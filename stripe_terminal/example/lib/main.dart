// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:example/models/discovery_method.dart';
import 'package:example/models/k.dart';
import 'package:example/stripe_api.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Stripe Secret Key: ${StripeApi.secretKey.isNotEmpty}');

  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _api = StripeApi();
  StripeTerminal? _terminal;

  var _locations = <Location>[];
  Location? _selectedLocation;

  StreamSubscription? _onConnectionStatusChangeSub;
  var _connectionStatus = ConnectionStatus.notConnected;
  bool _isSimulated = true;
  var _discoveringMethod = DiscoveryMethod.bluetoothScan;
  StreamSubscription? _discoverReaderSub;
  var _readers = const <Reader>[];
  StreamSubscription? _onUnexpectedReaderDisconnectSub;
  Reader? _reader;

  StreamSubscription? _onPaymentStatusChangeSub;
  PaymentStatus _paymentStatus = PaymentStatus.notReady;
  PaymentIntent? _paymentIntent;
  CancelableFuture<PaymentIntent>? _collectingPaymentMethod;

  @override
  void dispose() {
    unawaited(_onConnectionStatusChangeSub?.cancel());
    unawaited(_discoverReaderSub?.cancel());
    unawaited(_onUnexpectedReaderDisconnectSub?.cancel());
    unawaited(_onPaymentStatusChangeSub?.cancel());
    unawaited(_collectingPaymentMethod?.cancel());
    super.dispose();
  }

  Future<String> _fetchConnectionToken() async => _api.createTerminalConnectionToken();

  void _initTerminal() async {
    final permissions = [
      Permission.locationWhenInUse,
      Permission.bluetooth,
      if (Platform.isAndroid) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ],
    ];

    for (final permission in permissions) {
      final result = await permission.request();
      print('$permission: $result');

      if (result == PermissionStatus.denied || result == PermissionStatus.permanentlyDenied) return;
    }

    final stripeTerminal = await StripeTerminal.getInstance(
      shouldPrintLogs: true,
      fetchToken: _fetchConnectionToken,
    );
    setState(() => _terminal = stripeTerminal);
    _onConnectionStatusChangeSub = stripeTerminal.onConnectionStatusChange.listen((status) {
      print('Connection Status Changed: ${status.name}');
      setState(() => _connectionStatus = status);
    });
    _onUnexpectedReaderDisconnectSub = stripeTerminal.onUnexpectedReaderDisconnect.listen((reader) {
      print('Reader Unexpected Disconnected: ${reader.label}');
      setState(() => _reader = null);
    });
    _onPaymentStatusChangeSub = stripeTerminal.onPaymentStatusChange.listen((status) {
      print('Payment Status Changed: ${status.name}');
      setState(() => _paymentStatus = status);
    });
  }

  void _fetchLocations(StripeTerminal terminal) async {
    setState(() => _locations = const []);
    final locations = await terminal.listLocations();
    setState(() => _locations = locations);
  }

  void _toggleLocation(Location location) {
    setState(() => _selectedLocation = _selectedLocation == location ? null : location);
  }

  void _changeMode() {
    setState(() {
      _isSimulated = !_isSimulated;
      _readers = const [];
    });
    _stopDiscoverReaders();
  }

  void _changeDiscoveryMethod(DiscoveryMethod? method) {
    setState(() {
      _discoveringMethod = method!;
      _readers = const [];
    });
  }

  void _checkStatus(StripeTerminal terminal) async {
    final status = await terminal.getConnectionStatus();
    _showSnackBar('Connection status: ${status.name}');
  }

  Future<Reader?> _tryConnectReader(StripeTerminal terminal, Reader reader) async {
    String? getLocationId() {
      final locationId = _selectedLocation?.id ?? reader.locationId;
      if (locationId == null) _showSnackBar('Missing location');
      return locationId;
    }

    switch (_discoveringMethod) {
      case DiscoveryMethod.bluetoothScan || DiscoveryMethod.bluetoothProximity:
        final locationId = getLocationId();
        if (locationId == null) return null;
        return await terminal.connectBluetoothReader(
          reader,
          locationId: locationId,
        );
      case DiscoveryMethod.localMobile:
        final locationId = getLocationId();
        if (locationId == null) return null;
        return await terminal.connectMobileReader(
          reader,
          locationId: locationId,
        );
      case DiscoveryMethod.internet:
        return await terminal.connectInternetReader(reader);
      case DiscoveryMethod.handOff:
        return await terminal.connectHandoffReader(reader);
      case DiscoveryMethod.usb:
        final locationId = getLocationId();
        if (locationId == null) return null;
        return await terminal.connectUsbReader(reader, locationId: locationId);
    }
  }

  void _connectReader(StripeTerminal terminal, Reader reader) async {
    final connectedReader = await _tryConnectReader(terminal, reader);
    if (connectedReader == null) return;
    _showSnackBar(
        'Connected to a device: ${connectedReader.label ?? connectedReader.serialNumber}');
    setState(() => _reader = connectedReader);
  }

  void _disconnectReader(StripeTerminal terminal) async {
    await terminal.disconnectReader();
    _showSnackBar('Terminal ${_reader!.label ?? _reader!.serialNumber} disconnected');
    setState(() => _reader = null);
  }

  void _startDiscoverReaders(StripeTerminal terminal) {
    setState(() => _readers = const []);

    final configuration = switch (_discoveringMethod) {
      DiscoveryMethod.bluetoothScan => BluetoothDiscoveryConfiguration(
          isSimulated: _isSimulated,
        ),
      DiscoveryMethod.bluetoothProximity => BluetoothProximityDiscoveryConfiguration(
          isSimulated: _isSimulated,
        ),
      DiscoveryMethod.handOff => const HandoffDiscoveryConfiguration(),
      DiscoveryMethod.internet => InternetDiscoveryConfiguration(
          isSimulated: _isSimulated,
        ),
      DiscoveryMethod.localMobile => LocalMobileDiscoveryConfiguration(
          isSimulated: _isSimulated,
        ),
      DiscoveryMethod.usb => UsbDiscoveryConfiguration(
          isSimulated: _isSimulated,
        ),
    };

    final discoverReaderStream = terminal.discoverReaders(configuration);

    setState(() {
      _discoverReaderSub = discoverReaderStream.listen((readers) {
        setState(() => _readers = readers);
      }, onDone: () {
        setState(() => _discoverReaderSub = null);
      });
    });
  }

  void _stopDiscoverReaders() {
    unawaited(_discoverReaderSub?.cancel());
    setState(() => _discoverReaderSub = null);
  }

  void _createPaymentIntent(StripeTerminal terminal) async {
    final paymentIntent = await terminal.createPaymentIntent(PaymentIntentParameters(
      amount: 200,
      currency: K.currency,
      captureMethod: CaptureMethod.automatic,
      paymentMethodTypes: [PaymentMethodType.cardPresent],
    ));
    setState(() => _paymentIntent = paymentIntent);
    _showSnackBar('Payment intent created!');
  }

  void _createFromApiAndRetrievePaymentIntentFromSdk(StripeTerminal terminal) async {
    final paymentIntentClientSecret = await _api.createPaymentIntent();
    final paymentIntent = await terminal.retrievePaymentIntent(paymentIntentClientSecret);
    setState(() => _paymentIntent = paymentIntent);
    _showSnackBar('Payment intent retrieved!');
  }

  void _collectPaymentMethod(StripeTerminal terminal, PaymentIntent paymentIntent) async {
    final collectingPaymentMethod = terminal.collectPaymentMethod(
      paymentIntent,
      skipTipping: true,
    );
    setState(() {
      _collectingPaymentMethod = collectingPaymentMethod;
    });

    try {
      final paymentIntentWithPaymentMethod = await collectingPaymentMethod;
      setState(() {
        _paymentIntent = paymentIntentWithPaymentMethod;
        _collectingPaymentMethod = null;
      });
      _showSnackBar('Payment method collected!');
    } on TerminalException catch (exception) {
      setState(() => _collectingPaymentMethod = null);
      switch (exception.rawCode) {
        // TODO: map error codes from swift/android and unify them for dart
        case '2020' || 'cancelled':
          _showSnackBar('Collecting Payment method is cancelled!');
        default:
          rethrow;
      }
    }
  }

  void _cancelCollectingPaymentMethod(CancelableFuture<PaymentIntent> cancelable) async {
    await cancelable.cancel();
  }

  void _processPayment(StripeTerminal terminal, PaymentIntent paymentIntent) async {
    final processedPaymentIntent = await terminal.confirmPaymentIntent(paymentIntent);
    setState(() => _paymentIntent = processedPaymentIntent);
    _showSnackBar('Payment processed!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final terminal = _terminal;
    final paymentIntent = _paymentIntent;
    final collectingPaymentMethod = _collectingPaymentMethod;

    final mainTab = [
      TextButton(
        onPressed: terminal == null ? () async => _initTerminal() : null,
        child: const Text('Init Stripe'),
      ),
      TextButton(
        onPressed: () async => _api.createReader(),
        child: const Text('Random button'),
      ),
    ];
    final locationTab = [
      TextButton(
        onPressed: terminal != null ? () => _fetchLocations(terminal) : null,
        child: const Text('Fetch Locations'),
      ),
      const Divider(),
      ..._locations.map((e) {
        return ListTile(
          selected: _selectedLocation?.id == e.id,
          onTap: () => _toggleLocation(e),
          dense: true,
          title: Text('${e.id}: ${e.displayName}'),
          subtitle: Text('${e.address?.city},${e.address?.state},${e.address?.line1}'),
        );
      }),
    ];
    final readersTab = [
      TextButton(
        onPressed: terminal != null ? () => _checkStatus(terminal) : null,
        child: Text('Check status (${_connectionStatus.name})'),
      ),
      ListTile(
        onTap: _changeMode,
        title: const Text('Scanning mode'),
        trailing: Text(_isSimulated ? 'Simulator' : 'Real'),
      ),
      DropdownButton<DiscoveryMethod>(
        value: _discoveringMethod,
        onChanged: _changeDiscoveryMethod,
        items: DiscoveryMethod.values.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e.name),
          );
        }).toList(),
      ),
      if (_connectionStatus != ConnectionStatus.notConnected)
        TextButton(
          onPressed: terminal != null && _connectionStatus == ConnectionStatus.connected
              ? () => _disconnectReader(terminal)
              : null,
          child: const Text('Disconnect Reader'),
        )
      else if (_discoverReaderSub == null)
        TextButton(
          onPressed: terminal != null ? () => _startDiscoverReaders(terminal) : null,
          child: const Text('Scan Devices'),
        )
      else
        TextButton(
          onPressed: _stopDiscoverReaders,
          child: const Text('Stop Scanning'),
        ),
      const Divider(),
      ..._readers.map((e) {
        return ListTile(
          selected: e.serialNumber == _reader?.serialNumber,
          enabled: terminal != null &&
              _connectionStatus != ConnectionStatus.connecting &&
              (_reader == null || _reader!.serialNumber == e.serialNumber),
          onTap: terminal != null && _connectionStatus == ConnectionStatus.notConnected
              ? () => _connectReader(terminal, e)
              : null,
          title: Text(e.serialNumber),
          subtitle: Text('${e.deviceType?.name ?? 'Unknown'} ${e.locationId ?? 'NoLocation'}'),
          trailing: Text('${(e.batteryLevel * 100).toInt()}'),
        );
      }),
    ];
    final paymentTab = [
      ListTile(
        selected: true,
        title: Text('Payment Status: ${_paymentStatus.name}'),
      ),
      TextButton(
        onPressed: terminal != null ? () => _createPaymentIntent(terminal) : null,
        child: const Text('Create PaymentIntent via Skd'),
      ),
      TextButton(
        onPressed:
            terminal != null ? () => _createFromApiAndRetrievePaymentIntentFromSdk(terminal) : null,
        child: const Text('Create PaymentIntent via Api and Retrieve it via Sdk'),
      ),
      if (collectingPaymentMethod == null)
        TextButton(
          onPressed: terminal != null &&
                  _reader != null &&
                  paymentIntent != null &&
                  paymentIntent.status == PaymentIntentStatus.requiresPaymentMethod
              ? () => _collectPaymentMethod(terminal, paymentIntent)
              : null,
          child: const Text('Collect Payment Method'),
        )
      else
        TextButton(
          onPressed: () => _cancelCollectingPaymentMethod(collectingPaymentMethod),
          child: const Text('Cancel Collecting Payment Method'),
        ),
      TextButton(
        onPressed: terminal != null &&
                paymentIntent != null &&
                paymentIntent.status == PaymentIntentStatus.requiresConfirmation
            ? () => _processPayment(terminal, paymentIntent)
            : null,
        child: const Text('Process Payment'),
      ),
      const Divider(),
      if (paymentIntent != null)
        ListTile(
          title: Text('$paymentIntent'),
        )
    ];
    final cardTab = <Widget>[
      TextButton(
        onPressed: terminal != null
            ? () async => await terminal.setReaderDisplay(const Cart(
                  currency: K.currency,
                  tax: 130,
                  total: 1000,
                  lineItems: [
                    CartLineItem(
                      description: 'hello 1',
                      quantity: 1,
                      amount: 500,
                    ),
                    CartLineItem(
                      description: 'hello 2',
                      quantity: 1,
                      amount: 500,
                    ),
                  ],
                ))
            : null,
        child: const Text('Set reader display'),
      ),
    ];

    final tabs = {
      const Tab(text: 'Home'): mainTab,
      const Tab(text: 'Locations'): locationTab,
      const Tab(text: 'Readers'): readersTab,
      const Tab(text: 'Payment'): paymentTab,
      const Tab(text: 'Card'): cardTab,
    };

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.primary,
              child: SafeArea(
                child: TabBar(
                  isScrollable: true,
                  tabs: tabs.keys.toList(),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: tabs.values.map((e) {
                  return SingleChildScrollView(
                    child: Column(
                      children: e,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

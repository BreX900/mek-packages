// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

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

  String? _paymentIntentClientSecret;
  PaymentIntent? _paymentIntent;

  @override
  void dispose() {
    unawaited(_onConnectionStatusChangeSub?.cancel());
    unawaited(_discoverReaderSub?.cancel());
    unawaited(_onUnexpectedReaderDisconnectSub?.cancel());
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
    _onConnectionStatusChangeSub = stripeTerminal.onConnectionStatusChange.listen((event) {
      print('Connection Status Changed: ${event.name}');
      setState(() => _connectionStatus = event);
    });
    _onUnexpectedReaderDisconnectSub = stripeTerminal.onUnexpectedReaderDisconnect.listen((event) {
      print('Reader Unexpected Disconnected: ${event.label}');
      setState(() => _reader = null);
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

  Future<Reader?> _connectReader(StripeTerminal terminal, Reader reader) async {
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
      case DiscoveryMethod.embedded:
        _showSnackBar('Missing connect method implementation');
        return null;
    }
  }

  void _toggleReader(StripeTerminal terminal, Reader reader) async {
    if (_reader != null) {
      await terminal.disconnectReader();
      _showSnackBar('Terminal ${_reader!.label ?? _reader!.serialNumber} disconnected');
      setState(() => _reader = null);
      return;
    }

    final connectedReader = await _connectReader(terminal, reader);
    if (connectedReader == null) return;
    _showSnackBar(
        'Connected to a device: ${connectedReader.label ?? connectedReader.serialNumber}');
    setState(() => _reader = connectedReader);
  }

  void _startDiscoverReaders(StripeTerminal terminal) {
    setState(() => _readers = const []);

    final discoverReaderStream = terminal.discoverReaders(
      locationId: _selectedLocation?.id,
      discoveryMethod: _discoveringMethod,
      simulated: _isSimulated,
    );

    _discoverReaderSub = discoverReaderStream.listen((readers) {
      setState(() => _readers = readers);
    }, onDone: () {
      setState(() => _discoverReaderSub = null);
    });
  }

  void _stopDiscoverReaders() {
    unawaited(_discoverReaderSub?.cancel());
    setState(() => _discoverReaderSub = null);
  }

  void _createPaymentIntent() async {
    final paymentIntentClientSecret = await _api.createPaymentIntent();
    setState(() {
      _paymentIntentClientSecret = paymentIntentClientSecret;
      _paymentIntent = null;
    });
    _showSnackBar('Payment intent created!');
  }

  void _retrievePaymentIntent(StripeTerminal terminal, String paymentIntentClientSecret) async {
    final paymentIntent = await terminal.retrievePaymentIntent(paymentIntentClientSecret);
    setState(() => _paymentIntent = paymentIntent);
    _showSnackBar('Payment intent retrieved!');
  }

  void _collectPaymentMethod(StripeTerminal terminal, PaymentIntent paymentIntent) async {
    final paymentIntentWithPaymentMethod = await terminal.collectPaymentMethod(
      paymentIntent,
      skipTipping: true,
    );
    setState(() => _paymentIntent = paymentIntentWithPaymentMethod);
    _showSnackBar('Payment method collected!');
  }

  void _processPayment(StripeTerminal terminal, PaymentIntent paymentIntent) async {
    final processedPaymentIntent = await terminal.processPayment(paymentIntent);
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
    final paymentIntentClientSecret = _paymentIntentClientSecret;
    final paymentIntent = _paymentIntent;

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
      if (_discoverReaderSub == null)
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
          onTap: terminal != null ? () => _toggleReader(terminal, e) : null,
          title: Text(e.serialNumber),
          subtitle: Text('${e.deviceType?.name ?? 'Unknown'} ${e.locationId ?? 'NoLocation'}'),
          trailing: Text('${(e.batteryLevel * 100).toInt()}'),
        );
      }),
    ];
    final paymentTab = [
      TextButton(
        onPressed: _createPaymentIntent,
        child: const Text('Create PaymentIntent'),
      ),
      TextButton(
        onPressed: terminal != null && paymentIntentClientSecret != null
            ? () => _retrievePaymentIntent(terminal, paymentIntentClientSecret)
            : null,
        child: const Text('Retrieve Payment Intent'),
      ),
      TextButton(
        onPressed: terminal != null &&
                paymentIntent != null &&
                paymentIntent.status == PaymentIntentStatus.requiresPaymentMethod
            ? () => _collectPaymentMethod(terminal, paymentIntent)
            : null,
        child: const Text('Collect Payment Method'),
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
      // TextButton(
      //   child: const Text('Read Reusable Card Detail'),
      //   onPressed: () async {
      //     stripeTerminal.readReusableCardDetail().then((StripePaymentMethod paymentMethod) {
      //       _showSnackbar(
      //         'A card was read: ${paymentMethod.cardDetails}',
      //       );
      //     });
      //   },
      // ),
      TextButton(
        onPressed: terminal != null
            ? () async => await terminal.setReaderDisplay(const Cart(
                  currency: 'USD',
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

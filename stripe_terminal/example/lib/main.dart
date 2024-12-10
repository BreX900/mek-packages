// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:example/models/discovery_method.dart';
import 'package:example/models/k.dart';
import 'package:example/stripe_api.dart';
import 'package:example/utils/permission_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Stripe Secret Key: ${StripeApi.secretKey.isNotEmpty}');

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.amber,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = StripeApi();
  Terminal? _terminal;

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

  Future<void> _initTerminal() async {
    final permissions = [
      Permission.locationWhenInUse,
      Permission.bluetooth,
      if (Platform.isAndroid) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ],
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      print('$permission: $status');

      if (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
        _showSnackBar('Please grant ${permission.name} permission.');
        return;
      }
    }

    if (kReleaseMode) {
      for (final service in permissions.whereType<PermissionWithService>()) {
        final status = await service.serviceStatus;
        print('$service: $status');

        if (status != ServiceStatus.enabled) {
          _showSnackBar('Please enable ${service.name} service.');
          return;
        }
      }
    }

    final terminal = await Terminal.getInstance(
      shouldPrintLogs: true,
      fetchToken: _fetchConnectionToken,
    );
    setState(() => _terminal = terminal);
    _onConnectionStatusChangeSub = terminal.onConnectionStatusChange.listen((status) {
      print('Connection Status Changed: ${status.name}');
      setState(() {
        _connectionStatus = status;
        if (_connectionStatus == ConnectionStatus.notConnected) {
          _readers = const [];
          _reader = null;
        }
      });
    });
    _onUnexpectedReaderDisconnectSub = terminal.onUnexpectedReaderDisconnect.listen((reader) {
      print('Reader Unexpected Disconnected: ${reader.label}');
    });
    _onPaymentStatusChangeSub = terminal.onPaymentStatusChange.listen((status) {
      print('Payment Status Changed: ${status.name}');
      setState(() => _paymentStatus = status);
    });
  }

  Future<void> _fetchLocations(Terminal terminal) async {
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

  Future<void> _checkStatus(Terminal terminal) async {
    final status = await terminal.getConnectionStatus();
    _showSnackBar('Connection status: ${status.name}');
  }

  Future<Reader?> _tryConnectReader(Terminal terminal, Reader reader) async {
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

  Future<void> _connectReader(Terminal terminal, Reader reader) async {
    final connectedReader = await _tryConnectReader(terminal, reader);
    if (connectedReader == null) return;
    _showSnackBar(
        'Connected to a device: ${connectedReader.label ?? connectedReader.serialNumber}');
    setState(() => _reader = connectedReader);
  }

  Future<void> _disconnectReader(Terminal terminal, Reader reader) async {
    await terminal.disconnectReader();
    _showSnackBar('Terminal ${reader.label ?? reader.serialNumber} disconnected');
    setState(() => _reader = null);
  }

  void _startDiscoverReaders(Terminal terminal) {
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
        setState(() {
          _discoverReaderSub = null;
          _readers = const [];
        });
      });
    });
  }

  void _stopDiscoverReaders() {
    unawaited(_discoverReaderSub?.cancel());
    setState(() {
      _discoverReaderSub = null;
      _readers = const [];
    });
  }

  Future<void> _createPaymentIntent(Terminal terminal) async {
    final paymentIntent = await terminal.createPaymentIntent(PaymentIntentParameters(
      amount: 200,
      currency: K.currency,
      captureMethod: CaptureMethod.automatic,
      paymentMethodTypes: [PaymentMethodType.cardPresent],
    ));
    setState(() => _paymentIntent = paymentIntent);
    _showSnackBar('Payment intent created!');
  }

  Future<void> _createFromApiAndRetrievePaymentIntentFromSdk(Terminal terminal) async {
    final paymentIntentClientSecret = await _api.createPaymentIntent();
    final paymentIntent = await terminal.retrievePaymentIntent(paymentIntentClientSecret);
    setState(() => _paymentIntent = paymentIntent);
    _showSnackBar('Payment intent retrieved!');
  }

  Future<void> _collectPaymentMethod(Terminal terminal, PaymentIntent paymentIntent) async {
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
      switch (exception.code) {
        case TerminalExceptionCode.canceled:
          _showSnackBar('Collecting Payment method is cancelled!');
        default:
          rethrow;
      }
    }
  }

  Future<void> _cancelCollectingPaymentMethod(CancelableFuture<PaymentIntent> cancelable) async {
    await cancelable.cancel();
  }

  Future<void> _confirmPaymentIntent(Terminal terminal, PaymentIntent paymentIntent) async {
    final processedPaymentIntent = await terminal.confirmPaymentIntent(paymentIntent);
    setState(() => _paymentIntent = processedPaymentIntent);
    _showSnackBar('Payment processed!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

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
        onPressed: terminal != null ? () async => _fetchLocations(terminal) : null,
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
        onPressed: terminal != null ? () async => _checkStatus(terminal) : null,
        child: Text('Check status (${_connectionStatus.name})'),
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
      if (_discoveringMethod.canSimulate)
        ListTile(
          onTap: _changeMode,
          title: const Text('Scanning mode'),
          trailing: Text(_isSimulated ? 'Simulator' : 'Real'),
        ),
      if (_connectionStatus != ConnectionStatus.notConnected)
        TextButton(
          onPressed: terminal != null && _connectionStatus == ConnectionStatus.connected
              ? () async => _disconnectReader(terminal, _reader!)
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
      ...[
        ..._readers,
        if (_reader != null) _reader!,
      ].map((e) {
        return ListTile(
          selected: e.serialNumber == _reader?.serialNumber,
          enabled: terminal != null &&
              _connectionStatus != ConnectionStatus.connecting &&
              (_reader == null || _reader!.serialNumber == e.serialNumber),
          onTap: terminal != null && _connectionStatus == ConnectionStatus.notConnected
              ? () async => _connectReader(terminal, e)
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
        onPressed: terminal != null ? () async => _createPaymentIntent(terminal) : null,
        child: const Text('Create PaymentIntent via Skd'),
      ),
      TextButton(
        onPressed: terminal != null
            ? () async => _createFromApiAndRetrievePaymentIntentFromSdk(terminal)
            : null,
        child: const Text('Create PaymentIntent via Api and Retrieve it via Sdk'),
      ),
      if (collectingPaymentMethod == null)
        TextButton(
          onPressed: terminal != null &&
                  _reader != null &&
                  paymentIntent != null &&
                  paymentIntent.status == PaymentIntentStatus.requiresPaymentMethod
              ? () async => _collectPaymentMethod(terminal, paymentIntent)
              : null,
          child: const Text('Collect Payment Method'),
        )
      else
        TextButton(
          onPressed: () async => _cancelCollectingPaymentMethod(collectingPaymentMethod),
          child: const Text('Cancel Collecting Payment Method'),
        ),
      TextButton(
        onPressed: terminal != null &&
                paymentIntent != null &&
                paymentIntent.status == PaymentIntentStatus.requiresConfirmation
            ? () async => _confirmPaymentIntent(terminal, paymentIntent)
            : null,
        child: const Text('Confirm PaymentIntent'),
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(64.0 + viewPadding.top),
          child: Padding(
            padding: EdgeInsets.only(top: viewPadding.top),
            child: TabBar(
              isScrollable: true,
              tabs: tabs.keys.toList(),
            ),
          ),
        ),
        body: TabBarView(
          children: tabs.values.map((e) {
            return SingleChildScrollView(
              child: Column(
                children: e,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

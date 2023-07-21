// ignore_for_file: avoid_print

import 'dart:async';

import 'package:example/stripe_api.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  // await Backend().run();

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
  var _readers = const <StripeReader>[];
  StreamSubscription? _onUnexpectedReaderDisconnectSub;
  StripeReader? _reader;

  String? _paymentIntentClientSecret;
  PaymentIntentStatus? _paymentIntentStatus;

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
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ];

    for (final permission in permissions) {
      final result = await permission.request();
      print('$permission: $result');
      if (result == PermissionStatus.denied) return;
    }

    final stripeTerminal = await StripeTerminal.getInstance(
      fetchToken: _fetchConnectionToken,
    );
    setState(() {
      _terminal = stripeTerminal;
    });
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
    final status = await terminal.connectionStatus();
    _showSnackBar('Connection status: ${status.name}');
  }

  void _toggleReader(StripeTerminal terminal, StripeReader reader) async {
    if (_reader != null) {
      await terminal.disconnectReader();
      _showSnackBar('Terminal ${_reader!.label ?? _reader!.serialNumber} disconnected');
      setState(() => _reader = null);
      return;
    }

    final connectedReader = switch (_discoveringMethod) {
      DiscoveryMethod.bluetoothScan => await terminal.connectBluetoothReader(
          reader.serialNumber,
          locationId: (_selectedLocation?.id ?? reader.locationId)!,
        ),
      DiscoveryMethod.localMobile => await terminal.connectMobileReader(
          reader.serialNumber,
          locationId: (_selectedLocation?.id ?? reader.locationId)!,
        ),
      DiscoveryMethod.internet ||
      DiscoveryMethod.handOff ||
      DiscoveryMethod.embedded ||
      DiscoveryMethod.usb =>
        null,
    };
    _showSnackBar(connectedReader != null
        ? 'Connected to a device: ${connectedReader.label ?? connectedReader.serialNumber}'
        : 'Missing connect method implementation');
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
      setState(() {
        _readers = readers;
      });
    });
  }

  void _stopDiscoverReaders() {
    unawaited(_discoverReaderSub?.cancel());
    setState(() => _discoverReaderSub = null);
  }

  void _createPaymentIntent() async {
    final paymentIntent = await _api.createPaymentIntent();
    setState(() {
      _paymentIntentClientSecret = paymentIntent.clientSecret;
      _paymentIntentStatus = PaymentIntentStatus.requiresPaymentMethod;
    });
    _showSnackBar('PaymentIntent status: ${paymentIntent.status}');
  }

  void _collectPaymentMethod(StripeTerminal terminal, String paymentIntentClientSecret) async {
    final collectingPaymentIntent = terminal.collectPaymentMethod(
      paymentIntentClientSecret,
      skipTipping: true,
    );
    final paymentIntent = await collectingPaymentIntent.result;
    setState(() {
      _paymentIntentClientSecret = paymentIntent.clientSecret;
      _paymentIntentStatus = paymentIntent.status!;
    });
    _showSnackBar('PaymentIntent status: ${paymentIntent.status!.name}');
  }

  void _confirmPaymentIntent(StripeTerminal terminal, String paymentIntentClientSecret) async {
    final paymentIntent = await terminal.processPayment(paymentIntentClientSecret);
    setState(() {
      _paymentIntentClientSecret = paymentIntent.clientSecret;
      _paymentIntentStatus = paymentIntent.status!;
    });
    _showSnackBar('PaymentIntent status: ${paymentIntent.status!.name}');
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
    final paymentIntentStatus = _paymentIntentStatus;

    final mainTab = [
      TextButton(
        onPressed: terminal == null ? () async => _initTerminal() : null,
        child: const Text('Init Stripe'),
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
          subtitle: Text('${e.deviceType.name} ${e.locationId ?? 'NoLocation'}'),
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
        onPressed: terminal != null &&
                paymentIntentClientSecret != null &&
                paymentIntentStatus == PaymentIntentStatus.requiresPaymentMethod
            ? () => _collectPaymentMethod(terminal, paymentIntentClientSecret)
            : null,
        child: const Text('Collect Payment Method'),
      ),
      TextButton(
        onPressed: terminal != null &&
                paymentIntentClientSecret != null &&
                paymentIntentStatus == PaymentIntentStatus.requiresCapture
            ? () => _confirmPaymentIntent(terminal, paymentIntentClientSecret)
            : null,
        child: const Text('Process Payment'),
      ),
      const Divider(),
      if (paymentIntentStatus != null)
        ListTile(
          title: Text('PaymentIntent status: $paymentIntentStatus'),
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
      // TextButton(
      //   child: const Text('Set reader display'),
      //   onPressed: () async {
      //     stripeTerminal.setReaderDisplay(const Cart(
      //       currency: 'USD',
      //       tax: 130,
      //       total: 1000,
      //       lineItems: [
      //         CartLineItem(
      //           description: 'hello 1',
      //           quantity: 1,
      //           amount: 500,
      //         ),
      //         CartLineItem(
      //           description: 'hello 2',
      //           quantity: 1,
      //           amount: 500,
      //         ),
      //       ],
      //     ));
      //   },
      // ),
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

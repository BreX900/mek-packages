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
    final config = DiscoverConfig(
      locationId: _selectedLocation?.id,
      discoveryMethod: _discoveringMethod,
      simulated: _isSimulated,
    );
    _discoverReaderSub = terminal.discoverReaders(config).listen((readers) {
      setState(() {
        _readers = readers;
      });
    });
  }

  void _stopDiscoverReaders() {
    unawaited(_discoverReaderSub?.cancel());
    setState(() => _discoverReaderSub = null);
  }

  // Future<String> createPaymentIntent() async {
  //   Response invoice = await _dio.post("/createPaymentIntent", data: {
  //     "email": "awazgyawali@gmail.com",
  //     "order": {"test": "1"},
  //     "ticketCount": 3,
  //     "price": 5,
  //   });
  //   return jsonDecode(invoice.data)["paymentIntent"]["client_secret"];
  // }

  // void _collectPaymentMethod() async {
  //   final paymentIntent = await _api.createPaymentIntent();
  //   _terminal.
  // }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final terminal = _terminal;

    final body = Column(
      children: [
        TextButton(
          onPressed: terminal == null ? () async => _initTerminal() : null,
          child: const Text('Init Stripe'),
        ),
        const Divider(),
        TextButton(
          onPressed: terminal != null ? () => _fetchLocations(terminal) : null,
          child: const Text('Fetch Locations'),
        ),
        ..._locations.map((e) {
          return ListTile(
            selected: _selectedLocation?.id == e.id,
            onTap: () => _toggleLocation(e),
            dense: true,
            title: Text('${e.id}: ${e.displayName}'),
            subtitle: Text('${e.address?.city},${e.address?.state},${e.address?.line1}'),
          );
        }),
        const Divider(),
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

        TextButton(
          onPressed: terminal != null ? () => _checkStatus(terminal) : null,
          child: Text('Check status (${_connectionStatus.name})'),
        ),
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
        const Divider(),
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
        // TextButton(
        //   child: const Text("Collect Payment Method"),
        //   onPressed: () async {
        //     paymentIntentClientSecret = await createPaymentIntent();
        //     stripeTerminal
        //         .collectPaymentMethod()
        //         .then((StripePaymentIntent paymentIntent) async {
        //       _dio.post("/confirmPaymentIntent", data: {
        //         "paymentIntentId": paymentIntent.id,
        //       });
        //       _showSnackbar(
        //         "A payment method was captured",
        //       );
        //     });
        //   },
        // ),
        // TextButton(
        //   child: const Text("Misc Button"),
        //   onPressed: () async {
        //     StripeReader.fromJson(
        //       {
        //         "locationStatus": 2,
        //         "deviceType": 3,
        //         "serialNumber": "STRM26138003393",
        //         "batteryStatus": 0,
        //         "simulated": false,
        //         "availableUpdate": false
        //       },
        //     );
        //   },
        // ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: body,
      ),
    );
  }
}

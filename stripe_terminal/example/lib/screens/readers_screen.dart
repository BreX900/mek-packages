import 'dart:async';

import 'package:example/models/discovery_method.dart';
import 'package:example/models/k.dart';
import 'package:example/models/not_found_location_exeception.dart';
import 'package:example/utils/linear_progress_indicator_bar.dart';
import 'package:example/utils/reader_delegates.dart';
import 'package:example/utils/state_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class ReadersScreen extends StatefulWidget {
  final ValueListenable<ConnectionStatus> connectionStatusListenable;
  final ValueListenable<Location?> locationListenable;
  final ValueNotifier<Reader?> connectedReaderNotifier;

  const ReadersScreen({
    super.key,
    required this.connectionStatusListenable,
    required this.locationListenable,
    required this.connectedReaderNotifier,
  });

  @override
  State<ReadersScreen> createState() => _ReadersScreenState();
}

class _ReadersScreenState extends State<ReadersScreen> with StateTools {
  var _isSimulated = true;
  var _discoveryMethod = DiscoveryMethod.bluetoothScan;

  StreamSubscription<List<Reader>>? _discoverReaderSub;
  var _readers = const <Reader>[];

  Future<void> _checkStatus() async {
    final status = await Terminal.instance.getConnectionStatus();
    showSnackBar('Connection status: ${status.name}');
  }

  Future<void> _changeDiscoveryMethod(DiscoveryMethod? method) async {
    setState(() {
      _discoveryMethod = method!;
      _readers = const [];
    });
    await _stopDiscoverReaders();
  }

  Future<void> _changeMode() async {
    setState(() {
      _isSimulated = !_isSimulated;
      _readers = const [];
    });
    await _stopDiscoverReaders();
  }

  void _startDiscoverReaders() {
    setState(() => _readers = const []);

    final configuration = switch (_discoveryMethod) {
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
      DiscoveryMethod.tapToPay => TapToPayDiscoveryConfiguration(
          isSimulated: _isSimulated,
        ),
      DiscoveryMethod.usb => UsbDiscoveryConfiguration(
          isSimulated: _isSimulated,
        ),
    };

    final discoverReaderStream = Terminal.instance.discoverReaders(configuration);

    setState(() {
      _discoverReaderSub = discoverReaderStream.listen((readers) {
        setState(() => _readers = readers);
      }, onDone: () {
        setState(() => _discoverReaderSub = null);
      });
    });
  }

  Future<void> _stopDiscoverReaders() async {
    await _discoverReaderSub?.cancel();
    setState(() => _discoverReaderSub = null);
  }

  Future<void> _connectReader(Reader reader) async {
    String getLocationId() {
      final location = widget.locationListenable.value;
      final locationId = location?.id ?? reader.locationId;
      if (locationId != null) return locationId;
      throw NotFoundLocationException();
    }

    try {
      final connectionConfiguration = switch (_discoveryMethod) {
        DiscoveryMethod.bluetoothScan ||
        DiscoveryMethod.bluetoothProximity =>
          BluetoothConnectionConfiguration(
            locationId: getLocationId(),
            readerDelegate: LoggingMobileReaderDelegate(showSnackBar),
          ),
        DiscoveryMethod.tapToPay => TapToPayConnectionConfiguration(
            locationId: getLocationId(),
            readerDelegate: LoggingTapToPayReaderDelegate(showSnackBar),
          ),
        DiscoveryMethod.internet => InternetConnectionConfiguration(
            readerDelegate: LoggingInternetReaderDelegate(showSnackBar),
          ),
        DiscoveryMethod.handOff => HandoffConnectionConfiguration(
            readerDelegate: LoggingHandoffReaderDelegate(showSnackBar),
          ),
        DiscoveryMethod.usb => UsbConnectionConfiguration(
            locationId: getLocationId(),
            readerDelegate: LoggingMobileReaderDelegate(showSnackBar),
          ),
      };

      final connectedReader =
          await Terminal.instance.connectReader(reader, configuration: connectionConfiguration);

      showSnackBar(
          'Connected to a device: ${connectedReader.label ?? connectedReader.serialNumber}');
      widget.connectedReaderNotifier.value = connectedReader;
    } on NotFoundLocationException {
      showSnackBar('Location not selected!');
    }
  }

  Future<void> _disconnectReader() async {
    final reader = widget.connectedReaderNotifier.value;

    await Terminal.instance.disconnectReader();

    showSnackBar('Terminal ${reader?.label ?? reader?.serialNumber ?? '???'} disconnected');
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus = watch(widget.connectionStatusListenable);
    final connectedReader = watch(widget.connectedReaderNotifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Readers'),
        bottom: isMutating ? const LinearProgressIndicatorBar() : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FilledButton.tonal(
              onPressed: !isMutating ? () => mutate(_checkStatus) : null,
              child: Text('Check status (${connectionStatus.name})'),
            ),
            const Divider(height: 32.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButtonFormField<DiscoveryMethod>(
                value: _discoveryMethod,
                onChanged: !isMutating && connectionStatus == ConnectionStatus.notConnected
                    ? _changeDiscoveryMethod
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Discovery method'),
                items: DiscoveryMethod.values.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.name),
                  );
                }).toList(),
              ),
            ),
            if (_discoveryMethod.canSimulate)
              SwitchListTile(
                onChanged: !isMutating && connectionStatus == ConnectionStatus.notConnected
                    ? (_) => mutate(_changeMode)
                    : null,
                value: _isSimulated,
                title: const Text('Is simulate scanning mode?'),
              ),
            const SizedBox(height: 12.0),
            if (connectionStatus == ConnectionStatus.connected)
              FilledButton(
                onPressed: !isMutating ? () => mutate(_disconnectReader) : null,
                child: const Text('Disconnect Reader'),
              )
            else if (_discoverReaderSub == null)
              FilledButton(
                onPressed: !isMutating && connectionStatus == ConnectionStatus.notConnected
                    ? _startDiscoverReaders
                    : null,
                child: const Text('Scan Devices'),
              )
            else
              FilledButton(
                onPressed: !isMutating && connectionStatus == ConnectionStatus.discovering
                    ? _stopDiscoverReaders
                    : null,
                child: const Text('Stop Scanning'),
              ),
            const Divider(height: 32.0),
            ...(connectedReader != null ? [connectedReader] : _readers).map((reader) {
              return ListTile(
                selected: reader.serialNumber == connectedReader?.serialNumber,
                enabled: !isMutating &&
                    connectionStatus != ConnectionStatus.connecting &&
                    (connectedReader == null ||
                        connectedReader.serialNumber == reader.serialNumber),
                onTap: () => mutate(() async => _connectReader(reader)),
                title: Text(reader.serialNumber),
                subtitle: Text(
                    '${reader.deviceType?.name ?? 'Unknown'} ${reader.locationId ?? 'NoLocation'}'),
                trailing: Text('${(reader.batteryLevel * 100).toInt()}'),
              );
            }),
            if (connectedReader != null) ...[
              const SizedBox(height: 8.0),
              FilledButton.tonal(
                onPressed: !isMutating
                    ? () => mutate(() async => await Terminal.instance.setReaderDisplay(const Cart(
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
                        )))
                    : null,
                child: const Text('Set reader display'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

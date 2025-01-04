import 'dart:async';

import 'package:example/screens/locations_screen.dart';
import 'package:example/screens/more_screen.dart';
import 'package:example/screens/payments_screen.dart';
import 'package:example/screens/readers_screen.dart';
import 'package:example/utils/state_tools.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class TerminalArea extends StatefulWidget {
  const TerminalArea({super.key});

  @override
  State<TerminalArea> createState() => _TerminalAreaState();
}

class _TerminalAreaState extends State<TerminalArea> with StateTools {
  var _destinationIndex = 0;

  late StreamSubscription<ConnectionStatus> _onConnectionStatusChangeSub;
  final _connectionStatusNotifier = ValueNotifier<ConnectionStatus>(ConnectionStatus.notConnected);

  late StreamSubscription<PaymentStatus> _onPaymentStatusChangeSub;
  final _paymentStatusNotifier = ValueNotifier<PaymentStatus>(PaymentStatus.notReady);

  final _locationNotifier = ValueNotifier<Location?>(null);

  final _connectedReaderNotifier = ValueNotifier<Reader?>(null);

  @override
  void initState() {
    super.initState();
    _onConnectionStatusChangeSub = Terminal.instance.onConnectionStatusChange.listen((status) {
      report('Connection Status Changed: ${status.name}');
      _connectionStatusNotifier.value = status;
      if (status == ConnectionStatus.notConnected) _connectedReaderNotifier.value = null;
    });
    _onPaymentStatusChangeSub = Terminal.instance.onPaymentStatusChange.listen((status) {
      report('Payment Status Changed: ${status.name}');
      _paymentStatusNotifier.value = status;
    });
    mutate(_restoreStateAfterHotRestart);
  }

  @override
  void dispose() {
    unawaited(_onConnectionStatusChangeSub.cancel());
    _connectionStatusNotifier.dispose();
    unawaited(_onPaymentStatusChangeSub.cancel());
    _paymentStatusNotifier.dispose();
    _locationNotifier.dispose();
    _connectedReaderNotifier.dispose();
    super.dispose();
  }

  Future<void> _restoreStateAfterHotRestart() async {
    final (connectionStatus, paymentStatys, connectedReader) = await (
      Terminal.instance.getConnectionStatus(),
      Terminal.instance.getPaymentStatus(),
      Terminal.instance.getConnectedReader()
    ).wait;
    _connectionStatusNotifier.value = connectionStatus;
    _paymentStatusNotifier.value = paymentStatys;
    _connectedReaderNotifier.value = connectedReader;
  }

  void _changeDestination(int index) {
    if (_destinationIndex == index) return;
    setState(() => _destinationIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (isMutating) {
      return const Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _destinationIndex,
        children: [
          LocationsScreen(
            locationNotifier: _locationNotifier,
          ),
          ReadersScreen(
            connectionStatusListenable: _connectionStatusNotifier,
            locationListenable: _locationNotifier,
            connectedReaderNotifier: _connectedReaderNotifier,
          ),
          PaymentsScreen(
            paymentStatusListenable: _paymentStatusNotifier,
            connectedReaderListenable: _connectedReaderNotifier,
          ),
          MoreScreen(
            connectionStatusListenable: _connectionStatusNotifier,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _destinationIndex,
        onDestinationSelected: _changeDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.location_pin),
            label: 'Locations',
          ),
          NavigationDestination(
            icon: Icon(Icons.barcode_reader),
            label: 'Readers',
          ),
          NavigationDestination(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

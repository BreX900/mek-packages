import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

/// [DiscoveryConfiguration]
enum DiscoveryMethod {
  /// [BluetoothDiscoveryConfiguration]
  bluetoothScan(canSimulate: true),

  /// [BluetoothProximityDiscoveryConfiguration]
  bluetoothProximity(canSimulate: true),

  /// [HandoffDiscoveryConfiguration]
  handOff(),

  /// [InternetDiscoveryConfiguration]
  internet(canSimulate: true),

  /// [TapToPayDiscoveryConfiguration]
  tapToPay(canSimulate: true),

  /// [UsbDiscoveryConfiguration]
  usb(canSimulate: true);

  final bool canSimulate;

  const DiscoveryMethod({this.canSimulate = false});
}

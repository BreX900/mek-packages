import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

/// [DiscoveryConfiguration]
enum DiscoveryMethod {
  /// [BluetoothDiscoveryConfiguration]
  bluetoothScan,

  /// [BluetoothProximityDiscoveryConfiguration]
  bluetoothProximity,

  /// [HandoffDiscoveryConfiguration]
  handOff,

  /// [InternetDiscoveryConfiguration]
  internet,

  /// [LocalMobileDiscoveryConfiguration]
  localMobile,

  /// [UsbDiscoveryConfiguration]
  usb,
}

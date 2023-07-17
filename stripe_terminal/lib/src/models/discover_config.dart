import 'package:mek_data_class/mek_data_class.dart';

part 'discover_config.g.dart';

enum DiscoveryMethod {
  /// To discover `bluetooth` based readers.
  bluetoothScan,

  /// To discover `internet` based readers.
  internet,

  /// To discover `localMobile` based readers.
  localMobile,

  /// To discover `handOff` based readers.
  handOff,

  /// To discover `embedded` based readers.
  embedded,

  /// To discover `usb` based readers.
  usb,
}

@DataClass()
class DiscoverConfig with _$DiscoverConfig {
  /// The method of discovery. It can be `bluetooth`,`internet`,`localMobile`,`handOff`,`embedded` or`usb`.
  ///
  /// Its a required field
  final DiscoveryMethod discoveryMethod;

  /// Weather to show simulated devices in the discovery process.
  ///
  /// Defaults to `false`
  final bool simulated;

  /// Id of the location where you want to initate the discovery.
  ///
  /// Mostly required on bluetooth reader
  final String? locationId;

  const DiscoverConfig({
    required this.discoveryMethod,
    this.locationId,
    this.simulated = false,
  });
}

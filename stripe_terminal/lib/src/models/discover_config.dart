import 'package:mek_data_class/mek_data_class.dart';

part 'discover_config.g.dart';

/// The DiscoveryMethod enum represents the possible ways of discovery readers.
///
/// https://stripe.com/docs/terminal/readers/connecting
enum DiscoveryMethod {
  /// The [bluetoothScan] discovery method searches for Stripe Terminal's bluetooth-capable readers.
  bluetoothScan,

  /// The [internet] discovery method searches for internet-connected readers, such as the Verifone P400 or the BBPOS WisePOS E.
  internet,

  /// The [localMobile] discovery method allows the user to use the phone's or tablet's NFC reader as a payment terminal for NFC (tap) payments only.
  localMobile,

  /// The [handOff] discovery method is only supported when running directly on a reader. It allows the user to delegate the collecting of payments to a separate application that is responsible for collecting payments.
  handOff,

  /// The [embedded] discovery method allows the user to collect payments using the reader upon which the Application is currently running.
  embedded,

  /// The [usb] discovery method allows the user to use the device's usb input(s) to interact with Stripe Terminal's usb-capable readers.
  usb,
}

/// The DiscoveryConfiguration contains configuration information relevant to the reader discovery process.
///
/// Use of this SDK is subject to the Stripe Terminal Terms: https://stripe.com/terminal/legal
@DataClass()
class DiscoverConfig with _$DiscoverConfig {
  /// The [DiscoveryMethod] to use to find connectible readers.
  final DiscoveryMethod discoveryMethod;

  /// Whether the devices returned by discovery should be simulated
  final bool simulated;

  /// Location used to scope IP connected readers
  final String? locationId;

  // TODO: Add timeout field

  const DiscoverConfig({
    this.discoveryMethod = DiscoveryMethod.bluetoothScan,
    this.simulated = false,
    this.locationId,
  });
}

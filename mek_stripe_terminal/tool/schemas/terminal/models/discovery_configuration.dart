import 'discovery_filter.dart';

/// Protocol for classes to conform to that apply configuration options for discovering readers.
///
/// You should not implement this protocol yourself; instead, use one of the following:
///
/// - [BluetoothDiscoveryConfigurationApi]
/// - [BluetoothProximityDiscoveryConfigurationApi]
/// - [AppsOnDevicesDiscoveryConfigurationApi]
/// - [InternetDiscoveryConfigurationApi]
/// - [LocalMobileDiscoveryConfiguration]
/// - [UsbDiscoveryConfigurationApi]
/// Objects of those types get passed into the Terminal.shared.discoverReaders() method to control which devices get discovered, and how.
sealed class DiscoveryConfigurationApi {
  const DiscoveryConfigurationApi();
}

/// In IOS this class is called BluetoothScanDiscoveryConfiguration
///
/// The Bluetooth discovery method searches for Stripe Terminal’s Bluetooth-capable readers.
///
/// When discovering a reader using this method, the didUpdateDiscoveredReaders delegate method will
/// be called multiple times as the Bluetooth scan proceeds.
class BluetoothDiscoveryConfigurationApi extends DiscoveryConfigurationApi {
  final bool isSimulated;
  final int? timeoutInSeconds;

  const BluetoothDiscoveryConfigurationApi({this.isSimulated = false, this.timeoutInSeconds});
}

/// ONLY ON IOS
///
/// The Bluetooth Proximity discovery method searches for a subset of Stripe Terminal’s Bluetooth-capable readers.
///
/// If your app will be used in a busy environment with multiple iOS devices pairing to multiple
/// available readers at the same time, we recommend using this discovery method.
///
/// After a reader has been discovered using this method, the LEDs located above the reader’s power
/// button will start flashing multiple colors. After discovering the reader, your app should prompt
/// the user to confirm that the reader is flashing, and require a user action (e.g. tapping a button)
/// to connect to the reader.
///
/// When discovering a reader using this method, the didUpdateDiscoveredReaders delegate method will
/// be called twice. It will be called for the first time when the reader is initially discovered. The
/// reader’s LEDs will begin flashing. After a short delay, didUpdateDiscoveredReaders will be called
/// a second time with an updated reader object, populated with additional info about the device, like
/// its battery level.
///
/// Note:
/// - The Bluetooth Proximity discovery method can only discover Stripe Reader M2 and BBPOS Chipper 2X BT readers.
/// - The simulated Bluetooth Proximity discovery method will always return a Stripe Reader M2 simulated device.
class BluetoothProximityDiscoveryConfigurationApi extends DiscoveryConfigurationApi {
  final bool isSimulated;

  const BluetoothProximityDiscoveryConfigurationApi({this.isSimulated = false});
}

/// ONLY ON ANDROID
class AppsOnDevicesDiscoveryConfigurationApi extends DiscoveryConfigurationApi {
  const AppsOnDevicesDiscoveryConfigurationApi();
}

/// The Internet discovery method searches for internet-connected readers, such as the Stripe S700 or
/// the BBPOS WisePOS E.
///
/// When discovering a reader with this method didUpdateDiscoveredReaders will only be called once
/// with a list of readers from /v1/terminal/readers. Note that this will include readers that are
/// both online and offline.
///
/// Because the discovery process continues if connecting to a discovered reader fails, the SDK will
/// refresh the list of Readers and call didUpdateDiscoveredReaders with the results. For more details
/// about failed connect calls, see -[SCPTerminal connectReader:connectionConfig:cancelable:completion:]
class InternetDiscoveryConfigurationApi extends DiscoveryConfigurationApi {
  final bool isSimulated;
  final String? locationId;
  final int? timeoutInSeconds;
  final DiscoveryFilterApi? discoveryFilter;

  const InternetDiscoveryConfigurationApi({
    this.isSimulated = false,
    this.locationId,
    this.timeoutInSeconds,
    this.discoveryFilter,
  });
}

/// The Local Mobile discovery method searches for any readers built into the merchant device that
/// are supported by Stripe Terminal. When discovering a reader with this method didUpdateDiscoveredReaders
/// will only be called once with a list of discovered readers, if any. An error may be provided if a
/// discovery attempt is made in an on a device without hardware support for the Apple Built-In reader
/// or one running an unsupported version of iOS.
class TapToPayDiscoveryConfigurationApi extends DiscoveryConfigurationApi {
  final bool isSimulated;

  const TapToPayDiscoveryConfigurationApi({this.isSimulated = false});
}

/// ONLY ON ANDROID
class UsbDiscoveryConfigurationApi extends DiscoveryConfigurationApi {
  final bool isSimulated;
  final int? timeoutInSeconds;

  const UsbDiscoveryConfigurationApi({this.isSimulated = false, this.timeoutInSeconds});
}

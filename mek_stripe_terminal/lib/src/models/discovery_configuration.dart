import 'package:mek_stripe_terminal/src/api/terminal_api.g.dart';

typedef DiscoveryConfiguration = DiscoveryConfigurationApi;

typedef BluetoothDiscoveryConfiguration = BluetoothDiscoveryConfigurationApi;

extension BluetoothDiscoveryConfigurationUtils on BluetoothDiscoveryConfiguration {
  Duration? get timeout {
    if (timeoutInSeconds case final value?) return Duration(seconds: value);
    return null;
  }
}

typedef BluetoothProximityDiscoveryConfiguration = BluetoothProximityDiscoveryConfigurationApi;

typedef AppsOnDevicesDiscoveryConfiguration = AppsOnDevicesDiscoveryConfigurationApi;

typedef InternetDiscoveryConfiguration = InternetDiscoveryConfigurationApi;

extension InternetDiscoveryConfigurationUtils on InternetDiscoveryConfigurationApi {
  Duration? get timeout {
    if (timeoutInSeconds case final value?) return Duration(seconds: value);
    return null;
  }
}

typedef TapToPayDiscoveryConfiguration = TapToPayDiscoveryConfigurationApi;

typedef UsbDiscoveryConfiguration = UsbDiscoveryConfigurationApi;

extension UsbDiscoveryConfigurationUtils on UsbDiscoveryConfigurationApi {
  Duration? get timeout {
    if (timeoutInSeconds case final value?) return Duration(seconds: value);
    return null;
  }
}

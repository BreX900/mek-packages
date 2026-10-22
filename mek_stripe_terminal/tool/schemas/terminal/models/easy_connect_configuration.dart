import 'connection_configuration.dart';
import 'discovery_configuration.dart';

/// Configuration for the EasyConnect flow, which discovers and connects to a reader in one step.
sealed class EasyConnectConfigurationApi {
  const EasyConnectConfigurationApi();
}

class InternetEasyConnectConfigurationApi extends EasyConnectConfigurationApi {
  final InternetDiscoveryConfigurationApi discoveryConfiguration;
  final InternetConnectionConfigurationApi connectionConfiguration;

  const InternetEasyConnectConfigurationApi({
    required this.discoveryConfiguration,
    required this.connectionConfiguration,
  });
}

class AppsOnDevicesEasyConnectionConfigurationApi extends EasyConnectConfigurationApi {
  final AppsOnDevicesDiscoveryConfigurationApi discoveryConfiguration;
  final AppsOnDevicesConnectionConfigurationApi connectionConfiguration;

  const AppsOnDevicesEasyConnectionConfigurationApi({
    required this.discoveryConfiguration,
    required this.connectionConfiguration,
  });
}

class TapToPayEasyConnectConfigurationApi extends EasyConnectConfigurationApi {
  final TapToPayDiscoveryConfigurationApi discoveryConfiguration;
  final TapToPayConnectionConfigurationApi connectionConfiguration;

  const TapToPayEasyConnectConfigurationApi({
    required this.discoveryConfiguration,
    required this.connectionConfiguration,
  });
}

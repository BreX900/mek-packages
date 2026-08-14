import 'package:mek_stripe_terminal/src/models/connection_configuration.dart';
import 'package:mek_stripe_terminal/src/models/discovery_configuration.dart';

/// Configuration for the EasyConnect flow, which discovers and connects to a reader in one step.
sealed class EasyConnectConfiguration {
  const EasyConnectConfiguration();
}

class InternetEasyConnectConfiguration extends EasyConnectConfiguration {
  final InternetDiscoveryConfiguration discoveryConfiguration;
  final InternetConnectionConfiguration connectionConfiguration;

  const InternetEasyConnectConfiguration({
    required this.discoveryConfiguration,
    required this.connectionConfiguration,
  });
}

class AppsOnDevicesEasyConnectionConfiguration extends EasyConnectConfiguration {
  final AppsOnDevicesDiscoveryConfiguration discoveryConfiguration;
  final AppsOnDevicesConnectionConfiguration connectionConfiguration;

  const AppsOnDevicesEasyConnectionConfiguration({
    required this.discoveryConfiguration,
    required this.connectionConfiguration,
  });
}

class TapToPayEasyConnectConfiguration extends EasyConnectConfiguration {
  final TapToPayDiscoveryConfiguration discoveryConfiguration;
  final TapToPayConnectionConfiguration connectionConfiguration;

  const TapToPayEasyConnectConfiguration({
    required this.discoveryConfiguration,
    required this.connectionConfiguration,
  });
}

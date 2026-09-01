sealed class ConnectionConfigurationApi {
  const ConnectionConfigurationApi();
}

class BluetoothConnectionConfigurationApi extends ConnectionConfigurationApi {
  final String locationId;
  final bool autoReconnectOnUnexpectedDisconnect;

  const BluetoothConnectionConfigurationApi({
    required this.locationId,
    this.autoReconnectOnUnexpectedDisconnect = true,
  });
}

class AppsOnDevicesConnectionConfigurationApi extends ConnectionConfigurationApi {
  const AppsOnDevicesConnectionConfigurationApi();
}

class InternetConnectionConfigurationApi extends ConnectionConfigurationApi {
  final bool failIfInUse;

  /// Only available on iOS
  final bool allowCustomerCancel;

  const InternetConnectionConfigurationApi({
    this.failIfInUse = true,
    this.allowCustomerCancel = false,
  });
}

class TapToPayConnectionConfigurationApi extends ConnectionConfigurationApi {
  final String locationId;
  final bool autoReconnectOnUnexpectedDisconnect;

  /// Only available on iOS
  final String? onBehalfOf;

  /// Only available on iOS
  final String? merchantDisplayName;

  /// Only available on iOS
  final bool tosAcceptancePermitted;

  /// Only available on iOS
  final bool returnReadResultImmediatelyEnabled;

  const TapToPayConnectionConfigurationApi({
    required this.locationId,
    this.autoReconnectOnUnexpectedDisconnect = true,
    this.onBehalfOf,
    this.merchantDisplayName,
    this.tosAcceptancePermitted = true,
    this.returnReadResultImmediatelyEnabled = true,
  });
}

class UsbConnectionConfigurationApi extends ConnectionConfigurationApi {
  final String locationId;
  final bool autoReconnectOnUnexpectedDisconnect;

  const UsbConnectionConfigurationApi({
    required this.locationId,
    this.autoReconnectOnUnexpectedDisconnect = true,
  });
}

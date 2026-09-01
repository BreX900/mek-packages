import 'package:mek_stripe_terminal/src/api/terminal_api.g.dart';
import 'package:mek_stripe_terminal/src/reader_delegates.dart';

sealed class ConnectionConfiguration {
  ReaderDelegateAbstract get readerDelegate;
}

class BluetoothConnectionConfiguration extends BluetoothConnectionConfigurationApi
    implements ConnectionConfiguration {
  @override
  final MobileReaderDelegate readerDelegate;

  BluetoothConnectionConfiguration({
    required super.locationId,
    super.autoReconnectOnUnexpectedDisconnect = true,
    required this.readerDelegate,
  });
}

class AppsOnDevicesConnectionConfiguration extends AppsOnDevicesConnectionConfigurationApi
    implements ConnectionConfiguration {
  @override
  final AppsOnDevicesReaderDelegate readerDelegate;

  AppsOnDevicesConnectionConfiguration({required this.readerDelegate});
}

class InternetConnectionConfiguration extends InternetConnectionConfigurationApi
    implements ConnectionConfiguration {
  @override
  final InternetReaderDelegate readerDelegate;

  InternetConnectionConfiguration({
    super.failIfInUse = true,
    super.allowCustomerCancel = false,
    required this.readerDelegate,
  });
}

class TapToPayConnectionConfiguration extends TapToPayConnectionConfigurationApi
    implements ConnectionConfiguration {
  @override
  final TapToPayReaderDelegate readerDelegate;

  TapToPayConnectionConfiguration({
    required super.locationId,
    super.autoReconnectOnUnexpectedDisconnect = true,
    super.onBehalfOf,
    super.merchantDisplayName,
    super.tosAcceptancePermitted = true,
    super.returnReadResultImmediatelyEnabled = true,
    required this.readerDelegate,
  });
}

class UsbConnectionConfiguration extends UsbConnectionConfigurationApi
    implements ConnectionConfiguration {
  @override
  final MobileReaderDelegate readerDelegate;

  UsbConnectionConfiguration({
    required super.locationId,
    super.autoReconnectOnUnexpectedDisconnect = true,
    required this.readerDelegate,
  });
}

import 'package:mek_stripe_terminal/src/reader_delegates.dart';
import 'package:one_for_all/one_for_all.dart';

sealed class ConnectionConfiguration {
  const ConnectionConfiguration();

  ReaderDelegateAbstract? get readerDelegate => null;
}

class BluetoothConnectionConfiguration extends ConnectionConfiguration {
  final String locationId;
  final bool autoReconnectOnUnexpectedDisconnect;
  @override
  @SerializableParam.ignore()
  final MobileReaderDelegate readerDelegate;

  const BluetoothConnectionConfiguration({
    required this.locationId,
    this.autoReconnectOnUnexpectedDisconnect = true,
    required this.readerDelegate,
  });
}

class HandoffConnectionConfiguration extends ConnectionConfiguration {
  @override
  @SerializableParam.ignore()
  final HandoffReaderDelegate? readerDelegate;

  const HandoffConnectionConfiguration({
    required this.readerDelegate,
  });
}

class InternetConnectionConfiguration extends ConnectionConfiguration {
  final bool failIfInUse;

  /// Only available on iOS
  final bool allowCustomerCancel;

  @override
  @SerializableParam.ignore()
  final InternetReaderDelegate? readerDelegate;

  const InternetConnectionConfiguration({
    this.failIfInUse = true,
    this.allowCustomerCancel = false,
    required this.readerDelegate,
  });
}

class TapToPayConnectionConfiguration extends ConnectionConfiguration {
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

  @override
  @SerializableParam.ignore()
  final TapToPayReaderDelegate? readerDelegate;

  const TapToPayConnectionConfiguration({
    required this.locationId,
    this.autoReconnectOnUnexpectedDisconnect = true,
    this.onBehalfOf,
    this.merchantDisplayName,
    this.tosAcceptancePermitted = true,
    this.returnReadResultImmediatelyEnabled = true,
    required this.readerDelegate,
  });
}

class UsbConnectionConfiguration extends ConnectionConfiguration {
  final String locationId;
  final bool autoReconnectOnUnexpectedDisconnect;
  @override
  @SerializableParam.ignore()
  final MobileReaderDelegate? readerDelegate;

  const UsbConnectionConfiguration({
    required this.locationId,
    this.autoReconnectOnUnexpectedDisconnect = true,
    required this.readerDelegate,
  });
}

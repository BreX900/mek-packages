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
  @override
  @SerializableParam.ignore()
  final InternetReaderDelegate? readerDelegate;

  const InternetConnectionConfiguration({
    this.failIfInUse = true,
    required this.readerDelegate,
  });
}

class TapToPayConnectionConfiguration extends ConnectionConfiguration {
  final String locationId;
  final bool autoReconnectOnUnexpectedDisconnect;
  @override
  @SerializableParam.ignore()
  final TapToPayReaderDelegate? readerDelegate;

  const TapToPayConnectionConfiguration({
    required this.locationId,
    this.autoReconnectOnUnexpectedDisconnect = true,
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

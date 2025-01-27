import 'dart:async';

import 'package:mek_stripe_terminal/src/models/disconnect_reason.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/reader_software_update.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';

typedef Cancellable = Future<void> Function();

mixin class ReaderDelegate {
  FutureOr<void> onReportReaderEvent(ReaderEvent event) {}
}

mixin class PhysicalReaderDelegate implements ReaderDelegate {
  @override
  FutureOr<void> onReportReaderEvent(ReaderEvent event) {}

  FutureOr<void> onRequestReaderDisplayMessage(ReaderDisplayMessage message) {}

  FutureOr<void> onRequestReaderInput(List<ReaderInputOption> options) {}

  FutureOr<void> onReportBatteryLevelUpdate(
    double batteryLevel,
    BatteryStatus? batteryStatus,
    // ignore: avoid_positional_boolean_parameters
    bool isCharging,
  ) {}

  FutureOr<void> onReportLowBatteryWarning() {}

  FutureOr<void> onReportAvailableUpdate(ReaderSoftwareUpdate update) {}

  FutureOr<void> onStartInstallingUpdate(ReaderSoftwareUpdate update, Cancellable cancelUpdate) {}

  FutureOr<void> onReportReaderSoftwareUpdateProgress(double progress) {}

  FutureOr<void> onFinishInstallingUpdate(
    ReaderSoftwareUpdate? update,
    TerminalException? exception,
  ) {}

  FutureOr<void> onDisconnect(DisconnectReason reason) {}

  /// Available only for tap to pay on ios device
  FutureOr<void> onAcceptTermsOfService() {}
}

abstract mixin class ReaderReconnectionDelegate {
  FutureOr<void> onReaderReconnectFailed(Reader reader);

  @Deprecated('In favour of onReaderReconnectStarted2. Removed in next major.')
  FutureOr<void> onReaderReconnectStarted(Reader reader, Cancellable cancelReconnect) {}

  FutureOr<void> onReaderReconnectStarted2(
    Reader reader,
    Cancellable cancelReconnect,
    DisconnectReason reason,
  ) {
    // ignore: deprecated_member_use_from_same_package
    return onReaderReconnectStarted(reader, cancelReconnect);
  }

  FutureOr<void> onReaderReconnectSucceeded(Reader reader);
}

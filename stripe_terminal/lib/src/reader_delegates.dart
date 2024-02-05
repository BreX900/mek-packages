import 'dart:async';

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
}

abstract interface class ReaderReconnectionDelegate {
  FutureOr<void> onReaderReconnectFailed(Reader reader);

  FutureOr<void> onReaderReconnectStarted(Reader reader, Cancellable cancelReconnect);

  FutureOr<void> onReaderReconnectSucceeded(Reader reader);
}

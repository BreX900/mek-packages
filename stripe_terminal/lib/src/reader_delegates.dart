import 'dart:async';

import 'package:mek_stripe_terminal/src/models/reader_software_update.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';

typedef Cancellable = Future<void> Function();

abstract class ReaderDelegate {
  FutureOr<void> onReportAvailableUpdate(ReaderSoftwareUpdate update);

  FutureOr<void> onStartInstallingUpdate(ReaderSoftwareUpdate update, Cancellable cancelUpdate);

  FutureOr<void> onReportReaderSoftwareUpdateProgress(double progress);

  FutureOr<void> onFinishInstallingUpdate(
    ReaderSoftwareUpdate? update,
    TerminalException? exception,
  );
}

abstract class ReaderReconnectionDelegate {
  FutureOr<void> onReaderReconnectFailed();

  FutureOr<void> onReaderReconnectStarted(Cancellable cancelReconnect);

  FutureOr<void> onReaderReconnectSucceeded();
}

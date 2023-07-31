import 'dart:async';

import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/reader_software_update.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';

typedef Cancellable = Future<void> Function();

sealed class ReaderDelegate {
  FutureOr<void> onReportReaderEvent(ReaderEvent event) {}
}

sealed class PhysicalReaderDelegate extends ReaderDelegate {
  FutureOr<void> onRequestReaderDisplayMessage(ReaderDisplayMessage message) {}

  FutureOr<void> onRequestReaderInput(List<ReaderInputOption> options) {}

  FutureOr<void> onReportBatteryLevelUpdate(
    double batteryLevel,
    BatteryStatus? batteryStatus,
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

class HandoffReaderDelegate extends ReaderDelegate {}

class LocalMobileReaderDelegate extends PhysicalReaderDelegate {}

class BluetoothReaderDelegate extends PhysicalReaderDelegate {}

class UsbReaderDelegate extends PhysicalReaderDelegate {}

abstract class ReaderReconnectionDelegate {
  FutureOr<void> onReaderReconnectFailed();

  FutureOr<void> onReaderReconnectStarted(Cancellable cancelReconnect);

  FutureOr<void> onReaderReconnectSucceeded();
}

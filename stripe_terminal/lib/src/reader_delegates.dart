import 'dart:async';

import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/reader_software_update.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';

typedef Cancellable = Future<void> Function();

sealed class ReaderDelegate {
  FutureOr<void> Function(ReaderEvent event)? onReportReaderEventFn;
  
  FutureOr<void> onReportReaderEvent(ReaderEvent event) {
    if (onReportReaderEventFn != null) {
      return onReportReaderEventFn!(event);
    }
  }
}

sealed class PhysicalReaderDelegate extends ReaderDelegate {
  FutureOr<void> Function(ReaderDisplayMessage message)? onRequestReaderDisplayMessageFn;
  FutureOr<void> Function(List<ReaderInputOption> options)? onRequestReaderInputFn;
  FutureOr<void> Function(double batteryLevel, BatteryStatus? batteryStatus, bool isCharging)? onReportBatteryLevelUpdateFn;
  FutureOr<void> Function()? onReportLowBatteryWarningFn;
  FutureOr<void> Function(ReaderSoftwareUpdate update)? onReportAvailableUpdateFn;
  FutureOr<void> Function(ReaderSoftwareUpdate update, Cancellable cancelUpdate)? onStartInstallingUpdateFn;
  FutureOr<void> Function(double progress)? onReportReaderSoftwareUpdateProgressFn;
  FutureOr<void> Function(ReaderSoftwareUpdate? update, TerminalException? exception)? onFinishInstallingUpdateFn;

  FutureOr<void> onRequestReaderDisplayMessage(ReaderDisplayMessage message) {
    if (onRequestReaderDisplayMessageFn != null) {
      return onRequestReaderDisplayMessageFn!(message);
    }
  }

  FutureOr<void> onRequestReaderInput(List<ReaderInputOption> options) {
    if (onRequestReaderInputFn != null) {
      return onRequestReaderInputFn!(options);
    }
  }

  FutureOr<void> onReportBatteryLevelUpdate(double batteryLevel, BatteryStatus? batteryStatus, bool isCharging) {
    if (onReportBatteryLevelUpdateFn != null) {
      return onReportBatteryLevelUpdateFn!(batteryLevel, batteryStatus, isCharging);
    }
  }

  FutureOr<void> onReportLowBatteryWarning() {
    if (onReportLowBatteryWarningFn != null) {
      return onReportLowBatteryWarningFn!();
    }
  }

  FutureOr<void> onReportAvailableUpdate(ReaderSoftwareUpdate update) {
    if (onReportAvailableUpdateFn != null) {
      return onReportAvailableUpdateFn!(update);
    }
  }

  FutureOr<void> onStartInstallingUpdate(ReaderSoftwareUpdate update, Cancellable cancelUpdate) {
    if (onStartInstallingUpdateFn != null) {
      return onStartInstallingUpdateFn!(update, cancelUpdate);
    }
  }

  FutureOr<void> onReportReaderSoftwareUpdateProgress(double progress) {
    if (onReportReaderSoftwareUpdateProgressFn != null) {
      return onReportReaderSoftwareUpdateProgressFn!(progress);
    }
  }

  FutureOr<void> onFinishInstallingUpdate(ReaderSoftwareUpdate? update, TerminalException? exception) {
    if (onFinishInstallingUpdateFn != null) {
      return onFinishInstallingUpdateFn!(update, exception);
    }
  }
}

class HandoffReaderDelegate extends ReaderDelegate {}

class LocalMobileReaderDelegate extends PhysicalReaderDelegate {}

class BluetoothReaderDelegate extends PhysicalReaderDelegate {}

class UsbReaderDelegate extends PhysicalReaderDelegate {}

abstract class ReaderReconnectionDelegate {
  FutureOr<void> onReaderReconnectFailed(Reader reader);

  FutureOr<void> onReaderReconnectStarted(Reader reader, Cancellable cancelReconnect);

  FutureOr<void> onReaderReconnectSucceeded(Reader reader);
}

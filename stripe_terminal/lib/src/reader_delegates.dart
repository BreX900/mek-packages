import 'dart:async';

import 'package:mek_stripe_terminal/src/models/disconnect_reason.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/reader_software_update.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';

typedef Cancellable = Future<void> Function();

sealed class ReaderDelegateAbstract {}

mixin ReaderDelegate {
  void onReportReaderEvent(ReaderEvent event) {}
}

mixin ReaderReconnectionDelegate {
  void onReaderReconnectFailed(Reader reader) {}

  void onReaderReconnectStarted(
    Reader reader,
    Cancellable cancelReconnect,
    DisconnectReason reason,
  ) {}

  void onReaderReconnectSucceeded(Reader reader) {}
}

mixin ReaderDisconnectDelegate {
  void onDisconnect(DisconnectReason reason) {}
}

class MobileReaderDelegate extends ReaderDelegateAbstract
    with ReaderDelegate, ReaderReconnectionDelegate, ReaderDisconnectDelegate {
  // ignore: avoid_positional_boolean_parameters
  void onBatteryLevelUpdate(double batteryLevel, BatteryStatus? batteryStatus, bool isCharging) {}

  void onReportLowBatteryWarning() {}

  void onReportAvailableUpdate(ReaderSoftwareUpdate update) {}

  void onStartInstallingUpdate(ReaderSoftwareUpdate update, Cancellable cancelUpdate) {}

  void onReportReaderSoftwareUpdateProgress(double progress) {}

  void onFinishInstallingUpdate(ReaderSoftwareUpdate? update, TerminalException? exception) {}

  void onRequestReaderDisplayMessage(ReaderDisplayMessage message) {}

  void onRequestReaderInput(List<ReaderInputOption> options) {}
}

class HandoffReaderDelegate extends ReaderDelegateAbstract
    with ReaderDelegate, ReaderDisconnectDelegate {}

class InternetReaderDelegate extends ReaderDelegateAbstract with ReaderDisconnectDelegate {}

class TapToPayReaderDelegate extends ReaderDelegateAbstract
    with ReaderReconnectionDelegate, ReaderDisconnectDelegate {}

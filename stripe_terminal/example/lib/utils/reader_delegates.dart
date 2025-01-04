import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

typedef LogListener = void Function(String text);

mixin _LoggingReaderDelegate on ReaderDelegate {
  LogListener get onLog;

  @override
  void onReportReaderEvent(ReaderEvent event) => onLog('onReportReaderEvent: $event');
}

mixin _LoggingReaderReconnectionDelegate on ReaderReconnectionDelegate {
  LogListener get onLog;

  @override
  void onReaderReconnectFailed(Reader reader) => onLog('onReaderReconnectFailed: ${reader.label}');

  @override
  void onReaderReconnectStarted(
    Reader reader,
    Cancellable cancelReconnect,
    DisconnectReason reason,
  ) {
    onLog('onReaderReconnectStarted: ${reader.label}');
  }

  @override
  void onReaderReconnectSucceeded(Reader reader) =>
      onLog('onReaderReconnectSucceeded: ${reader.label}');
}

mixin _LoggingReaderDisconnectDelegate on ReaderDisconnectDelegate {
  LogListener get onLog;

  @override
  void onDisconnect(DisconnectReason reason) => onLog('onDisconnect: $reason');
}

mixin _LoggingReaderPortableDelegate on ReaderPortableDelegate {
  LogListener get onLog;

  @override
  void onStartInstallingUpdate(ReaderSoftwareUpdate update, Cancellable cancelUpdate) =>
      onLog('onStartInstallingUpdate: ${update.version}');

  @override
  void onReportReaderSoftwareUpdateProgress(double progress) =>
      onLog('onReportReaderSoftwareUpdateProgress: $progress');

  @override
  void onFinishInstallingUpdate(ReaderSoftwareUpdate? update, TerminalException? exception) =>
      onLog('onFinishInstallingUpdate: ${update?.version} ${exception?.code}');

  @override
  void onRequestReaderDisplayMessage(ReaderDisplayMessage message) =>
      onLog('onRequestReaderDisplayMessage: ${message.name}');

  @override
  void onRequestReaderInput(List<ReaderInputOption> options) =>
      onLog('onRequestReaderInput: $ReaderInputOption(${options.map((e) => e.name).join(',')})');
}

class LoggingMobileReaderDelegate extends MobileReaderDelegate
    with
        _LoggingReaderDelegate,
        _LoggingReaderReconnectionDelegate,
        _LoggingReaderDisconnectDelegate,
        _LoggingReaderPortableDelegate {
  @override
  final LogListener onLog;

  LoggingMobileReaderDelegate(this.onLog);

  @override
  void onBatteryLevelUpdate(double batteryLevel, BatteryStatus? batteryStatus, bool isCharging) {
    onLog(
        'onBatteryLevelUpdate: batteryLevel: $batteryLevel $batteryStatus isCharging: $isCharging');
  }

  @override
  void onReportLowBatteryWarning() => onLog('onReportLowBatteryWarning');

  @override
  void onReportAvailableUpdate(ReaderSoftwareUpdate update) =>
      onLog('onReportAvailableUpdate: ${update.version}');
}

class LoggingHandoffReaderDelegate extends HandoffReaderDelegate
    with _LoggingReaderDelegate, _LoggingReaderDisconnectDelegate {
  @override
  final LogListener onLog;

  LoggingHandoffReaderDelegate(this.onLog);
}

class LoggingInternetReaderDelegate extends InternetReaderDelegate
    with _LoggingReaderDisconnectDelegate {
  @override
  final LogListener onLog;

  LoggingInternetReaderDelegate(this.onLog);
}

class LoggingTapToPayReaderDelegate extends TapToPayReaderDelegate
    with
        _LoggingReaderReconnectionDelegate,
        _LoggingReaderDisconnectDelegate,
        _LoggingReaderPortableDelegate {
  @override
  final LogListener onLog;

  LoggingTapToPayReaderDelegate(this.onLog);

  @override
  void onAcceptTermsOfService() => onLog('onAcceptTermsOfService');
}

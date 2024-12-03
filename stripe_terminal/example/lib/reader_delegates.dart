import 'package:example/main.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

mixin _SnackBarReaderDelegate on ReaderDelegate {
  @override
  void onReportReaderEvent(ReaderEvent event) {
    _showSnackBar('onReportReaderEvent: $event');
  }

  void _showSnackBar(String message);
}

mixin _SnackBarReaderReconnectionDelegate on ReaderReconnectionDelegate {
  @override
  void onReaderReconnectFailed(Reader reader) {
    _showSnackBar('onReaderReconnectFailed: ${reader.label}');
  }

  @override
  void onReaderReconnectStarted(
    Reader reader,
    Cancellable cancelReconnect,
    DisconnectReason reason,
  ) {
    _showSnackBar('onReaderReconnectStarted: ${reader.label}');
  }

  @override
  void onReaderReconnectSucceeded(Reader reader) {
    _showSnackBar('onReaderReconnectSucceeded: ${reader.label}');
  }

  void _showSnackBar(String message);
}

mixin _SnackBarReaderDisconnectDelegate on ReaderDisconnectDelegate {
  @override
  void onDisconnect(reason) {
    _showSnackBar('onDisconnect: $reason');
  }

  void _showSnackBar(String message);
}

class HomeScreenMobileReaderDelegate extends MobileReaderDelegate
    with
        _SnackBarReaderDelegate,
        _SnackBarReaderReconnectionDelegate,
        _SnackBarReaderDisconnectDelegate {
  final HomeScreenState state;

  HomeScreenMobileReaderDelegate(this.state);

  @override
  void onBatteryLevelUpdate(double batteryLevel, BatteryStatus? batteryStatus, bool isCharging) {
    _showSnackBar('onBatteryLevelUpdate: $batteryLevel $batteryStatus $isCharging');
  }

  @override
  void onReportLowBatteryWarning() {
    _showSnackBar('onReportLowBatteryWarning');
  }

  @override
  void onReportAvailableUpdate(ReaderSoftwareUpdate update) {
    _showSnackBar('onReportAvailableUpdate: ${update.version}');
  }

  @override
  void onStartInstallingUpdate(ReaderSoftwareUpdate update, Cancellable cancelUpdate) {
    _showSnackBar('onStartInstallingUpdate: ${update.version}');
  }

  @override
  void onReportReaderSoftwareUpdateProgress(double progress) {
    _showSnackBar('onReportReaderSoftwareUpdateProgress: $progress');
  }

  @override
  void onFinishInstallingUpdate(ReaderSoftwareUpdate? update, TerminalException? exception) {
    _showSnackBar('onFinishInstallingUpdate: ${update?.version} ${exception?.code}');
  }

  @override
  void onRequestReaderDisplayMessage(ReaderDisplayMessage message) {
    _showSnackBar('onRequestReaderDisplayMessage: $message');
  }

  @override
  void onRequestReaderInput(List<ReaderInputOption> options) {
    // TODO: Show a dialog
    _showSnackBar('onRequestReaderInput: ${options.length}');
  }

  @override
  void _showSnackBar(String message) => state.showSnackBar(message);
}

class HomeScreenHandoffReaderDelegate extends HandoffReaderDelegate
    with _SnackBarReaderDelegate, _SnackBarReaderDisconnectDelegate {
  final HomeScreenState state;

  HomeScreenHandoffReaderDelegate(this.state);

  @override
  void _showSnackBar(String message) => state.showSnackBar(message);
}

class HomeScreenInternetReaderDelegate extends InternetReaderDelegate
    with _SnackBarReaderDisconnectDelegate {
  final HomeScreenState state;

  HomeScreenInternetReaderDelegate(this.state);

  @override
  void _showSnackBar(String message) => state.showSnackBar(message);
}

class HomeScreenTapToPayReaderDelegate extends TapToPayReaderDelegate
    with _SnackBarReaderReconnectionDelegate, _SnackBarReaderDisconnectDelegate {
  final HomeScreenState state;

  HomeScreenTapToPayReaderDelegate(this.state);

  @override
  void _showSnackBar(String message) => state.showSnackBar(message);
}

import 'dart:async';

import 'package:mek_stripe_terminal/src/api/terminal_api.g.dart';
import 'package:mek_stripe_terminal/src/models/disconnect_reason.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/reader_software_update.dart';
import 'package:mek_stripe_terminal/src/reader_delegates.dart';
import 'package:mek_stripe_terminal/src/terminal.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';

class TerminalHandlers implements TerminalHandlersApi {
  final TerminalPlatformApi _platform;
  Future<String> Function()? fetchToken;

  final _connectionStatusChangeController = StreamController<ConnectionStatus>.broadcast();
  final _paymentStatusChangeController = StreamController<PaymentStatus>.broadcast();

  ReaderDelegateAbstract? _readerDelegate;

  Stream<ConnectionStatus> get connectionStatusChangeStream =>
      _connectionStatusChangeController.stream;
  Stream<PaymentStatus> get paymentStatusChangeStream => _paymentStatusChangeController.stream;

  TerminalHandlers(this._platform) {
    TerminalHandlersApi.setUp(this);
  }

  Future<R> handleReaderConnection<R>(
    ReaderDelegateAbstract? delegate,
    Future<R> Function() body,
  ) async {
    _readerDelegate = delegate;
    try {
      return await body();
    } catch (_) {
      _readerDelegate = null;
      rethrow;
    }
  }

  void handleReaderDisconnection() {
    _readerDelegate = null;
  }

  @override
  Future<String> requestConnectionToken() async => await fetchToken!();

  @override
  void connectionStatusChange(ConnectionStatus connectionStatus) =>
      _connectionStatusChangeController.add(connectionStatus);

  @override
  void paymentStatusChange(PaymentStatus paymentStatus) =>
      _paymentStatusChangeController.add(paymentStatus);

  //region ReaderDelegate
  @override
  void readerReportEvent(ReaderEvent event) {
    _runInZone<ReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onReportReaderEvent(event);
    });
  }
  //endregion

  //region ReaderReconnectionDelegate
  @override
  void readerReconnectFailed(Reader reader) {
    _runInZone<ReaderReconnectionDelegate>(_readerDelegate, (delegate) {
      delegate.onReaderReconnectFailed(reader);
    });
  }

  @override
  void readerReconnectStarted(Reader reader, DisconnectReason reason) {
    _runInZone<ReaderReconnectionDelegate>(_readerDelegate, (delegate) {
      delegate.onReaderReconnectStarted(reader, _platform.cancelReaderReconnection, reason);
    });
  }

  @override
  void readerReconnectSucceeded(Reader reader) {
    _runInZone<ReaderReconnectionDelegate>(_readerDelegate, (delegate) {
      delegate.onReaderReconnectSucceeded(reader);
    });
  }
  //endregion

  //region ReaderDisconnectDelegate
  @override
  void disconnect(DisconnectReason reason) {
    _runInZone<ReaderDisconnectDelegate>(_readerDelegate, (delegate) {
      delegate.onDisconnect(reason);
    });
  }
  //endregion

  //region ReaderPortableDelegate
  @override
  void readerStartInstallingUpdate(ReaderSoftwareUpdate update) {
    _runInZone<ReaderPortableDelegate>(_readerDelegate, (delegate) {
      delegate.onStartInstallingUpdate(update, _platform.cancelReaderUpdate);
    });
  }

  @override
  void readerReportSoftwareUpdateProgress(double progress) {
    _runInZone<ReaderPortableDelegate>(_readerDelegate, (delegate) {
      delegate.onReportReaderSoftwareUpdateProgress(progress);
    });
  }

  @override
  void readerFinishInstallingUpdate(ReaderSoftwareUpdate? update, TerminalExceptionApi? exception) {
    _runInZone<ReaderPortableDelegate>(_readerDelegate, (delegate) {
      delegate.onFinishInstallingUpdate(
        update,
        exception != null ? TerminalException.fromApi(exception) : null,
      );
    });
  }

  @override
  void readerRequestDisplayMessage(ReaderDisplayMessage message) {
    _runInZone<ReaderPortableDelegate>(_readerDelegate, (delegate) {
      delegate.onRequestReaderDisplayMessage(message);
    });
  }

  @override
  void readerRequestInput(List<ReaderInputOption> options) {
    _runInZone<ReaderPortableDelegate>(_readerDelegate, (delegate) {
      delegate.onRequestReaderInput(options);
    });
  }
  //endregion

  //region MobileReaderDelegate
  @override
  void readerBatteryLevelUpdate(
    double batteryLevel,
    BatteryStatus? batteryStatus,
    bool isCharging,
  ) {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onBatteryLevelUpdate(batteryLevel, batteryStatus, isCharging);
    });
  }

  @override
  void readerReportLowBatteryWarning() {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onReportLowBatteryWarning();
    });
  }

  @override
  void readerReportAvailableUpdate(ReaderSoftwareUpdate update) {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onReportAvailableUpdate(update);
    });
  }
  //endRegion

  //region TapToPayReaderDelegate
  @override
  void readerAcceptTermsOfService() {
    _runInZone<TapToPayReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onAcceptTermsOfService();
    });
  }
  //endRegion

  void _runInZone<T>(ReaderDelegateAbstract? delegate, void Function(T delegate) body) {
    if (delegate == null) return;
    if (delegate is! T) return;
    Zone.current.runUnary(body, delegate as T);
  }

  //endregion
}

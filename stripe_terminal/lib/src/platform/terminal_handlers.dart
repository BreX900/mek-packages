part of 'terminal_platform.dart';

@FlutterApi()
class TerminalHandlers {
  final TerminalPlatform _platform;
  Future<String> Function()? fetchToken;

  final _connectionStatusChangeController = StreamController<ConnectionStatus>.broadcast();
  final _paymentStatusChangeController = StreamController<PaymentStatus>.broadcast();

  ReaderDelegateAbstract? _readerDelegate;

  Stream<ConnectionStatus> get connectionStatusChangeStream =>
      _connectionStatusChangeController.stream;
  Stream<PaymentStatus> get paymentStatusChangeStream => _paymentStatusChangeController.stream;

  TerminalHandlers(this._platform) {
    _$setupTerminalHandlers(this);
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

  @MethodApi(kotlin: MethodApiType.callbacks, swift: MethodApiType.async)
  Future<String> _onRequestConnectionToken() async => await fetchToken!();

  void _onConnectionStatusChange(ConnectionStatus connectionStatus) =>
      _connectionStatusChangeController.add(connectionStatus);

  void _onPaymentStatusChange(PaymentStatus paymentStatus) =>
      _paymentStatusChangeController.add(paymentStatus);

//region Reader delegate
  void _onReaderReportEvent(ReaderEvent event) {
    _runInZone<ReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onReportReaderEvent(event);
    });
  }

  void _onReaderReconnectFailed(Reader reader) {
    _runInZone<ReaderReconnectionDelegate>(_readerDelegate, (delegate) {
      delegate.onReaderReconnectFailed(reader);
    });
  }

  void _onReaderReconnectStarted(Reader reader, DisconnectReason reason) {
    _runInZone<ReaderReconnectionDelegate>(_readerDelegate, (delegate) {
      delegate.onReaderReconnectStarted(reader, _platform.cancelReaderReconnection, reason);
    });
  }

  void _onReaderReconnectSucceeded(Reader reader) {
    _runInZone<ReaderReconnectionDelegate>(_readerDelegate, (delegate) {
      delegate.onReaderReconnectSucceeded(reader);
    });
  }

  void _onDisconnect(DisconnectReason reason) {
    _runInZone<ReaderDisconnectDelegate>(_readerDelegate, (delegate) {
      delegate.onDisconnect(reason);
    });
  }

  void _onReaderRequestDisplayMessage(ReaderDisplayMessage message) {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onRequestReaderDisplayMessage(message);
    });
  }

  void _onReaderRequestInput(List<ReaderInputOption> options) {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onRequestReaderInput(options);
    });
  }

  void _onReaderBatteryLevelUpdate(
    double batteryLevel,
    BatteryStatus? batteryStatus,
    bool isCharging,
  ) {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onBatteryLevelUpdate(batteryLevel, batteryStatus, isCharging);
    });
  }

  void _onReaderReportLowBatteryWarning() {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onReportLowBatteryWarning();
    });
  }

  void _onReaderReportAvailableUpdate(ReaderSoftwareUpdate update) {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onReportAvailableUpdate(update);
    });
  }

  void _onReaderStartInstallingUpdate(ReaderSoftwareUpdate update) {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onStartInstallingUpdate(update, _platform.cancelReaderUpdate);
    });
  }

  void _onReaderReportSoftwareUpdateProgress(double progress) {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onReportReaderSoftwareUpdateProgress(progress);
    });
  }

  void _onReaderFinishInstallingUpdate(
    ReaderSoftwareUpdate? update,
    TerminalException? exception,
  ) {
    _runInZone<MobileReaderDelegate>(_readerDelegate, (delegate) {
      delegate.onFinishInstallingUpdate(update, exception);
    });
  }

  void _runInZone<T>(
    ReaderDelegateAbstract? delegate,
    void Function(T delegate) body,
  ) {
    if (delegate == null) return;
    if (delegate is! T) return;
    Zone.current.runUnary(body, delegate as T);
  }

//endregion
}

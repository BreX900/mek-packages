part of 'terminal_platform.dart';

@FlutterApi()
class TerminalHandlers {
  final TerminalPlatform _platform;
  final Future<String> Function() _fetchToken;

  final _unexpectedReaderDisconnectController = StreamController<Reader>.broadcast();
  final _connectionStatusChangeController = StreamController<ConnectionStatus>.broadcast();
  final _paymentStatusChangeController = StreamController<PaymentStatus>.broadcast();

  ReaderDelegate? _readerDelegate;
  ReaderReconnectionDelegate? _readerReconnectionDelegate;

  Stream<Reader> get unexpectedReaderDisconnectStream =>
      _unexpectedReaderDisconnectController.stream;
  Stream<ConnectionStatus> get connectionStatusChangeStream =>
      _connectionStatusChangeController.stream;
  Stream<PaymentStatus> get paymentStatusChangeStream => _paymentStatusChangeController.stream;

  TerminalHandlers({
    required TerminalPlatform platform,
    required Future<String> Function() fetchToken,
  })  : _platform = platform,
        _fetchToken = fetchToken {
    _$setupTerminalHandlers(this);
  }

  void attachReaderDelegates(
    ReaderDelegate? delegate,
    ReaderReconnectionDelegate? reconnectionDelegate,
  ) {
    _readerDelegate = delegate;
    _readerReconnectionDelegate = reconnectionDelegate;
  }

  void detachReaderDelegates() {
    _readerDelegate = null;
    _readerReconnectionDelegate = null;
  }

  @MethodApi(kotlin: MethodApiType.callbacks, swift: MethodApiType.async)
  Future<String> _onRequestConnectionToken() async => await _fetchToken();

  Future<void> _onUnexpectedReaderDisconnect(Reader reader) async =>
      _unexpectedReaderDisconnectController.add(reader);

  Future<void> _onConnectionStatusChange(ConnectionStatus connectionStatus) async =>
      _connectionStatusChangeController.add(connectionStatus);

  Future<void> _onPaymentStatusChange(PaymentStatus paymentStatus) async =>
      _paymentStatusChangeController.add(paymentStatus);

//region Reader delegate
  void _onReaderReportEvent(ReaderEvent event) {
    _runInZone(_readerDelegate, (delegate) async {
      await delegate.onReportReaderEvent(event);
    });
  }

  void _onReaderRequestDisplayMessage(ReaderDisplayMessage message) {
    _runInZone(_readerDelegate, (delegate) async {
      if (delegate is! PhysicalReaderDelegate) return;
      await delegate.onRequestReaderDisplayMessage(message);
    });
  }

  void _onReaderRequestInput(List<ReaderInputOption> options) {
    _runInZone(_readerDelegate, (delegate) async {
      if (delegate is! PhysicalReaderDelegate) return;
      await delegate.onRequestReaderInput(options);
    });
  }

  void _onReaderBatteryLevelUpdate(
    double batteryLevel,
    BatteryStatus? batteryStatus,
    bool isCharging,
  ) {
    _runInZone(_readerDelegate, (delegate) async {
      if (delegate is! PhysicalReaderDelegate) return;
      await delegate.onReportBatteryLevelUpdate(batteryLevel, batteryStatus, isCharging);
    });
  }

  void _onReaderReportLowBatteryWarning() {
    _runInZone(_readerDelegate, (delegate) async {
      if (delegate is! PhysicalReaderDelegate) return;
      await delegate.onReportLowBatteryWarning();
    });
  }

  void _onReaderReportAvailableUpdate(ReaderSoftwareUpdate update) {
    _runInZone(_readerDelegate, (delegate) async {
      if (delegate is! PhysicalReaderDelegate) return;
      await delegate.onReportAvailableUpdate(update);
    });
  }

  void _onReaderStartInstallingUpdate(ReaderSoftwareUpdate update) {
    _runInZone(_readerDelegate, (delegate) async {
      if (delegate is! PhysicalReaderDelegate) return;
      await delegate.onStartInstallingUpdate(update, _platform.cancelReaderUpdate);
    });
  }

  void _onReaderReportSoftwareUpdateProgress(double progress) {
    _runInZone(_readerDelegate, (delegate) async {
      if (delegate is! PhysicalReaderDelegate) return;
      await delegate.onReportReaderSoftwareUpdateProgress(progress);
    });
  }

  void _onReaderFinishInstallingUpdate(
    ReaderSoftwareUpdate? update,
    TerminalException? exception,
  ) {
    _runInZone(_readerDelegate, (delegate) async {
      if (delegate is! PhysicalReaderDelegate) return;
      await delegate.onFinishInstallingUpdate(update, exception);
    });
  }
//endregion

//region Reader reconnection delegate
  void _onReaderReconnectFailed(Reader reader) {
    _runInZone(_readerReconnectionDelegate, (delegate) async {
      await delegate.onReaderReconnectFailed(reader);
    });
  }

  void _onReaderReconnectStarted(Reader reader) {
    _runInZone(_readerReconnectionDelegate, (delegate) async {
      await delegate.onReaderReconnectStarted(reader, _platform.cancelReaderReconnection);
    });
  }

  void _onReaderReconnectSucceeded(Reader reader) {
    _runInZone(_readerReconnectionDelegate, (delegate) async {
      await delegate.onReaderReconnectSucceeded(reader);
    });
  }

  void _runInZone<T>(T? delegate, Future<void> Function(T delegate) body) {
    if (delegate == null) return;
    unawaited(Zone.current.runUnary(body, delegate));
  }
//endregion
}

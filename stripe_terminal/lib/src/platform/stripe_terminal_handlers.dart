part of 'stripe_terminal_platform.dart';

@FlutterApi()
class StripeTerminalHandlers {
  final StripeTerminalPlatform _platform;
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

  StripeTerminalHandlers({
    required StripeTerminalPlatform platform,
    required Future<String> Function() fetchToken,
  })  : _platform = platform,
        _fetchToken = fetchToken {
    _$setupStripeTerminalHandlers(this);
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

  void _onReaderReportAvailableUpdate(ReaderSoftwareUpdate update) {
    _runInZone(_readerDelegate, (delegate) async {
      await delegate.onReportAvailableUpdate(update);
    });
  }

  void _onReaderStartInstallingUpdate(ReaderSoftwareUpdate update) {
    _runInZone(_readerDelegate, (delegate) async {
      await delegate.onStartInstallingUpdate(update, _platform.cancelReaderUpdate);
    });
  }

  void _onReaderReportSoftwareUpdateProgress(double progress) {
    _runInZone(_readerDelegate, (delegate) async {
      await delegate.onReportReaderSoftwareUpdateProgress(progress);
    });
  }

  void _onReaderFinishInstallingUpdate(
    ReaderSoftwareUpdate? update,
    TerminalException? exception,
  ) {
    _runInZone(_readerDelegate, (delegate) async {
      await delegate.onFinishInstallingUpdate(update, exception);
    });
  }

  void _onReaderReconnectFailed() {
    _runInZone(_readerReconnectionDelegate, (delegate) async {
      await delegate.onReaderReconnectFailed();
    });
  }

  void _onReaderReconnectStarted() {
    _runInZone(_readerReconnectionDelegate, (delegate) async {
      await delegate.onReaderReconnectStarted(_platform.cancelReaderReconnection);
    });
  }

  void _onReaderReconnectSucceeded() {
    _runInZone(_readerReconnectionDelegate, (delegate) async {
      await delegate.onReaderReconnectSucceeded();
    });
  }

  void _runInZone<T>(T? delegate, Future<void> Function(T delegate) body) {
    if (delegate == null) return;
    unawaited(Zone.current.runUnary(body, delegate));
  }
}

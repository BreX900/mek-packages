part of 'stripe_terminal.dart';

@FlutterApi()
class StripeTerminalHandlers {
  final Future<String> Function() _fetchToken;

  final _unexpectedReaderDisconnectController = StreamController<StripeReader>.broadcast();
  final _connectionStatusChangeController = StreamController<ConnectionStatus>.broadcast();
  final _paymentStatusChangeController = StreamController<PaymentStatus>.broadcast();

  final _availableUpdateController = StreamController<bool>.broadcast();
  final _reportReaderSoftwareUpdateProgressController = StreamController<double>.broadcast();

  Stream<StripeReader> get unexpectedReaderDisconnectStream =>
      _unexpectedReaderDisconnectController.stream;
  Stream<ConnectionStatus> get connectionStatusChangeStream =>
      _connectionStatusChangeController.stream;
  Stream<PaymentStatus> get paymentStatusChangeStream => _paymentStatusChangeController.stream;

  Stream<bool> get availableUpdateStream => _availableUpdateController.stream;
  Stream<double> get reportReaderSoftwareUpdateProgressStream =>
      _reportReaderSoftwareUpdateProgressController.stream;

  StripeTerminalHandlers({
    required Future<String> Function() fetchToken,
  }) : _fetchToken = fetchToken;

  @MethodApi(kotlin: MethodApiType.callbacks, swift: MethodApiType.async)
  Future<String> _onRequestConnectionToken() async => await _fetchToken();

  Future<void> _onUnexpectedReaderDisconnect(StripeReader reader) async =>
      _unexpectedReaderDisconnectController.add(reader);

  Future<void> _onConnectionStatusChange(ConnectionStatus connectionStatus) async =>
      _connectionStatusChangeController.add(connectionStatus);

  Future<void> _onPaymentStatusChange(PaymentStatus paymentStatus) async =>
      _paymentStatusChangeController.add(paymentStatus);

  Future<void> _onAvailableUpdate(bool availableUpdate) async =>
      _availableUpdateController.add(availableUpdate);

  Future<void> _onReportReaderSoftwareUpdateProgress(double progress) async =>
      _reportReaderSoftwareUpdateProgressController.add(progress);
}

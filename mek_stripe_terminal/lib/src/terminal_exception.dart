import 'package:mek_stripe_terminal/src/api/terminal_api.g.dart';
import 'package:mek_stripe_terminal/src/models/payment_intent.dart';

typedef TerminalExceptionCode = TerminalExceptionCodeApi;

class TerminalException implements Exception {
  final TerminalExceptionCode code;
  final String message;
  final String? stackTrace;
  final PaymentIntent? paymentIntent;
  final Object? apiError;

  TerminalException({
    required this.code,
    required String message,
    required this.stackTrace,
    required this.paymentIntent,
    required this.apiError,
  }) : message = (message.isEmpty ? code.message : message) ?? '';

  factory TerminalException.fromApi(TerminalExceptionApi data) {
    return TerminalException(
      code: data.code,
      message: data.message,
      stackTrace: data.stackTrace,
      paymentIntent: data.paymentIntent,
      apiError: data.apiError,
    );
  }

  @override
  String toString() => [
    'TerminalException: ${code.name}',
    message,
    if (paymentIntent != null) paymentIntent,
    if (apiError != null) apiError,
    if (stackTrace != null) stackTrace,
  ].join('\n');
}

extension TerminalExceptionCodeUtils on TerminalExceptionCode {
  String? get message => switch (this) {
    .paymentIntentNotRecovered =>
      'Call this method with the [PaymentIntent] returned from the [StripeTerminal.createPaymentIntent] '
          'or [StripeTerminal.retrievePaymentIntent] methods.',
    .setupIntentNotRecovered =>
      'Call this method with the [SetupIntent] returned from the [StripeTerminal.createSetupIntent] '
          'or [StripeTerminal.retrieveSetupIntent] methods.',
    .readerNotRecovered =>
      'Call this method with the [Reader] returned from the [StripeTerminal.discoverReaders] method.',
    _ => null,
  };
}

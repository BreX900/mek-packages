import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'payment_intent.g.dart';

@DataClass()
class PaymentIntent with _$PaymentIntent {
  final String id;
  final double amount;
  final double amountCapturable;
  final double amountReceived;
  final String? application;
  final double? applicationFeeAmount;
  final String? captureMethod;
  final String? cancellationReason;
  final DateTime? canceledAt;
  final String? clientSecret;
  final String? confirmationMethod;
  final DateTime created;
  final String? currency;
  final String? customer;
  final String? description;
  final String? invoice;
  final Map<String, String> metadata;
  final String? onBehalfOf;
  final String? paymentMethodId;
  final PaymentIntentStatus? status;
  final String? review;
  final String? receiptEmail;
  final String? setupFutureUsage;
  final String? transferGroup;

  @internal
  const PaymentIntent({
    required this.id,
    required this.amount,
    required this.amountCapturable,
    required this.amountReceived,
    required this.created,
    required this.status,
    required this.applicationFeeAmount,
    this.metadata = const {},
    this.application,
    this.captureMethod,
    this.cancellationReason,
    this.canceledAt,
    this.clientSecret,
    this.confirmationMethod,
    this.currency,
    this.customer,
    this.description,
    this.invoice,
    this.onBehalfOf,
    this.paymentMethodId,
    this.review,
    this.receiptEmail,
    this.setupFutureUsage,
    this.transferGroup,
  });
}

enum PaymentIntentStatus {
  canceled,
  processing,
  requiresCapture,
  requiresConfirmation,
  requiresPaymentMethod,
  succeeded,
}

@DataClass()
class PaymentIntentParameters with _$PaymentIntentParameters {
  final int amount;
  final String currency;
  final CaptureMethod captureMethod;
  final List<PaymentMethodType> paymentMethodTypes;

  const PaymentIntentParameters({
    required this.amount,
    required this.currency,
    required this.captureMethod,
    required this.paymentMethodTypes,
  });
}

enum PaymentMethodType { cardPresent, card, interactPresent }

enum CaptureMethod { automatic, manual }

import 'package:mek_data_class/mek_data_class.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:meta/meta.dart';

part 'payment_intent.g.dart';

@DataClass()
class PaymentIntent with _$PaymentIntent {
  final String id;
  final DateTime created;
  final PaymentIntentStatus status;
  final double amount;
  final String captureMethod;
  final String currency;
  final Map<String, String> metadata;
  // TODO: charges, paymentMethod
  final String? paymentMethodId;
  final double? amountTip;
  final String? statementDescriptor;
  final String? statementDescriptorSuffix;

  /// Only on android

  final double? amountCapturable;
  final double? amountReceived;
  final String? application;
  final double? applicationFeeAmount;
  final String? cancellationReason;
  final DateTime? canceledAt;
  final String? clientSecret;
  final String? confirmationMethod;
  final String? customer;
  final String? description;
  final String? invoice;
  final String? onBehalfOf;
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
    required this.amountTip,
    required this.statementDescriptor,
    required this.statementDescriptorSuffix,
    this.metadata = const {},
    required this.application,
    required this.captureMethod,
    required this.cancellationReason,
    required this.canceledAt,
    required this.clientSecret,
    required this.confirmationMethod,
    required this.currency,
    required this.customer,
    required this.description,
    required this.invoice,
    required this.onBehalfOf,
    required this.paymentMethodId,
    required this.review,
    required this.receiptEmail,
    required this.setupFutureUsage,
    required this.transferGroup,
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

// TODO: https://github.com/BreX900/mek-packages/issues/11
@DataClass()
class PaymentIntentParameters with _$PaymentIntentParameters {
  final int amount;
  final String currency;
  final CaptureMethod captureMethod;
  final List<PaymentMethodType> paymentMethodTypes;

  final Map<String, String> metadata;
  final String? description;
  final String? statementDescriptor;
  final String? statementDescriptorSuffix;
  final String? receiptEmail;
  final String? customerId;
  final int? applicationFeeAmount;
  final String? transferDataDestination;
  final String? transferGroup;
  final String? onBehalfOf;
  final String? setupFutureUsage;

  final PaymentMethodOptionsParameters? paymentMethodOptionsParameters;

  PaymentIntentParameters({
    required this.amount,
    required this.currency,
    required this.captureMethod,
    required this.paymentMethodTypes,
    this.metadata = const {},
    this.description,
    this.statementDescriptor,
    this.statementDescriptorSuffix,
    this.receiptEmail,
    this.customerId,
    this.applicationFeeAmount,
    this.transferDataDestination,
    this.transferGroup,
    this.onBehalfOf,
    this.setupFutureUsage,
    this.paymentMethodOptionsParameters,
  });
}

enum PaymentMethodType { cardPresent, card, interactPresent }

enum CaptureMethod { automatic, manual }

@DataClass()
class PaymentMethodOptionsParameters with _$PaymentMethodOptionsParameters {
  final CardPresentParameters cardPresentParameters;

  const PaymentMethodOptionsParameters({
    required this.cardPresentParameters,
  });
}

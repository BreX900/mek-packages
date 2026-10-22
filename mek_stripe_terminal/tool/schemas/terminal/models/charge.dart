import 'refund.dart';

/// The possible statuses for a charge
enum ChargeStatusApi {
  /// The charge succeeded.
  succeeded,

  /// The charge pending.
  pending,

  /// The charge failed.
  failed,
}

/// An object representing a Stripe charge.
///
/// See https://stripe.com/docs/api#charges
class ChargeApi {
  /// The amount of the charge.
  final int amount;

  /// The currency of the charge.
  final String currency;

  /// The status of the charge.
  final ChargeStatusApi status;

  /// The payment method details associated with the charge.
  final PaymentMethodDetailsApi? paymentMethodDetails;

  /// A string describing the charge, displayed in the Stripe dashboard and in email receipts.
  final String? descriptionX;

  /// The unique identifier for the charge.
  final String id;

  /// Metadata associated with the charge.
  ///
  /// See https://stripe.com/docs/api#metadata
  final Map<String, String> metadata;

  /// Extra dynamic information about a Charge. This will appear concatenated with the
  /// statementDescriptor on your customer’s credit card’s statement.
  final String? statementDescriptorSuffix;

  /// The full statement descriptor that is displayed on your customer’s credit card’s statement,
  /// after the static statementDescriptor and dynamic statementDescriptorSuffix portions are combined.
  final String? calculatedStatementDescriptor;

  /// 6 digit authorization code for this charge.
  final String? authorizationCode;

  const ChargeApi({
    required this.amount,
    required this.currency,
    required this.status,
    required this.descriptionX,
    required this.paymentMethodDetails,
    required this.id,
    required this.metadata,
    required this.statementDescriptorSuffix,
    required this.calculatedStatementDescriptor,
    required this.authorizationCode,
  });
}

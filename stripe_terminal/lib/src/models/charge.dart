import 'package:mek_data_class/mek_data_class.dart';
import 'package:mek_stripe_terminal/src/models/refund.dart';
import 'package:meta/meta.dart';

part 'charge.g.dart';

/// The possible statuses for a charge
enum ChargeStatus {
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
@DataClass()
class Charge with _$Charge {
  /// The amount of the charge.
  final int amount;

  /// The currency of the charge.
  final String currency;

  /// The status of the charge.
  final ChargeStatus status;

  /// The payment method details associated with the charge.
  final PaymentMethodDetails? paymentMethodDetails;

  /// A string describing the charge, displayed in the Stripe dashboard and in email receipts.
  final String? description;

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

  @internal
  const Charge({
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    required this.paymentMethodDetails,
    required this.id,
    required this.metadata,
    required this.statementDescriptorSuffix,
    required this.calculatedStatementDescriptor,
    required this.authorizationCode,
  });
}

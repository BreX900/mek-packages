import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'setup_intent.g.dart';

/// A SetupIntent guides you through the process of setting up and saving a customer’s
/// payment credentials for future payments. For example, you could use a SetupIntent to set up and
/// save your customer’s card without immediately collecting a payment.
/// Later, you can use PaymentIntents to drive the payment flow.
@DataClass()
class SetupIntent with _$SetupIntent {
  /// The unique identifier for the intent.
  final String id;

  /// When the intent was created.
  final DateTime created;

  /// The identifier of a customer object to which the SetupIntent is attached, if applicable.
  final String? customerId;

  /// Set of key-value pairs attached to the object.
  final Map<String, String> metadata;

  /// An [SetupIntentUsage] value describing how the SetupIntent will be used. Defaults to off-session if not set.
  final SetupIntentUsage usage;

  /// The status of the intent.
  final SetupIntentStatus status;

  /// The most recent SetupAttempt for this SetupIntent
  final SetupAttempt? latestAttempt;

  @internal
  const SetupIntent({
    required this.id,
    required this.created,
    required this.customerId,
    required this.metadata,
    required this.usage,
    required this.status,
    required this.latestAttempt,
  });
}

/// The [SetupIntent] usage options tell Stripe how the payment method is intended to be used in the future.
/// Stripe will use the chosen option to pick the most frictionless flow for the customer.
enum SetupIntentUsage {
  /// An on-session usage indicates to Stripe that future payments will take place while the customer
  /// is actively in your checkout flow and able to authenticate the payment method.
  /// With the on-session option, you can postpone authenticating the card details
  /// until a future checkout to avoid upfront friction.
  onSession,

  /// An off-session usage indicates to Stripe that future payments will take place without
  /// the direct involvement of the customer. Creating an off-session [SetupIntent] might incur some
  /// initial friction from additional authentication steps, but can reduce customer intervention
  /// in later off-session payments.
  offSession
}

enum SetupIntentStatus {
  requiresPaymentMethod,
  requiresConfirmation,
  requiresAction,
  processing,
  succeeded,
  cancelled
}

/// A SetupAttempt describes one attempted confirmation of a SetupIntent, whether that confirmation
/// was successful or unsuccessful. You can use SetupAttempts to inspect details of a specific
/// attempt at setting up a payment method using a SetupIntent.
@DataClass()
class SetupAttempt with _$SetupAttempt {
  /// The unique identifier for the SetupAttempt.
  final String id;

  /// The ID of the Connect application that created the SetupIntent.
  final String? applicationId;

  /// Time at which the object was created.
  final DateTime created;

  /// ID of the Customer this SetupIntent belongs to, if one exists.
  final String? customerId;

  /// (Connect) The account (if any) for which the setup is intended.
  final String? onBehalfOf;

  /// ID of the payment method used with this SetupAttempt.
  final String? paymentMethodId;

  /// Details about the payment method at the time of SetupIntent confirmation.
  final SetupAttemptPaymentMethodDetails? paymentMethodDetails;

  /// ID of the SetupIntent that this attempt belongs to.
  final String setupIntentId;

  /// The status of this [SetupAttempt].
  final SetupAttemptStatus status;

  @internal
  const SetupAttempt({
    required this.id,
    required this.applicationId,
    required this.created,
    required this.customerId,
    required this.onBehalfOf,
    required this.paymentMethodId,
    required this.paymentMethodDetails,
    required this.setupIntentId,
    required this.status,
  });
}

/// Statuses for a [SetupAttempt]
enum SetupAttemptStatus {
  requiresConfirmation,
  requiresAction,
  processing,
  succeeded,
  failed,
  abandoned
}

/// Details about a PaymentMethod at a specific time. ex: at time of transaction for a SetupAttempt.
@DataClass()
class SetupAttemptPaymentMethodDetails with _$SetupAttemptPaymentMethodDetails {
  // TODO: Implement `type` field

  /// If this is a card present payment method (ie self.type == PaymentMethodTypeCardPresent),
  /// this contains additional information.
  final SetupAttemptCardPresentDetails? cardPresent;

  /// If this is a card present payment method (ie self.type == SCPPaymentMethodTypeInteracPresent),
  /// this contains additional information.
  final SetupAttemptCardPresentDetails? interacPresent;

  @internal
  const SetupAttemptPaymentMethodDetails({
    this.cardPresent,
    this.interacPresent,
  });
}

/// An object representing details from a transaction using a cardPresent payment method.
@DataClass()
class SetupAttemptCardPresentDetails with _$SetupAttemptCardPresentDetails {
  /// The Authorization Response Cryptogram (ARPC) from the issuer.
  final String emvAuthData;

  /// The ID of the Card PaymentMethod which was generated by this [SetupAttempt].
  final String generatedCard;

  const SetupAttemptCardPresentDetails({
    required this.emvAuthData,
    required this.generatedCard,
  });
}

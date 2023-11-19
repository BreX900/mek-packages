import 'package:mek_data_class/mek_data_class.dart';
import 'package:mek_stripe_terminal/src/models/card.dart';
import 'package:meta/meta.dart';

part 'payment_method.g.dart';

/// An enum representing the type of payment method being handled.
enum PaymentMethodType {
  /// A card present payment method.
  cardPresent,

  /// A card payment method.
  card,

  /// An Interac Present payment method.
  interactPresent
}

/// PaymentMethod objects represent your customer’s payment instruments. They can be used with
/// PaymentIntents to collect payments, or saved to Customer objects to store instrument details
/// for future payments.
@DataClass()
class PaymentMethod with _$PaymentMethod {
  /// The unique identifier for the PaymentMethod
  final String id;

  /// A CardDetails object containing more details about the payment method
  final CardDetails? card;

  /// Details about the card-present payment method
  final CardPresentDetails? cardPresent;

  /// Details about the interac-present payment method
  final CardPresentDetails? interacPresent;

  /// The Customer that this PaymentMethod is attached to, or nil.
  final String? customerId;

  /// Set of key-value pairs that you can attach to an object. This can be useful for storing
  /// additional information about the object in a structured format.
  final Map<String, String> metadata;

  @internal
  const PaymentMethod({
    required this.id,
    required this.card,
    required this.cardPresent,
    required this.interacPresent,
    required this.customerId,
    this.metadata = const <String, String>{},
  });
}

import 'package:mek_data_class/mek_data_class.dart';
import 'package:mek_stripe_terminal/src/models/location.dart';

part 'payment_method.g.dart';

@DataClass()
class PaymentMethod with _$PaymentMethod {
  final String id;
  // final BillingDetails billingDetails;
  final CardDetails? cardDetails;
  final String? customer;

  /// Only Android
  final bool livemode;
  final Map<String, String> metadata;
  // final String type;

  const PaymentMethod({
    required this.id,
    required this.metadata,
    // required this.billingDetails,
    required this.livemode,
    // required this.type,
    required this.cardDetails,
    required this.customer,
  });
}

@DataClass()
class BillingDetails with _$BillingDetails {
  final Address? address;
  final String? email;
  final String? name;
  final String? phone;

  const BillingDetails({
    required this.address,
    required this.email,
    required this.name,
    required this.phone,
  });
}

@DataClass()
class CardDetails with _$CardDetails {
  final CardBrand? brand;
  final String? country;
  final int expMonth;
  final int expYear;
  final String? fingerprint;
  final CardFundingType? funding;
  final String? last4;

  const CardDetails({
    required this.brand,
    required this.country,
    required this.expMonth,
    required this.expYear,
    required this.fingerprint,
    required this.funding,
    required this.last4,
  });
}

enum CardBrand {
  amex,
  dinersClub,
  discover,
  jcb,
  masterCard,
  unionPay,
  visa,

  /// Only iOS
  interac,

  /// Only iOS
  eftposAu;
}

enum CardFundingType { credit, debit, prepaid }

// class Networks {
//   final List<String> available;
//   final String? preferred;
//
//   const Networks({
//     required this.available,
//     required this.preferred,
//   });
// }

// class ThreeDSecureUsage {
//   final bool supported;
//
//   const ThreeDSecureUsage({
//     required this.supported,
//   });
// }

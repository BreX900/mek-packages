import 'package:mek_data_class/mek_data_class.dart';

part 'payment_method.g.dart';

@DataClass()
class StripePaymentMethod with _$StripePaymentMethod {
  final String id;
  // final BillingDetails billingDetails;
  final CardDetails? cardDetails;
  final String? customer;
  final bool livemode;
  final Map<String, String>? metadata;
  // final String type;

  const StripePaymentMethod({
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
class Address with _$Address {
  final String? city;
  final String? country;
  final String? line1;
  final String? line2;
  final String? postalCode;
  final String? state;

  const Address({
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.postalCode,
    required this.state,
  });
}

@DataClass()
class CardDetails with _$CardDetails {
  final String? brand;
  final String? country;
  final int expMonth;
  final int expYear;
  final String? fingerprint;
  final String? funding;
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

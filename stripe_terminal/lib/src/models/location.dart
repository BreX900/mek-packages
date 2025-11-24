import 'package:mek_data_class/mek_data_class.dart';

part 'location.g.dart';

@DataClass()
class Location with _$Location {
  final Address? address;
  final String? displayName;
  final String? id;
  final bool? livemode;
  final Map<String, String>? metadata;

  const Location({
    required this.address,
    required this.displayName,
    required this.id,
    required this.livemode,
    required this.metadata,
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

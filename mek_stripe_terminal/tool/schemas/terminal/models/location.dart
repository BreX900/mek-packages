class LocationApi {
  final AddressApi? address;
  final String? displayName;
  final String? id;
  final bool? livemode;
  final Map<String, String> metadata;

  const LocationApi({
    required this.address,
    required this.displayName,
    required this.id,
    required this.livemode,
    required this.metadata,
  });
}

class AddressApi {
  final String? city;
  final String? country;
  final String? line1;
  final String? line2;
  final String? postalCode;
  final String? state;

  const AddressApi({
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.postalCode,
    required this.state,
  });
}

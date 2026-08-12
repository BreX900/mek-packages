import 'package:one_for_all/one_for_all.dart';

/// Filters for Internet reader discovery.
@SerializableClass(flutterToHost: true)
sealed class DiscoveryFilter {
  const DiscoveryFilter();
}

/// Filters internet discovery by reader ID.
class DiscoveryFilterByReaderId extends DiscoveryFilter {
  final String readerId;

  const DiscoveryFilterByReaderId(this.readerId);
}

/// Filters internet discovery by reader serial number.
class DiscoveryFilterBySerialNumber extends DiscoveryFilter {
  final String serialNumber;

  const DiscoveryFilterBySerialNumber(this.serialNumber);
}

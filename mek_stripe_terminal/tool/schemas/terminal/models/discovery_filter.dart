sealed class DiscoveryFilterApi {
  const DiscoveryFilterApi();
}

/// Filters internet discovery by reader ID.
class DiscoveryFilterByReaderIdApi extends DiscoveryFilterApi {
  final String readerId;

  const DiscoveryFilterByReaderIdApi(this.readerId);
}

/// Filters internet discovery by reader serial number.
class DiscoveryFilterBySerialNumberApi extends DiscoveryFilterApi {
  final String serialNumber;

  const DiscoveryFilterBySerialNumberApi(this.serialNumber);
}

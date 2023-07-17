// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_config.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$DiscoverConfig {
  DiscoverConfig get _self => this as DiscoverConfig;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoverConfig &&
          runtimeType == other.runtimeType &&
          _self.discoveryMethod == other.discoveryMethod &&
          _self.simulated == other.simulated &&
          _self.locationId == other.locationId;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.discoveryMethod.hashCode);
    hashCode = $hashCombine(hashCode, _self.simulated.hashCode);
    hashCode = $hashCombine(hashCode, _self.locationId.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('DiscoverConfig')
        ..add('discoveryMethod', _self.discoveryMethod)
        ..add('simulated', _self.simulated)
        ..add('locationId', _self.locationId))
      .toString();
}

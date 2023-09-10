// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$Reader {
  Reader get _self => this as Reader;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reader &&
          runtimeType == other.runtimeType &&
          _self.locationStatus == other.locationStatus &&
          _self.deviceType == other.deviceType &&
          _self.simulated == other.simulated &&
          _self.locationId == other.locationId &&
          _self.location == other.location &&
          _self.serialNumber == other.serialNumber &&
          _self.availableUpdate == other.availableUpdate &&
          _self.batteryLevel == other.batteryLevel &&
          _self.label == other.label;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.locationStatus.hashCode);
    hashCode = $hashCombine(hashCode, _self.deviceType.hashCode);
    hashCode = $hashCombine(hashCode, _self.simulated.hashCode);
    hashCode = $hashCombine(hashCode, _self.locationId.hashCode);
    hashCode = $hashCombine(hashCode, _self.location.hashCode);
    hashCode = $hashCombine(hashCode, _self.serialNumber.hashCode);
    hashCode = $hashCombine(hashCode, _self.availableUpdate.hashCode);
    hashCode = $hashCombine(hashCode, _self.batteryLevel.hashCode);
    hashCode = $hashCombine(hashCode, _self.label.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('Reader')
        ..add('locationStatus', _self.locationStatus)
        ..add('deviceType', _self.deviceType)
        ..add('simulated', _self.simulated)
        ..add('locationId', _self.locationId)
        ..add('location', _self.location)
        ..add('serialNumber', _self.serialNumber)
        ..add('availableUpdate', _self.availableUpdate)
        ..add('batteryLevel', _self.batteryLevel)
        ..add('label', _self.label))
      .toString();
}

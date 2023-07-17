// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$StripeReader {
  StripeReader get _self => this as StripeReader;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StripeReader &&
          runtimeType == other.runtimeType &&
          _self.locationStatus == other.locationStatus &&
          _self.batteryLevel == other.batteryLevel &&
          _self.deviceType == other.deviceType &&
          _self.simulated == other.simulated &&
          _self.availableUpdate == other.availableUpdate &&
          _self.locationId == other.locationId &&
          _self.serialNumber == other.serialNumber &&
          _self.label == other.label;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.locationStatus.hashCode);
    hashCode = $hashCombine(hashCode, _self.batteryLevel.hashCode);
    hashCode = $hashCombine(hashCode, _self.deviceType.hashCode);
    hashCode = $hashCombine(hashCode, _self.simulated.hashCode);
    hashCode = $hashCombine(hashCode, _self.availableUpdate.hashCode);
    hashCode = $hashCombine(hashCode, _self.locationId.hashCode);
    hashCode = $hashCombine(hashCode, _self.serialNumber.hashCode);
    hashCode = $hashCombine(hashCode, _self.label.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('StripeReader')
        ..add('locationStatus', _self.locationStatus)
        ..add('batteryLevel', _self.batteryLevel)
        ..add('deviceType', _self.deviceType)
        ..add('simulated', _self.simulated)
        ..add('availableUpdate', _self.availableUpdate)
        ..add('locationId', _self.locationId)
        ..add('serialNumber', _self.serialNumber)
        ..add('label', _self.label))
      .toString();
}

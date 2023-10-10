// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipping.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$TippingConfiguration {
  TippingConfiguration get _self => this as TippingConfiguration;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TippingConfiguration &&
          runtimeType == other.runtimeType &&
          _self.eligibleAmount == other.eligibleAmount;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.eligibleAmount.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() =>
      (ClassToString('TippingConfiguration')..add('eligibleAmount', _self.eligibleAmount))
          .toString();
}

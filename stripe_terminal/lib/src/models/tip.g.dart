// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$Tip {
  Tip get _self => this as Tip;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tip && runtimeType == other.runtimeType && _self.amount == other.amount;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.amount.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('Tip')..add('amount', _self.amount)).toString();
}

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

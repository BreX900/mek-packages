// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charge.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$Charge {
  Charge get _self => this as Charge;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Charge &&
          runtimeType == other.runtimeType &&
          _self.amount == other.amount &&
          _self.currency == other.currency &&
          _self.status == other.status &&
          _self.paymentMethodDetails == other.paymentMethodDetails &&
          _self.description == other.description &&
          _self.id == other.id &&
          $mapEquality.equals(_self.metadata, other.metadata) &&
          _self.statementDescriptorSuffix == other.statementDescriptorSuffix &&
          _self.calculatedStatementDescriptor == other.calculatedStatementDescriptor &&
          _self.authorizationCode == other.authorizationCode;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.amount.hashCode);
    hashCode = $hashCombine(hashCode, _self.currency.hashCode);
    hashCode = $hashCombine(hashCode, _self.status.hashCode);
    hashCode = $hashCombine(hashCode, _self.paymentMethodDetails.hashCode);
    hashCode = $hashCombine(hashCode, _self.description.hashCode);
    hashCode = $hashCombine(hashCode, _self.id.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.metadata));
    hashCode = $hashCombine(hashCode, _self.statementDescriptorSuffix.hashCode);
    hashCode = $hashCombine(hashCode, _self.calculatedStatementDescriptor.hashCode);
    hashCode = $hashCombine(hashCode, _self.authorizationCode.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('Charge')
        ..add('amount', _self.amount)
        ..add('currency', _self.currency)
        ..add('status', _self.status)
        ..add('paymentMethodDetails', _self.paymentMethodDetails)
        ..add('description', _self.description)
        ..add('id', _self.id)
        ..add('metadata', _self.metadata)
        ..add('statementDescriptorSuffix', _self.statementDescriptorSuffix)
        ..add('calculatedStatementDescriptor', _self.calculatedStatementDescriptor)
        ..add('authorizationCode', _self.authorizationCode))
      .toString();
}

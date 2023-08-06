// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$PaymentMethod {
  PaymentMethod get _self => this as PaymentMethod;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethod &&
          runtimeType == other.runtimeType &&
          _self.id == other.id &&
          _self.card == other.card &&
          _self.cardPresent == other.cardPresent &&
          _self.interacPresent == other.interacPresent &&
          _self.customer == other.customer &&
          $mapEquality.equals(_self.metadata, other.metadata);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.id.hashCode);
    hashCode = $hashCombine(hashCode, _self.card.hashCode);
    hashCode = $hashCombine(hashCode, _self.cardPresent.hashCode);
    hashCode = $hashCombine(hashCode, _self.interacPresent.hashCode);
    hashCode = $hashCombine(hashCode, _self.customer.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.metadata));
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('PaymentMethod')
        ..add('id', _self.id)
        ..add('card', _self.card)
        ..add('cardPresent', _self.cardPresent)
        ..add('interacPresent', _self.interacPresent)
        ..add('customer', _self.customer)
        ..add('metadata', _self.metadata))
      .toString();
}

mixin _$BillingDetails {
  BillingDetails get _self => this as BillingDetails;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingDetails &&
          runtimeType == other.runtimeType &&
          _self.address == other.address &&
          _self.email == other.email &&
          _self.name == other.name &&
          _self.phone == other.phone;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.address.hashCode);
    hashCode = $hashCombine(hashCode, _self.email.hashCode);
    hashCode = $hashCombine(hashCode, _self.name.hashCode);
    hashCode = $hashCombine(hashCode, _self.phone.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('BillingDetails')
        ..add('address', _self.address)
        ..add('email', _self.email)
        ..add('name', _self.name)
        ..add('phone', _self.phone))
      .toString();
}

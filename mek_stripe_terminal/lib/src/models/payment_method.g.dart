// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$StripePaymentMethod {
  StripePaymentMethod get _self => this as StripePaymentMethod;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StripePaymentMethod &&
          runtimeType == other.runtimeType &&
          _self.id == other.id &&
          _self.cardDetails == other.cardDetails &&
          _self.customer == other.customer &&
          _self.livemode == other.livemode &&
          $mapEquality.equals(_self.metadata, other.metadata);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.id.hashCode);
    hashCode = $hashCombine(hashCode, _self.cardDetails.hashCode);
    hashCode = $hashCombine(hashCode, _self.customer.hashCode);
    hashCode = $hashCombine(hashCode, _self.livemode.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.metadata));
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('StripePaymentMethod')
        ..add('id', _self.id)
        ..add('cardDetails', _self.cardDetails)
        ..add('customer', _self.customer)
        ..add('livemode', _self.livemode)
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

mixin _$Address {
  Address get _self => this as Address;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          _self.city == other.city &&
          _self.country == other.country &&
          _self.line1 == other.line1 &&
          _self.line2 == other.line2 &&
          _self.postalCode == other.postalCode &&
          _self.state == other.state;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.city.hashCode);
    hashCode = $hashCombine(hashCode, _self.country.hashCode);
    hashCode = $hashCombine(hashCode, _self.line1.hashCode);
    hashCode = $hashCombine(hashCode, _self.line2.hashCode);
    hashCode = $hashCombine(hashCode, _self.postalCode.hashCode);
    hashCode = $hashCombine(hashCode, _self.state.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('Address')
        ..add('city', _self.city)
        ..add('country', _self.country)
        ..add('line1', _self.line1)
        ..add('line2', _self.line2)
        ..add('postalCode', _self.postalCode)
        ..add('state', _self.state))
      .toString();
}

mixin _$CardDetails {
  CardDetails get _self => this as CardDetails;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardDetails &&
          runtimeType == other.runtimeType &&
          _self.brand == other.brand &&
          _self.country == other.country &&
          _self.expMonth == other.expMonth &&
          _self.expYear == other.expYear &&
          _self.fingerprint == other.fingerprint &&
          _self.funding == other.funding &&
          _self.last4 == other.last4;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.brand.hashCode);
    hashCode = $hashCombine(hashCode, _self.country.hashCode);
    hashCode = $hashCombine(hashCode, _self.expMonth.hashCode);
    hashCode = $hashCombine(hashCode, _self.expYear.hashCode);
    hashCode = $hashCombine(hashCode, _self.fingerprint.hashCode);
    hashCode = $hashCombine(hashCode, _self.funding.hashCode);
    hashCode = $hashCombine(hashCode, _self.last4.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('CardDetails')
        ..add('brand', _self.brand)
        ..add('country', _self.country)
        ..add('expMonth', _self.expMonth)
        ..add('expYear', _self.expYear)
        ..add('fingerprint', _self.fingerprint)
        ..add('funding', _self.funding)
        ..add('last4', _self.last4))
      .toString();
}

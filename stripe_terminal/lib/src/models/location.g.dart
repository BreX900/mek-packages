// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$Location {
  Location get _self => this as Location;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          _self.address == other.address &&
          _self.displayName == other.displayName &&
          _self.id == other.id &&
          _self.livemode == other.livemode &&
          $mapEquality.equals(_self.metadata, other.metadata);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.address.hashCode);
    hashCode = $hashCombine(hashCode, _self.displayName.hashCode);
    hashCode = $hashCombine(hashCode, _self.id.hashCode);
    hashCode = $hashCombine(hashCode, _self.livemode.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.metadata));
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('Location')
        ..add('address', _self.address)
        ..add('displayName', _self.displayName)
        ..add('id', _self.id)
        ..add('livemode', _self.livemode)
        ..add('metadata', _self.metadata))
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

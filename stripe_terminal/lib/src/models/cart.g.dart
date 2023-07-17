// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$Cart {
  Cart get _self => this as Cart;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cart &&
          runtimeType == other.runtimeType &&
          _self.currency == other.currency &&
          _self.tax == other.tax &&
          _self.total == other.total &&
          $listEquality.equals(_self.lineItems, other.lineItems);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.currency.hashCode);
    hashCode = $hashCombine(hashCode, _self.tax.hashCode);
    hashCode = $hashCombine(hashCode, _self.total.hashCode);
    hashCode = $hashCombine(hashCode, $listEquality.hash(_self.lineItems));
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('Cart')
        ..add('currency', _self.currency)
        ..add('tax', _self.tax)
        ..add('total', _self.total)
        ..add('lineItems', _self.lineItems))
      .toString();
}

mixin _$CartLineItem {
  CartLineItem get _self => this as CartLineItem;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartLineItem &&
          runtimeType == other.runtimeType &&
          _self.description == other.description &&
          _self.quantity == other.quantity &&
          _self.amount == other.amount;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.description.hashCode);
    hashCode = $hashCombine(hashCode, _self.quantity.hashCode);
    hashCode = $hashCombine(hashCode, _self.amount.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('CartLineItem')
        ..add('description', _self.description)
        ..add('quantity', _self.quantity)
        ..add('amount', _self.amount))
      .toString();
}

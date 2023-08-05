// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$Refund {
  Refund get _self => this as Refund;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Refund &&
          runtimeType == other.runtimeType &&
          _self.id == other.id &&
          _self.amount == other.amount &&
          _self.chargeId == other.chargeId &&
          _self.created == other.created &&
          _self.currency == other.currency &&
          $mapEquality.equals(_self.metadata, other.metadata) &&
          _self.reason == other.reason &&
          _self.status == other.status &&
          _self.paymentMethodDetails == other.paymentMethodDetails &&
          _self.failureReason == other.failureReason;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.id.hashCode);
    hashCode = $hashCombine(hashCode, _self.amount.hashCode);
    hashCode = $hashCombine(hashCode, _self.chargeId.hashCode);
    hashCode = $hashCombine(hashCode, _self.created.hashCode);
    hashCode = $hashCombine(hashCode, _self.currency.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.metadata));
    hashCode = $hashCombine(hashCode, _self.reason.hashCode);
    hashCode = $hashCombine(hashCode, _self.status.hashCode);
    hashCode = $hashCombine(hashCode, _self.paymentMethodDetails.hashCode);
    hashCode = $hashCombine(hashCode, _self.failureReason.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('Refund')
        ..add('id', _self.id)
        ..add('amount', _self.amount)
        ..add('chargeId', _self.chargeId)
        ..add('created', _self.created)
        ..add('currency', _self.currency)
        ..add('metadata', _self.metadata)
        ..add('reason', _self.reason)
        ..add('status', _self.status)
        ..add('paymentMethodDetails', _self.paymentMethodDetails)
        ..add('failureReason', _self.failureReason))
      .toString();
}

mixin _$PaymentMethodDetails {
  PaymentMethodDetails get _self => this as PaymentMethodDetails;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodDetails &&
          runtimeType == other.runtimeType &&
          _self.cardPresent == other.cardPresent &&
          _self.interacPresent == other.interacPresent;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.cardPresent.hashCode);
    hashCode = $hashCombine(hashCode, _self.interacPresent.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('PaymentMethodDetails')
        ..add('cardPresent', _self.cardPresent)
        ..add('interacPresent', _self.interacPresent))
      .toString();
}

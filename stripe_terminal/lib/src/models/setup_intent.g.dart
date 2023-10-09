// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_intent.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$SetupIntent {
  SetupIntent get _self => this as SetupIntent;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetupIntent &&
          runtimeType == other.runtimeType &&
          _self.id == other.id &&
          _self.created == other.created &&
          _self.customerId == other.customerId &&
          $mapEquality.equals(_self.metadata, other.metadata) &&
          _self.usage == other.usage &&
          _self.status == other.status &&
          _self.latestAttempt == other.latestAttempt;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.id.hashCode);
    hashCode = $hashCombine(hashCode, _self.created.hashCode);
    hashCode = $hashCombine(hashCode, _self.customerId.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.metadata));
    hashCode = $hashCombine(hashCode, _self.usage.hashCode);
    hashCode = $hashCombine(hashCode, _self.status.hashCode);
    hashCode = $hashCombine(hashCode, _self.latestAttempt.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('SetupIntent')
        ..add('id', _self.id)
        ..add('created', _self.created)
        ..add('customerId', _self.customerId)
        ..add('metadata', _self.metadata)
        ..add('usage', _self.usage)
        ..add('status', _self.status)
        ..add('latestAttempt', _self.latestAttempt))
      .toString();
}

mixin _$SetupAttempt {
  SetupAttempt get _self => this as SetupAttempt;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetupAttempt &&
          runtimeType == other.runtimeType &&
          _self.id == other.id &&
          _self.applicationId == other.applicationId &&
          _self.created == other.created &&
          _self.customerId == other.customerId &&
          _self.onBehalfOf == other.onBehalfOf &&
          _self.paymentMethodId == other.paymentMethodId &&
          _self.paymentMethodDetails == other.paymentMethodDetails &&
          _self.setupIntentId == other.setupIntentId &&
          _self.status == other.status;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.id.hashCode);
    hashCode = $hashCombine(hashCode, _self.applicationId.hashCode);
    hashCode = $hashCombine(hashCode, _self.created.hashCode);
    hashCode = $hashCombine(hashCode, _self.customerId.hashCode);
    hashCode = $hashCombine(hashCode, _self.onBehalfOf.hashCode);
    hashCode = $hashCombine(hashCode, _self.paymentMethodId.hashCode);
    hashCode = $hashCombine(hashCode, _self.paymentMethodDetails.hashCode);
    hashCode = $hashCombine(hashCode, _self.setupIntentId.hashCode);
    hashCode = $hashCombine(hashCode, _self.status.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('SetupAttempt')
        ..add('id', _self.id)
        ..add('applicationId', _self.applicationId)
        ..add('created', _self.created)
        ..add('customerId', _self.customerId)
        ..add('onBehalfOfId', _self.onBehalfOf)
        ..add('paymentMethodId', _self.paymentMethodId)
        ..add('paymentMethodDetails', _self.paymentMethodDetails)
        ..add('setupIntentId', _self.setupIntentId)
        ..add('status', _self.status))
      .toString();
}

mixin _$SetupAttemptPaymentMethodDetails {
  SetupAttemptPaymentMethodDetails get _self => this as SetupAttemptPaymentMethodDetails;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetupAttemptPaymentMethodDetails &&
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
  String toString() => (ClassToString('SetupAttemptPaymentMethodDetails')
        ..add('cardPresent', _self.cardPresent)
        ..add('interacPresent', _self.interacPresent))
      .toString();
}

mixin _$SetupAttemptCardPresentDetails {
  SetupAttemptCardPresentDetails get _self => this as SetupAttemptCardPresentDetails;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetupAttemptCardPresentDetails &&
          runtimeType == other.runtimeType &&
          _self.emvAuthData == other.emvAuthData &&
          _self.generatedCard == other.generatedCard;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.emvAuthData.hashCode);
    hashCode = $hashCombine(hashCode, _self.generatedCard.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('SetupAttemptCardPresentDetails')
        ..add('emvAuthData', _self.emvAuthData)
        ..add('generatedCard', _self.generatedCard))
      .toString();
}

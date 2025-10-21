// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

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
          _self.funding == other.funding &&
          _self.last4 == other.last4;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.brand.hashCode);
    hashCode = $hashCombine(hashCode, _self.country.hashCode);
    hashCode = $hashCombine(hashCode, _self.expMonth.hashCode);
    hashCode = $hashCombine(hashCode, _self.expYear.hashCode);
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
        ..add('funding', _self.funding)
        ..add('last4', _self.last4))
      .toString();
}

mixin _$CardPresentDetails {
  CardPresentDetails get _self => this as CardPresentDetails;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardPresentDetails &&
          runtimeType == other.runtimeType &&
          _self.brand == other.brand &&
          _self.country == other.country &&
          _self.expMonth == other.expMonth &&
          _self.expYear == other.expYear &&
          _self.funding == other.funding &&
          _self.last4 == other.last4 &&
          _self.cardholderName == other.cardholderName &&
          _self.emvAuthData == other.emvAuthData &&
          _self.generatedCard == other.generatedCard &&
          _self.incrementalAuthorizationStatus ==
              other.incrementalAuthorizationStatus &&
          _self.networks == other.networks &&
          _self.receipt == other.receipt;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.brand.hashCode);
    hashCode = $hashCombine(hashCode, _self.country.hashCode);
    hashCode = $hashCombine(hashCode, _self.expMonth.hashCode);
    hashCode = $hashCombine(hashCode, _self.expYear.hashCode);
    hashCode = $hashCombine(hashCode, _self.funding.hashCode);
    hashCode = $hashCombine(hashCode, _self.last4.hashCode);
    hashCode = $hashCombine(hashCode, _self.cardholderName.hashCode);
    hashCode = $hashCombine(hashCode, _self.emvAuthData.hashCode);
    hashCode = $hashCombine(hashCode, _self.generatedCard.hashCode);
    hashCode =
        $hashCombine(hashCode, _self.incrementalAuthorizationStatus.hashCode);
    hashCode = $hashCombine(hashCode, _self.networks.hashCode);
    hashCode = $hashCombine(hashCode, _self.receipt.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('CardPresentDetails')
        ..add('brand', _self.brand)
        ..add('country', _self.country)
        ..add('expMonth', _self.expMonth)
        ..add('expYear', _self.expYear)
        ..add('funding', _self.funding)
        ..add('last4', _self.last4)
        ..add('cardholderName', _self.cardholderName)
        ..add('emvAuthData', _self.emvAuthData)
        ..add('generatedCard', _self.generatedCard)
        ..add('incrementalAuthorizationStatus',
            _self.incrementalAuthorizationStatus)
        ..add('networks', _self.networks)
        ..add('receipt', _self.receipt))
      .toString();
}

mixin _$CardNetworks {
  CardNetworks get _self => this as CardNetworks;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardNetworks &&
          runtimeType == other.runtimeType &&
          $listEquality.equals(_self.available, other.available) &&
          _self.preferred == other.preferred;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, $listEquality.hash(_self.available));
    hashCode = $hashCombine(hashCode, _self.preferred.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('CardNetworks')
        ..add('available', _self.available)
        ..add('preferred', _self.preferred))
      .toString();
}

mixin _$ReceiptDetails {
  ReceiptDetails get _self => this as ReceiptDetails;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptDetails &&
          runtimeType == other.runtimeType &&
          _self.accountType == other.accountType &&
          _self.applicationPreferredName == other.applicationPreferredName &&
          _self.authorizationCode == other.authorizationCode &&
          _self.authorizationResponseCode == other.authorizationResponseCode &&
          _self.applicationCryptogram == other.applicationCryptogram &&
          _self.dedicatedFileName == other.dedicatedFileName &&
          _self.transactionStatusInformation ==
              other.transactionStatusInformation &&
          _self.terminalVerificationResults ==
              other.terminalVerificationResults;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.accountType.hashCode);
    hashCode = $hashCombine(hashCode, _self.applicationPreferredName.hashCode);
    hashCode = $hashCombine(hashCode, _self.authorizationCode.hashCode);
    hashCode = $hashCombine(hashCode, _self.authorizationResponseCode.hashCode);
    hashCode = $hashCombine(hashCode, _self.applicationCryptogram.hashCode);
    hashCode = $hashCombine(hashCode, _self.dedicatedFileName.hashCode);
    hashCode =
        $hashCombine(hashCode, _self.transactionStatusInformation.hashCode);
    hashCode =
        $hashCombine(hashCode, _self.terminalVerificationResults.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('ReceiptDetails')
        ..add('accountType', _self.accountType)
        ..add('applicationPreferredName', _self.applicationPreferredName)
        ..add('authorizationCode', _self.authorizationCode)
        ..add('authorizationResponseCode', _self.authorizationResponseCode)
        ..add('applicationCryptogram', _self.applicationCryptogram)
        ..add('dedicatedFileName', _self.dedicatedFileName)
        ..add(
            'transactionStatusInformation', _self.transactionStatusInformation)
        ..add('terminalVerificationResults', _self.terminalVerificationResults))
      .toString();
}

mixin _$CardPresentParameters {
  CardPresentParameters get _self => this as CardPresentParameters;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardPresentParameters &&
          runtimeType == other.runtimeType &&
          _self.captureMethod == other.captureMethod &&
          _self.requestExtendedAuthorization ==
              other.requestExtendedAuthorization &&
          _self.requestIncrementalAuthorizationSupport ==
              other.requestIncrementalAuthorizationSupport &&
          _self.requestedPriority == other.requestedPriority;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.captureMethod.hashCode);
    hashCode =
        $hashCombine(hashCode, _self.requestExtendedAuthorization.hashCode);
    hashCode = $hashCombine(
        hashCode, _self.requestIncrementalAuthorizationSupport.hashCode);
    hashCode = $hashCombine(hashCode, _self.requestedPriority.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('CardPresentParameters')
        ..add('captureMethod', _self.captureMethod)
        ..add(
            'requestExtendedAuthorization', _self.requestExtendedAuthorization)
        ..add('requestIncrementalAuthorizationSupport',
            _self.requestIncrementalAuthorizationSupport)
        ..add('requestedPriority', _self.requestedPriority))
      .toString();
}

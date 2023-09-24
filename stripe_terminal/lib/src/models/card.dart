import 'package:mek_data_class/mek_data_class.dart';

part 'card.g.dart';

enum CardBrand {
  amex,
  dinersClub,
  discover,
  jcb,
  masterCard,
  unionPay,
  visa,

  /// Only iOS
  interac,

  /// Only iOS
  eftposAu;
}

enum CardFundingType { credit, debit, prepaid }

@DataClass()
class CardPresentDetails with _$CardPresentDetails {
  final CardBrand? brand;
  final String? country;
  final int expMonth;
  final int expYear;
  final CardFundingType? funding;
  final String? last4;

  final String? cardholderName;
  final String? emvAuthData;
  final String? generatedCard;
  final IncrementalAuthorizationStatus? incrementalAuthorizationStatus;
  final CardNetworks? networks;
  final ReceiptDetails? receipt;

  const CardPresentDetails({
    required this.brand,
    required this.country,
    required this.expMonth,
    required this.expYear,
    required this.funding,
    required this.last4,
    required this.cardholderName,
    required this.emvAuthData,
    required this.generatedCard,
    required this.incrementalAuthorizationStatus,
    required this.networks,
    required this.receipt,
  });

  bool get incrementalAuthorizationSupported =>
      incrementalAuthorizationStatus == IncrementalAuthorizationStatus.supported;
}

enum IncrementalAuthorizationStatus { notSupported, supported }

@DataClass()
class CardNetworks with _$CardNetworks {
  final List<CardBrand> available;
  final String? preferred;

  const CardNetworks({
    required this.available,
    required this.preferred,
  });
}

@DataClass()
class ReceiptDetails with _$ReceiptDetails {
  final String? accountType;
  final String applicationPreferredName;
  final String? authorizationCode;
  final String authorizationResponseCode;
  final String applicationCryptogram;
  final String dedicatedFileName;
  final String transactionStatusInformation;
  final String terminalVerificationResults;

  const ReceiptDetails({
    required this.accountType,
    required this.applicationPreferredName,
    required this.authorizationCode,
    required this.authorizationResponseCode,
    required this.applicationCryptogram,
    required this.dedicatedFileName,
    required this.transactionStatusInformation,
    required this.terminalVerificationResults,
  });
}

enum CardPresentCaptureMethod {
  manualPreferred,
}

@DataClass()
class CardPresentParameters with _$CardPresentParameters {
  final CardPresentCaptureMethod? captureMethod;
  final bool? requestExtendedAuthorization;
  final bool? requestIncrementalAuthorizationSupport;
  final CardPresentRouting? requestedPriority;

  const CardPresentParameters({
    this.captureMethod,
    this.requestExtendedAuthorization,
    this.requestIncrementalAuthorizationSupport,
    this.requestedPriority,
  });
}

enum CardPresentRouting {
  domestic,
  international,
}

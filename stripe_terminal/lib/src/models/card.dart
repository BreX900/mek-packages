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
class CardDetails with _$CardDetails {
  final CardBrand? brand;
  final String? country;
  final int expMonth;
  final int expYear;
  final CardFundingType? funding;
  final String? last4;

  const CardDetails({
    required this.brand,
    required this.country,
    required this.expMonth,
    required this.expYear,
    required this.funding,
    required this.last4,
  });
}

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

/// Capture Method values that can be used as card-present payment method options.
enum CardPresentCaptureMethod {
  /// Use manual_preferred if you prefer manual capture_method for the [PaymentIntent]’s
  /// capture_method but support falling back to automatic based on the presented payment method.
  manualPreferred,
}

/// Parameters that will be applied to the card present PaymentIntent.
@DataClass()
class CardPresentParameters with _$CardPresentParameters {
  /// Capture method of a card-present payment method option.
  final CardPresentCaptureMethod? captureMethod;

  /// Using the extended authorizations feature, users in eligible categories can capture up to
  /// 31 days later, depending on the card brand.
  final bool? requestExtendedAuthorization;

  /// Allows you to increase the authorized amount on a confirmed [PaymentIntent] before you capture it.
  /// This means you can update the amount on a payment if the estimated price changes or goods and
  /// services are added. Before capture, each incremental authorization appears on your customer’s
  /// credit card statement as an additional pending charge.
  final bool? requestIncrementalAuthorizationSupport;

  /// Network routing priority on co-branded EMV cards supporting domestic debit and international card schemes.
  final CardPresentRouting? requestedPriority;

  const CardPresentParameters({
    this.captureMethod,
    this.requestExtendedAuthorization,
    this.requestIncrementalAuthorizationSupport,
    this.requestedPriority,
  });
}

/// Transaction routing priorities
enum CardPresentRouting {
  domestic,
  international,
}

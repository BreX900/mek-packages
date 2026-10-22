enum CardBrandApi {
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
  eftposAu,
}

enum CardFundingTypeApi { credit, debit, prepaid }

class CardDetailsApi {
  final CardBrandApi? brand;
  final String? country;
  final int expMonth;
  final int expYear;
  final CardFundingTypeApi? funding;
  final String? last4;

  const CardDetailsApi({
    required this.brand,
    required this.country,
    required this.expMonth,
    required this.expYear,
    required this.funding,
    required this.last4,
  });
}

class CardPresentDetailsApi {
  final CardBrandApi? brand;
  final String? country;
  final int expMonth;
  final int expYear;
  final CardFundingTypeApi? funding;
  final String? last4;

  final String? cardholderName;
  final String? emvAuthData;
  final String? generatedCard;
  final IncrementalAuthorizationStatusApi? incrementalAuthorizationStatus;
  final CardNetworksApi? networks;
  final ReceiptDetailsApi? receipt;

  const CardPresentDetailsApi({
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

  // bool get incrementalAuthorizationSupported =>
  //     incrementalAuthorizationStatus == IncrementalAuthorizationStatus.supported;
}

enum IncrementalAuthorizationStatusApi { notSupported, supported }

class CardNetworksApi {
  final List<CardBrandApi> available;
  final String? preferred;

  const CardNetworksApi({required this.available, required this.preferred});
}

class ReceiptDetailsApi {
  final String? accountType;
  final String? applicationPreferredName;
  final String? authorizationCode;
  final String authorizationResponseCode;
  final String? applicationCryptogram;
  final String? dedicatedFileName;
  final String? transactionStatusInformation;
  final String? terminalVerificationResults;

  const ReceiptDetailsApi({
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
enum CardPresentCaptureMethodApi {
  /// Use manual_preferred if you prefer manual capture_method for the [PaymentIntent]’s
  /// capture_method but support falling back to automatic based on the presented payment method.
  manualPreferred,
}

/// Parameters that will be applied to the card present PaymentIntent.
class CardPresentParametersApi {
  /// Capture method of a card-present payment method option.
  final CardPresentCaptureMethodApi? captureMethod;

  /// Using the extended authorizations feature, users in eligible categories can capture up to
  /// 31 days later, depending on the card brand.
  final bool? requestExtendedAuthorization;

  /// Allows you to increase the authorized amount on a confirmed [PaymentIntent] before you capture it.
  /// This means you can update the amount on a payment if the estimated price changes or goods and
  /// services are added. Before capture, each incremental authorization appears on your customer’s
  /// credit card statement as an additional pending charge.
  final bool? requestIncrementalAuthorizationSupport;

  /// Network routing priority on co-branded EMV cards supporting domestic debit and international card schemes.
  final CardPresentRoutingApi? requestedPriority;

  const CardPresentParametersApi({
    this.captureMethod,
    this.requestExtendedAuthorization,
    this.requestIncrementalAuthorizationSupport,
    this.requestedPriority,
  });
}

/// Transaction routing priorities
enum CardPresentRoutingApi { domestic, international }

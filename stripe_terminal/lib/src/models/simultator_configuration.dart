/// Simulator specific configurations you can set to test your integration’s behavior in different
/// scenarios. We recommend changing these properties during testing to ensure your app works as
/// expected for different reader updates and for different presented cards.
///
/// Do not create new instances of this class. Instead, set the properties via [Terminal.setSimulatorConfiguration].
class SimulatorConfiguration {
  /// Set this to different values of the [SimulateReaderUpdate] enum to test your integration with
  /// different reader software update scenarios.
  final SimulateReaderUpdate update;

  /// Create a [SimulatedCard] and set it on the shared configuration object to test your integration
  /// with different card brands and in error scenarios.
  ///
  /// Note: Simulated Internet reader refunds do not use the specified simulated card.
  /// See: https://stripe.com/docs/terminal/testing#simulated-test-cards
  final SimulatedCard simulatedCard;

  /// Set this to simulate a [Terminal] configuration object with this fixed tip amount for all currencies.
  final int? simulatedTipAmount;

  const SimulatorConfiguration({
    this.update = SimulateReaderUpdate.available,
    this.simulatedCard = const SimulatedCard.fromType(SimulatedCardType.visa),
    this.simulatedTipAmount,
  });
}

/// Enum used to simulate various types of reader updates being available for a simulated bluetooth
/// or local mobile reader.
enum SimulateReaderUpdate {
  /// Updates are available
  ///
  /// When connecting to a Bluetooth reader, an update is available that is marked as needing to be installed within 7 days.
  /// When connecting to a Local Mobile reader, a mandatory update will complete during the connection flow.
  available,

  /// No updates are available
  none,

  /// A required full reader software update exists.
  ///
  /// Use this to simulate the auto-install of a required update that will be applied during connect.
  /// This simulated update will take 1 minute and progress will be provided to the delegate provided
  /// to [Terminal.connectBluetoothReader] or [Terminal.connectLocalMobileReader] as appropriate.
  required,

  /// Randomly picks a type of update for the reader to help exercise the various states.
  random,
}

/// Simulated Card objects can be used with the shared [SimulatorConfiguration] to simulate different
/// card brand and error cases with a simulated Reader.
///
/// Simulated Card objects are backed by one of Stripe’s test card numbers, which are hardcoded to
/// provide certain behavior within Stripe’s backend. The Terminal SDK provides an [SimulatedCardType]
/// enum that automatically maps to the card numbers for convenience.
///
///
/// See: https://stripe.com/docs/terminal/testing#simulated-test-cards
class SimulatedCard {
  final SimulatedCardType? type;
  final String? testCardNumber;

  /// Create a Simulated Card object with a given simulated card type.
  const SimulatedCard.fromType(SimulatedCardType this.type) : testCardNumber = null;

  /// Create a Simulated Card object with a raw card number.
  ///
  /// This initializer is made available in case Stripe creates a new test card number without
  /// creating a corresponding [SimulatedCardType]. The card number entered here must be in the list
  /// of test card numbers.
  ///
  /// See: https://stripe.com/docs/terminal/testing#simulated-test-cards
  const SimulatedCard.fromTestCardNumber(String this.testCardNumber) : type = null;
}

/// Enum used to simulate various types of cards and error cases.
///
/// See: https://stripe.com/docs/terminal/testing#simulated-test-cards
enum SimulatedCardType {
  /// Visa
  visa,

  /// Visa (debit)
  visaDebit,

  /// Visa debit supporting both international and US Common Debit applications
  visaUsCommonDebit,

  /// Mastercard
  mastercard,

  /// Mastercard (debit)
  masterDebit,

  /// Mastercard (prepaid)
  mastercardPrepaid,

  /// American Express
  amex,

  /// American Express
  amex2,

  /// Discover
  discover,

  /// Discover
  discover2,

  /// Diners Club
  diners,

  /// Diners Club (14 digit card)
  diners14Digit,

  /// JCB
  jbc,

  /// UnionPay
  unionPay,

  /// Interac
  interac,

  /// Eftpos Australia
  eftposAuDebit,

  /// Eftpos Australia/Visa
  eftposAuVisaDebit,

  /// Eftpos Australia/Mastercard
  eftposAuDebitMastercard,

  /// Charge is declined with a card_declined code.
  chargeDeclined,

  /// Charge is declined with a card_declined code. The decline_code attribute is insufficient_funds.
  chargeDeclinedInsufficientFunds,

  /// Charge is declined with a card_declined code. The decline_code attribute is lost_card.
  chargeDeclinedLostCard,

  /// Charge is declined with a card_declined code. The decline_code attribute is stolen_card.
  chargeDeclinedStolenCard,

  /// Charge is declined with an expired_card code.
  chargeDeclinedExpiredCard,

  /// Charge is declined with a processing_error code.
  chargeDeclinedProcessingError,

  /// Payment attaches Online Pin to the transaction. cardholder_verification_method will be set to
  /// online_pin in the resulting paymentIntent WisePad3 only
  onlinePinCvm,

  /// This flow simulates an Online Pin scenario with SCA compliance. Payment is retried and user is
  /// prompted to input their pin. Next an online pin being entered is simulated.
  onlinePinScaRetry,

  /// Payment attaches Offline Pin to the transaction. cardholder_verification_method will be set to
  /// offline_pin in the resulting paymentIntent WisePad3 only
  offlinePinCvm,

  /// This flow simulates an Offline Pin scenario with SCA compliance. Payment is retried and user is
  /// prompted to insert their card. Next a contact retry and an offline pin being entered are simulated.
  offlinePinScaRetry,
}

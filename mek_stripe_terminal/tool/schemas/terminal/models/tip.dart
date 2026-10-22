/// Contains details about tips
///
/// For more information, see the official Stripe docs: [Collect on-reader tips](https://stripe.com/docs/terminal/features/collecting-tips/on-reader)
class TipApi {
  /// Portion of the amount that corresponds to a tip
  ///
  /// The value will be null in the following scenarios:
  /// - tipping is skipped by using the skipTipping flag in processPaymentIntent or by setting
  ///   TippingConfiguration.eligibleAmount to 0
  /// - current reader location does not have a tipping config set
  /// If “No tip” is selected on the reader, the value will be 0
  final int? amount;

  const TipApi({required this.amount});
}

// PARAMETERS

/// The [TippingConfigurationApi] contains configuration information relevant to collecting tips.
class TippingConfigurationApi {
  /// The amount of the payment total eligible for tips.
  final int eligibleAmount;

  const TippingConfigurationApi({required this.eligibleAmount});
}

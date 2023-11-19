import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'tip.g.dart';

/// Contains details about tips
///
/// For more information, see the official Stripe docs: [Collect on-reader tips](https://stripe.com/docs/terminal/features/collecting-tips/on-reader)
@DataClass()
class Tip with _$Tip {
  /// Portion of the amount that corresponds to a tip
  ///
  /// The value will be null in the following scenarios:
  /// - tipping is skipped by using the CollectConfiguration.skipTipping flag or by setting TippingConfiguration.eligibleAmount to 0
  /// - current reader location does not have a tipping config set
  /// If “No tip” is selected on the reader, the value will be 0
  final int? amount;

  @internal
  const Tip({
    required this.amount,
  });
}

// PARAMETERS

/// The [TippingConfiguration] contains configuration information relevant to collecting tips.
@DataClass()
class TippingConfiguration with _$TippingConfiguration {
  /// The amount of the payment total eligible for tips.
  final int eligibleAmount;

  const TippingConfiguration({
    required this.eligibleAmount,
  });
}

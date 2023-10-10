import 'package:mek_data_class/mek_data_class.dart';

part 'tipping.g.dart';

/// The [TippingConfiguration] contains configuration information relevant to collecting tips.
@DataClass()
class TippingConfiguration with _$TippingConfiguration {
  /// The amount of the payment total eligible for tips.
  final int eligibleAmount;

  const TippingConfiguration({
    required this.eligibleAmount,
  });
}

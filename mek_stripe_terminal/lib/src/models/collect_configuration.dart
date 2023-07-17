import 'package:mek_data_class/mek_data_class.dart';

part 'collect_configuration.g.dart';

@DataClass()
class CollectConfiguration with _$CollectConfiguration {
  final bool skipTipping;

  const CollectConfiguration({
    /// Weather to skip tipping or not, default to false if config is not provided
    required this.skipTipping,
  });
}

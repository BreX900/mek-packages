import 'package:mek_data_class/mek_data_class.dart';

part 'reader_software_update.g.dart';

@DataClass()
class ReaderSoftwareUpdate with _$ReaderSoftwareUpdate {
  final List<UpdateComponent> components;
  // final config: com.stripe.proto.model.config.MobileClientConfig? /* compiled code */
  // final configSpec: com.stripe.proto.model.common.ClientVersionSpecPb? /* compiled code */
  // final firmwareSpec: com.stripe.proto.model.common.ClientVersionSpecPb? /* compiled code */
  final String? keyProfileName;
  final bool onlyInstallRequiredUpdates;
  final DateTime requiredAt;
  final String? settingsVersion;
  final UpdateTimeEstimate timeEstimate;
  final String version;

  const ReaderSoftwareUpdate({
    required this.components,
    required this.keyProfileName,
    required this.onlyInstallRequiredUpdates,
    required this.requiredAt,
    required this.settingsVersion,
    required this.timeEstimate,
    required this.version,
  });

  bool get hasIncrementalUpdate => components.contains(UpdateComponent.incremental);
  bool get hasFirmwareUpdate => components.contains(UpdateComponent.firmware);
  bool get hasConfigUpdate => components.contains(UpdateComponent.config);
  bool get hasKeyUpdate => components.contains(UpdateComponent.keys);
}

enum UpdateComponent {
  incremental,
  firmware,
  config,
  keys;
}

enum UpdateTimeEstimate {
  lessThanOneMinute,
  oneToTwoMinutes,
  twoToFiveMinutes,
  fiveToFifteenMinutes;
}

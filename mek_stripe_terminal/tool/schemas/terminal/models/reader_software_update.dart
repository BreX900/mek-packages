class ReaderSoftwareUpdateApi {
  final List<UpdateComponentApi> components;
  // final config: com.stripe.proto.model.config.MobileClientConfig? /* compiled code */
  // final configSpec: com.stripe.proto.model.common.ClientVersionSpecPb? /* compiled code */
  // final firmwareSpec: com.stripe.proto.model.common.ClientVersionSpecPb? /* compiled code */
  final String? keyProfileName;
  final bool onlyInstallRequiredUpdates;
  final int requiredAtInMilliseconds;
  final String? settingsVersion;
  final UpdateTimeEstimateApi timeEstimate;
  final String version;

  const ReaderSoftwareUpdateApi({
    required this.components,
    required this.keyProfileName,
    required this.onlyInstallRequiredUpdates,
    required this.requiredAtInMilliseconds,
    required this.settingsVersion,
    required this.timeEstimate,
    required this.version,
  });
}

enum UpdateComponentApi { incremental, firmware, config, keys }

enum UpdateTimeEstimateApi {
  lessThanOneMinute,
  oneToTwoMinutes,
  twoToFiveMinutes,
  fiveToFifteenMinutes,
}

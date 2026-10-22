import 'package:mek_stripe_terminal/src/api/terminal_api.g.dart';

typedef ReaderSoftwareUpdate = ReaderSoftwareUpdateApi;

typedef UpdateComponent = UpdateComponentApi;

typedef UpdateTimeEstimate = UpdateTimeEstimateApi;

extension ReaderSoftwareUpdateApiUtils on ReaderSoftwareUpdateApi {
  bool get hasIncrementalUpdate => components.contains(UpdateComponentApi.incremental);
  bool get hasFirmwareUpdate => components.contains(UpdateComponentApi.firmware);
  bool get hasConfigUpdate => components.contains(UpdateComponentApi.config);
  bool get hasKeyUpdate => components.contains(UpdateComponentApi.keys);
  DateTime get requiredAt =>
      DateTime.fromMillisecondsSinceEpoch(requiredAtInMilliseconds, isUtc: true);
}

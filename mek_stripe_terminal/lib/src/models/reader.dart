import 'package:mek_stripe_terminal/src/api/terminal_api.g.dart';

typedef ConnectionStatus = ConnectionStatusApi;

typedef Reader = ReaderApi;

extension ReaderUtils on Reader {
  BatteryStatusApi? get batteryStatus {
    if (batteryLevel == -1) return null;
    return BatteryStatusApi.values.singleWhere((e) {
      return batteryLevel > e.minLevel && batteryLevel < e.maxLevel;
    });
  }
}

typedef LocationStatus = LocationStatusApi;

typedef DeviceType = DeviceTypeApi;

typedef ReaderEvent = ReaderEventApi;

typedef ReaderDisplayMessage = ReaderDisplayMessageApi;

typedef ReaderInputOption = ReaderInputOptionApi;

typedef NetworkStatus = NetworkStatusApi;

typedef BatteryStatus = BatteryStatusApi;

/// A categorization of a reader’s battery charge level.
extension BatteryStatusUtils on BatteryStatus {
  double get minLevel => switch (this) {
    BatteryStatus.critical => 0.00,
    BatteryStatus.low => 0.05,
    BatteryStatus.nominal => 0.20,
  };
  double get maxLevel => switch (this) {
    BatteryStatusApi.critical => 0.05,
    BatteryStatusApi.low => 0.20,
    BatteryStatusApi.nominal => 1.00,
  };
}

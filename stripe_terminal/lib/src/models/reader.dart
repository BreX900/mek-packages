import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'reader.g.dart';

enum ConnectionStatus { notConnected, connected, connecting }

@DataClass()
class Reader with _$Reader {
  final LocationStatus? locationStatus;
  final double batteryLevel;
  final DeviceType? deviceType;
  final bool simulated;
  final bool availableUpdate;
  final String? locationId;
  final String serialNumber;
  final String? label;

  @internal
  const Reader({
    required this.locationStatus,
    required this.batteryLevel,
    required this.deviceType,
    required this.simulated,
    required this.availableUpdate,
    required this.serialNumber,
    required this.locationId,
    required this.label,
  });
}

enum LocationStatus { set, notSet }

enum DeviceType {
  chipper1X,
  chipper2X,
  stripeM2,
  cotsDevice,
  verifoneP400,
  wiseCube,
  wisePad3,
  wisePad3s,
  wisePosE,
  wisePosEDevkit,
  etna,
  stripeS700,
  stripeS700Devkit,
  appleBuiltIn,
}

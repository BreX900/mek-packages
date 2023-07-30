import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'reader.g.dart';

@DataClass()
class Reader with _$Reader {
  final LocationStatus locationStatus;
  final double batteryLevel;
  final DeviceType deviceType;
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

enum LocationStatus {
  unknown,
  set,
  notSet,
}

enum DeviceType {
  chipper1X,
  chipper2X,
  stripeM2,
  cotsDevice,
  verifoneP400,
  wiseCube,
  wisepad3,
  wisepad3s,
  wiseposE,
  wiseposEDevkit,
  etna,
  stripeS700,
  stripeS700Devkit,
  unknown
}

enum ConnectionStatus { notConnected, connected, connecting }

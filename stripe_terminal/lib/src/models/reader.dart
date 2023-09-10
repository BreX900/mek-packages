import 'package:mek_data_class/mek_data_class.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:meta/meta.dart';

part 'reader.g.dart';

/// The possible reader connection statuses for the SDK.
enum ConnectionStatus {
  /// The SDK is not connected to a reader.
  notConnected,

  /// The SDK is connected to a reader.
  connected,

  /// The SDK is currently connecting to a reader.
  connecting
}

/// Information about a card reader that has been discovered by or connected to the SDK.
///
/// Some of the properties are only applicable to a certain device type. These properties are
/// labeled with the reader or reader type to which they apply.
@DataClass()
class Reader with _$Reader {
  // TODO: Add id field

  /// Used to tell whether the location field has been set. Note that the Internet and simulated
  /// readers will always have an `null` [locationStatus].
  ///
  /// The location is not known. location will be nil.
  ///
  /// A reader will have a location status to `null` when a Bluetooth reader’s full location
  /// information failed to fetch properly during discovery.
  ///
  /// (Bluetooth and Apple Built-In readers only.)
  final LocationStatus? locationStatus;

  /// The reader’s device type.
  final DeviceType? deviceType;

  /// True if this is a simulated reader.
  final bool simulated;

  /// The ID of the reader’s Location.
  ///
  /// Internet readers remain registered to the location specified when registering the reader
  /// to your account. For internet readers, this field represents that location. If you need to
  /// change your internet reader’s location, re-register the reader and specify the new location id
  /// in the location param. See https://stripe.com/docs/api/terminal/readers/create
  ///
  /// Bluetooth and Apple Built-In readers are designed to be more mobile and must be registered
  /// to a location upon each connection. This field represents the last location that the reader
  /// was registered to. If the reader has not been used before, this field will be `null`. If you
  /// associate the reader to a different location while calling [StripeTerminal.connectBluetoothReader],
  /// this field will update to that new location’s id.
  final String? locationId;

  final Location? location;

  // TODO: Add location field

  /// The reader’s serial number.
  final String serialNumber;

  // TODO: Add deviceSoftwareVersion field

  /// LocalMobile, Bluetooth and Usb readers properties

  /// The available update for this reader, or nil if no update is available. This update will also
  /// have been announced via [PhysicalReaderDelegate.onReportAvailableUpdate]
  ///
  /// Install this update with [StripeTerminal.installAvailableUpdate]
  ///
  /// calls to [StripeTerminal.installAvailableUpdate] when availableUpdate is `null` will result in
  /// [PhysicalReaderDelegate.onFinishInstallingUpdate] called immediately with a `null` update and `null` error.
  final bool availableUpdate;

  /// The reader’s battery level, represented as a boxed float in the range [0, 1]. If the reader does not have a battery, or the battery level is unknown, this value is nil.
  final double batteryLevel;

  BatteryStatus? get batteryStatus => BatteryStatus.from(batteryLevel);

  // TODO: Add isCharging/bluetoothDevice field

  /// Internet readers properties

  // TODO: Add ipAddress field
  // TODO: Add status/networkStatus field

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
    required this.location,
    required this.label,
  });
}

/// Represents the possible states of the location object for a discovered reader.
enum LocationStatus {
  /// The location was successfully set to a known location. location is a valid [Location].
  set,

  /// This location is known to be not set. location will be null.
  notSet
}

/// The reader’s device type.
enum DeviceType {
  /// Chipper 1X aka Chip & Swipe
  chipper1X,

  /// The BBPOS Chipper 2X BT mobile reader.
  chipper2X,

  /// The Stripe Reader M2 mobile reader.
  stripeM2,

  /// COTS Device.
  cotsDevice,

  /// The Verifone P400 countertop reader.
  verifoneP400,

  /// Wisecube aka Wisepad 2 aka Tap & Chip.
  wiseCube,

  /// The BBPOS WisePad 3 mobile reader.
  wisePad3,

  /// The BBPOS WisePad 3S mobile reader.
  wisePad3s,

  /// The BBPOS WisePOS E countertop reader.
  wisePosE,

  /// The BBPOS WisePOS E DevKit countertop reader.
  wisePosEDevkit,

  /// ETNA.
  etna,

  /// Stripe Reader S700.
  stripeS700,

  /// Stripe Reader S700 DevKit.
  stripeS700Devkit,

  /// Apple Built-In reader.
  appleBuiltIn,
}

/// A categorization of a reader’s battery charge level.
enum BatteryStatus {
  /// The device’s battery is less than or equal to 5%.
  critical(0.00, 0.05),

  /// The device’s battery is between 5% and 20%.
  low(0.05, 0.20),

  /// The device’s battery is greater than 20%.
  nominal(0.20, 1.00);

  final double minLevel;
  final double maxLevel;

  const BatteryStatus(this.minLevel, this.maxLevel);

  static BatteryStatus? from(double level) {
    if (level == -1) return null;
    return BatteryStatus.values.singleWhere((e) => level > e.minLevel && level < e.maxLevel);
  }
}

enum ReaderEvent { cardInserted, cardRemoved }

enum ReaderDisplayMessage {
  checkMobileDevice,
  retryCard,
  insertCard,
  insertOrSwipeCard,
  swipeCard,
  removeCard,
  multipleContactlessCardsDetected,
  tryAnotherReadMethod,
  tryAnotherCard,
  cardRemovedTooEarly,
}

enum ReaderInputOption { insertCard, swipeCard, tapCard, manualEntry }

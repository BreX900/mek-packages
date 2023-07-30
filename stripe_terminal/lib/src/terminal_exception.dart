import 'package:collection/collection.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:recase/recase.dart';

@SerializableEnum(
  type: SerializableEnumType.string,
  languages: {LanguageApi.swift},
  hostToFlutter: true,
)
enum TerminalExceptionCode {
  /// Common
  paymentIntentNotRetrieved('Before calling this method you need to call "retrievePaymentIntent".'),

  /// Android
  cancelFailed,
  notConnectedToReader,
  alreadyConnectedToReader,
  bluetoothPermissionDenied,
  processInvalidPaymentIntent,
  invalidClientSecret,
  unsupportedOperation,
  unexpectedOperation,
  unsupportedSdk,
  usbPermissionDenied,
  missingRequiredParameter,
  invalidRequiredParameter,
  invalidTipParameter,
  localMobileLibraryNotIncluded,
  localMobileUnsupportedDevice,
  localMobileUnsupportedAndroidVersion,
  localMobileDeviceTampered,
  localMobileDebugNotSupported,
  offlineModeUnsupportedAndroidVersion,
  canceled,
  locationServicesDisabled,
  bluetoothScanTimedOut,
  bluetoothLowEnergyUnsupported,
  readerSoftwareUpdateFailedBatteryLow,
  readerSoftwareUpdateFailedInterrupted,
  cardInsertNotRead,
  cardSwipeNotRead,
  cardReadTimedOut,
  cardRemoved,
  customerConsentRequired,
  cardLeftInReader,
  usbDiscoveryTimedOut,
  featureNotEnabledOnAccount,
  readerBusy,
  readerCommunicationError,
  bluetoothError,
  bluetoothDisconnected,
  bluetoothReconnectStarted,
  usbDisconnected,
  usbReconnectStarted,
  readerConnectedToAnotherDevice,
  readerSoftwareUpdateFailed,
  readerSoftwareUpdateFailedReaderError,
  readerSoftwareUpdateFailedServerError,
  localMobileNfcDisabled,
  unsupportedReaderVersion,
  unexpectedSdkError,
  declinedByStripeApi,
  declinedByReader,
  requestTimedOut,
  stripeApiConnectionError,
  stripeApiError,
  stripeApiResponseDecodingError,
  connectionTokenProviderError,
  sessionExpired,
  androidApiLevelError,
  amountExceedsMaxOfflineAmount,
  offlinePaymentsDatabaseTooLarge,
  readerConnectionNotAvailableOffline,
  readerConnectionOfflineLocationMismatch,
  noLastSeenAccount,
  invalidOfflineCurrency,
  cardSwipeNotAvailable,
  interacNotSupportedOffline,
  onlinePinNotSupportedOffline,
  offlineAndCardExpired,
  offlineTransactionDeclined,
  offlineCollectAndProcessMismatch,
  offlineTestmodePaymentInLivemode,
  offlineLivemodePaymentInTestmode,
  offlinePaymentIntentNotFound,
  missingEmvData,
  connectionTokenProviderErrorWhileForwarding,
  accountIdMismatchWhileForwarding,
  forceOfflineWithFeatureDisabled,
  notConnectedToInternetAndRequireOnlineSet,

  /// iOS
  ;

  final String? message;

  const TerminalExceptionCode([this.message]);
}

class TerminalException {
  final String rawCode;
  final String? message;
  final String? details;

  late final TerminalExceptionCode? code =
      TerminalExceptionCode.values.firstWhereOrNull((e) => e.name == rawCode);

  TerminalException({
    required String rawCode,
    required this.message,
    required this.details,
  }) : rawCode = rawCode.camelCase;

  @override
  String toString() =>
      ['$runtimeType: $rawCode', code?.message, message, details].nonNulls.join('\n');
}

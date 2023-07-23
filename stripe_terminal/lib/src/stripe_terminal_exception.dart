import 'package:one_for_all/one_for_all.dart';

@SerializableEnum(
  type: SerializableEnumType.string,
  languages: {LanguageApi.swift},
  hostToFlutter: true,
)
enum StripeTerminalExceptionCode {
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
  notConnectedToInternetAndRequireOnlineSet;

  const StripeTerminalExceptionCode();
}

class StripeTerminalException {
  final StripeTerminalExceptionCode code;
  final String? message;
  final String? details;

  const StripeTerminalException(this.code, this.message, this.details);

  @override
  String toString() => ['$runtimeType: ${code.name}', message, details].nonNulls.join('\n');
}

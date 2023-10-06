import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:recase/recase.dart';

@experimental
@SerializableEnum(
  type: SerializableEnumType.string,
  languages: {LanguageApi.swift},
  hostToFlutter: true,
)
enum TerminalExceptionCode {
  /// Generic
  unknown,
  paymentIntentNotRetrieved,

  /// Common
  cancelFailed('1010', 'CANCEL_FAILED'), // SCPErrorCancelFailedAlreadyCompleted
  notConnectedToReader('1100', 'NOT_CONNECTED_TO_READER'), // SCPErrorNotConnectedToReader
  alreadyConnectedToReader('1110', 'ALREADY_CONNECTED_TO_READER'), // SCPErrorAlreadyConnectedToReader
  confirmInvalidPaymentIntent('1530', 'CONFIRM_INVALID_PAYMENT_INTENT'), // SCPErrorConfirmInvalidPaymentIntent
  invalidClientSecret('1560', 'INVALID_CLIENT_SECRET'), // SCPErrorInvalidClientSecret
  invalidTipParameter('1640', 'INVALID_TIP_PARAMETER'), // SCPErrorReaderTippingParameterInvalid
  unsupportedSdk('1870', 'UNSUPPORTED_SDK'), // SCPErrorUnsupportedSDK
  featureNotAvailable('1890', 'FEATURE_NOT_AVAILABLE'), // SCPErrorFeatureNotAvailable
  invalidRequiredParameter('1920', 'INVALID_REQUIRED_PARAMETER'), // SCPErrorInvalidRequiredParameter
  accountIdMismatchWhileForwarding('1930', 'ACCOUNT_ID_MISMATCH_WHILE_FORWARDING'), // SCPErrorAccountIdMismatchWhileForwarding
  offlineTestmodePaymentInLivemode('1937', 'OFFLINE_TESTMODE_PAYMENT_IN_LIVEMODE'), // SCPErrorForwardingTestModePaymentInLiveMode
  offlineLivemodePaymentInTestmode('1938', 'OFFLINE_LIVEMODE_PAYMENT_IN_TESTMODE'), // SCPErrorForwardingLiveModePaymentInTestmode
  canceled('2020', 'CANCELED'), // SCPErrorCanceled
  locationServicesDisabled('2200', 'LOCATION_SERVICES_DISABLED'), // SCPErrorLocationServicesDisabled
  bluetoothAccessDenied('2321', 'BLUETOOTH_PERMISSION_DENIED'), // SCPErrorBluetoothAccessDenied
  bluetoothScanTimedOut('2330', 'BLUETOOTH_SCAN_TIMED_OUT'), // SCPErrorBluetoothScanTimedOut
  bluetoothLowEnergyUnsupported('2340', 'BLUETOOTH_LOW_ENERGY_UNSUPPORTED'), // SCPErrorBluetoothLowEnergyUnsupported
  readerSoftwareUpdateFailedBatteryLow('2650', 'READER_SOFTWARE_UPDATE_FAILED_BATTERY_LOW'), // SCPErrorReaderSoftwareUpdateFailedBatteryLow
  readerSoftwareUpdateFailedInterrupted('2660', 'READER_SOFTWARE_UPDATE_FAILED_INTERRUPTED'), // SCPErrorReaderSoftwareUpdateFailedInterrupted
  cardInsertNotRead('2810', 'CARD_INSERT_NOT_READ'), // SCPErrorCardInsertNotRead
  cardSwipeNotRead('2820', 'CARD_SWIPE_NOT_READ'), // SCPErrorCardSwipeNotRead
  cardReadTimedOut('2830', 'CARD_READ_TIMED_OUT'), // SCPErrorCardReadTimedOut
  cardRemoved('2840', 'CARD_REMOVED'), // SCPErrorCardRemoved
  cardLeftInReader('2850', 'CARD_LEFT_IN_READER'), // SCPErrorCardLeftInReader
  offlinePaymentsDatabaseTooLarge('2860', 'OFFLINE_PAYMENTS_DATABASE_TOO_LARGE'), // SCPErrorOfflinePaymentsDatabaseTooLarge
  readerConnectionNotAvailableOffline('2870', 'READER_CONNECTION_NOT_AVAILABLE_OFFLINE'), // SCPErrorReaderConnectionNotAvailableOffline
  noLastSeenAccount('2880', 'NO_LAST_SEEN_ACCOUNT'), // SCPErrorNoLastSeenAccount
  amountExceedsMaxOfflineAmount('2890', 'AMOUNT_EXCEEDS_MAX_OFFLINE_AMOUNT'), // SCPErrorAmountExceedsMaxOfflineAmount
  invalidOfflineCurrency('2891', 'INVALID_OFFLINE_CURRENCY'), // SCPErrorInvalidOfflineCurrency
  missingEmvData('2892', 'MISSING_EMV_DATA'), // SCPErrorMissingEMVData
  localMobileUnsupportedDevice('2910', 'LOCAL_MOBILE_UNSUPPORTED_DEVICE'), // SCPErrorUnsupportedMobileDeviceConfiguration
  readerBusy('3010', 'READER_BUSY'), // SCPErrorReaderBusy
  readerCommunicationError('3060', 'READER_COMMUNICATION_ERROR'), // SCPErrorReaderCommunicationError
  localMobileNfcDisabled('3100', 'LOCAL_MOBILE_NFC_DISABLED'), // SCPErrorNFCDisabled
  bluetoothError('3200', 'BLUETOOTH_ERROR'), // SCPErrorBluetoothError
  bluetoothDisconnected('3230', 'BLUETOOTH_DISCONNECTED'), // SCPErrorBluetoothDisconnected
  readerConnectedToAnotherDevice('3241', 'READER_CONNECTED_TO_ANOTHER_DEVICE'), // SCPErrorBluetoothAlreadyPairedWithAnotherDevice
  readerSoftwareUpdateFailed('3800', 'READER_SOFTWARE_UPDATE_FAILED'), // SCPErrorReaderSoftwareUpdateFailed
  readerSoftwareUpdateFailedReaderError('3830', 'READER_SOFTWARE_UPDATE_FAILED_READER_ERROR'), // SCPErrorReaderSoftwareUpdateFailedReaderError
  readerSoftwareUpdateFailedServerError('3840', 'READER_SOFTWARE_UPDATE_FAILED_SERVER_ERROR'), // SCPErrorReaderSoftwareUpdateFailedServerError
  unsupportedReaderVersion('3850', 'UNSUPPORTED_READER_VERSION'), // SCPErrorUnsupportedReaderVersion
  bluetoothReconnectStarted('3890', 'BLUETOOTH_RECONNECT_STARTED'), // SCPErrorBluetoothReconnectStarted
  unexpectedSdkError('5000', 'UNEXPECTED_SDK_ERROR'), // SCPErrorUnexpectedSdkError
  declinedByStripeApi('6000', 'DECLINED_BY_STRIPE_API'), // SCPErrorDeclinedByStripeAPI
  declinedByReader('6500', 'DECLINED_BY_READER'), // SCPErrorDeclinedByReader
  customerConsentRequired('6700', 'CUSTOMER_CONSENT_REQUIRED'), // SCPErrorCommandRequiresCardholderConsent
  cardSwipeNotAvailable('6900', 'CARD_SWIPE_NOT_AVAILABLE'), // SCPErrorCardSwipeNotAvailable
  interacNotSupportedOffline('6901', 'INTERAC_NOT_SUPPORTED_OFFLINE'), // SCPErrorInteracNotSupportedOffline
  offlineAndCardExpired('6902', 'OFFLINE_AND_CARD_EXPIRED'), // SCPErrorOfflineAndCardExpired
  offlineTransactionDeclined('6903', 'OFFLINE_TRANSACTION_DECLINED'), // SCPErrorOfflineTransactionDeclined
  offlineCollectAndProcessMismatch('6904', 'OFFLINE_COLLECT_AND_PROCESS_MISMATCH'), // SCPErrorOfflineCollectAndConfirmMismatch
  stripeApiConnectionError('9000', 'STRIPE_API_CONNECTION_ERROR'), // SCPErrorNotConnectedToInternet
  requestTimedOut('9010', 'REQUEST_TIMED_OUT'), // SCPErrorRequestTimedOut
  stripeApiError('9020', 'STRIPE_API_ERROR'), // SCPErrorStripeAPIError
  stripeApiResponseDecodingError('9030', 'STRIPE_API_RESPONSE_DECODING_ERROR'), // SCPErrorStripeAPIResponseDecodingError
  connectionTokenProviderError('9050', 'CONNECTION_TOKEN_PROVIDER_ERROR'), // SCPErrorConnectionTokenProviderCompletedWithError
  connectionTokenProviderErrorWhileForwarding('9051', 'CONNECTION_TOKEN_PROVIDER_ERROR_WHILE_FORWARDING'), // SCPErrorConnectionTokenProviderCompletedWithErrorWhileForwarding
  sessionExpired('9060', 'SESSION_EXPIRED'), // SCPErrorSessionExpired
  forceOfflineWithFeatureDisabled('10107', 'FORCE_OFFLINE_WITH_FEATURE_DISABLED'), // SCPErrorOfflineBehaviorForceOfflineWithFeatureDisabled
  notConnectedToInternetAndRequireOnlineSet('10106', 'NOT_CONNECTED_TO_INTERNET_AND_REQUIRE_ONLINE_SET'), // SCPErrorNotConnectedToInternetAndOfflineBehaviorRequireOnline

  /// iOS
  connectionTokenProviderCompletedWithNothing('1510', null), // SCPErrorConnectionTokenProviderCompletedWithNothing
  connectionTokenProviderCompletedWithNothingWhileForwarding('1511', null), // SCPErrorConnectionTokenProviderCompletedWithNothingWhileForwarding
  nilPaymentIntent('1520', null), // SCPErrorNilPaymentIntent
  nilSetupIntent('1530', null), // SCPErrorNilSetupIntent
  nilRefundPaymentMethod('1540', null), // SCPErrorNilRefundPaymentMethod
  invalidRefundParameters('1550', null), // SCPErrorInvalidRefundParameters
  invalidDiscoveryConfiguration('1560', null), // SCPErrorInvalidDiscoveryConfiguration
  invalidReaderForUpdate('1570', null), // SCPErrorInvalidReaderForUpdate
  featureNotAvailableWithConnectedReader('1580', null), // SCPErrorFeatureNotAvailableWithConnectedReader
  invalidListLocationsLimitParameter('1590', null), // SCPErrorInvalidListLocationsLimitParameter
  bluetoothConnectionInvalidLocationIdParameter('1600', null), // SCPErrorBluetoothConnectionInvalidLocationIdParameter
  updatePaymentIntentUnavailableWhileOffline('1610', null), // SCPErrorUpdatePaymentIntentUnavailableWhileOffline
  updatePaymentIntentUnavailableWhileOfflineModeEnabled('1620', null), // SCPErrorUpdatePaymentIntentUnavailableWhileOfflineModeEnabled
  readerConnectionConfigurationInvalid('1630', null), // SCPErrorReaderConnectionConfigurationInvalid
  invalidLocationIdParameter('1650', null), // SCPErrorInvalidLocationIdParameter
  bluetoothConnectTimedOut('1660', null), // SCPErrorBluetoothConnectTimedOut
  bluetoothPeerRemovedPairingInformation('1670', null), // SCPErrorBluetoothPeerRemovedPairingInformation
  readerSoftwareUpdateFailedExpiredUpdate('1680', null), // SCPErrorReaderSoftwareUpdateFailedExpiredUpdate
  bluetoothConnectionFailedBatteryCriticallyLow('1690', null), // SCPErrorBluetoothConnectionFailedBatteryCriticallyLow
  commandNotAllowed('1700', null), // SCPErrorCommandNotAllowed
  passcodeNotEnabled('1710', null), // SCPErrorPasscodeNotEnabled
  commandNotAllowedDuringCall('1720', null), // SCPErrorCommandNotAllowedDuringCall
  invalidAmount('1730', null), // SCPErrorInvalidAmount
  invalidCurrency('1740', null), // SCPErrorInvalidCurrency
  appleBuiltInReaderTOSAcceptanceRequiresiCloudSignIn('1750', null), // SCPErrorAppleBuiltInReaderTOSAcceptanceRequiresiCloudSignIn
  appleBuiltInReaderTOSAcceptanceCanceled('1760', null), // SCPErrorAppleBuiltInReaderTOSAcceptanceCanceled
  incompatibleReader('1770', null), // SCPErrorIncompatibleReader
  unknownReaderIpAddress('1780', null), // SCPErrorUnknownReaderIpAddress
  internetConnectTimeOut('1790', null), // SCPErrorInternetConnectTimeOut
  connectFailedReaderIsInUse('1800', null), // SCPErrorConnectFailedReaderIsInUse
  readerNotAccessibleInBackground('1810', null), // SCPErrorReaderNotAccessibleInBackground
  appleBuiltInReaderFailedToPrepare('1820', null), // SCPErrorAppleBuiltInReaderFailedToPrepare
  appleBuiltInReaderDeviceBanned('1830', null), // SCPErrorAppleBuiltInReaderDeviceBanned
  appleBuiltInReaderTOSNotYetAccepted('1840', null), // SCPErrorAppleBuiltInReaderTOSNotYetAccepted
  appleBuiltInReaderTOSAcceptanceFailed('1850', null), // SCPErrorAppleBuiltInReaderTOSAcceptanceFailed
  appleBuiltInReaderMerchantBlocked('1860', null), // SCPErrorAppleBuiltInReaderMerchantBlocked
  appleBuiltInReaderInvalidMerchant('1870', null), // SCPErrorAppleBuiltInReaderInvalidMerchant
  unexpectedReaderError('1880', null), // SCPErrorUnexpectedReaderError
  refundFailed('1890', null), // SCPErrorRefundFailed
  internalNetworkError('1900', null), // SCPErrorInternalNetworkError
  connectionTokenProviderTimedOut('1910', null), // SCPErrorConnectionTokenProviderTimedOut
  readerConnectionOfflineLocationMismatch('2871', null), // SCPErrorReaderConnectionOfflineLocationMismatch
  bluetoothDisabled('2320', null), // SCPErrorBluetoothDisabled

  /// Android
  androidApiLevelError(null, 'ANDROID_API_LEVEL_ERROR'),
  collectInputsApplicationError(null, 'COLLECT_INPUTS_APPLICATION_ERROR'),
  collectInputsInvalidParameter(null, 'COLLECT_INPUTS_INVALID_PARAMETER'),
  collectInputsTimedOut(null, 'COLLECT_INPUTS_TIMED_OUT'),
  featureNotEnabledOnAccount(null, 'FEATURE_NOT_ENABLED_ON_ACCOUNT'),
  localMobileDebugNotSupported(null, 'LOCAL_MOBILE_DEBUG_NOT_SUPPORTED'),
  localMobileDeviceTampered(null, 'LOCAL_MOBILE_DEVICE_TAMPERED'),
  localMobileLibraryNotIncluded(null, 'LOCAL_MOBILE_LIBRARY_NOT_INCLUDED'),
  localMobileUnsupportedAndroidVersion(null, 'LOCAL_MOBILE_UNSUPPORTED_ANDROID_VERSION'),
  locationConnectionNotAvailableOffline(null, 'LOCATION_CONNECTION_NOT_AVAILABLE_OFFLINE'),
  missingRequiredParameter(null, 'MISSING_REQUIRED_PARAMETER'),
  offlineModeUnsupportedAndroidVersion(null, 'OFFLINE_MODE_UNSUPPORTED_ANDROID_VERSION'),
  offlinePaymentIntentNotFound(null, 'OFFLINE_PAYMENT_INTENT_NOT_FOUND'),
  onlinePinNotSupportedOffline(null, 'ONLINE_PIN_NOT_SUPPORTED_OFFLINE'),
  testCardInLivemode(null, 'TEST_CARD_IN_LIVEMODE'),
  unexpectedOperation(null, 'UNEXPECTED_OPERATION'),
  unsupportedOperation(null, 'UNSUPPORTED_OPERATION'),
  usbDisconnected(null, 'USB_DISCONNECTED'),
  usbDiscoveryTimedOut(null, 'USB_DISCOVERY_TIMED_OUT'),
  usbPermissionDenied(null, 'USB_PERMISSION_DENIED'),
  usbReconnectStarted(null, 'USB_RECONNECT_STARTED');

  final String? iosCode;
  final String? androidCode;

  const TerminalExceptionCode([this.iosCode, this.androidCode]);
}

class TerminalException {
  final String rawCode;
  final String? message;
  final String? details;

  late final TerminalExceptionCode code =
      TerminalExceptionCode.values.firstWhereOrNull((e) => e.iosCode == rawCode || e.androidCode == rawCode || e.name == rawCode.camelCase) ?? TerminalExceptionCode.unknown;

  TerminalException({
    required this.rawCode,
    required this.message,
    required this.details,
  });

  @override
  String toString() => ['$runtimeType: $rawCode', message, details].nonNulls.join('\n');
}

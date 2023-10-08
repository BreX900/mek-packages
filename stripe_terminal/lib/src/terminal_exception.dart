import 'package:mek_stripe_terminal/src/models/payment_intent.dart';
import 'package:one_for_all/one_for_all.dart';

@SerializableEnum(hostToFlutter: true)
enum TerminalExceptionCode {
  // Flutter Plugin

  /// See te message in [TerminalException]
  unknown,

  /// See [message] field
  readerNotRecovered(
      'Call this method with the [Reader] returned from the [StripeTerminal.discoverReaders] method.'),

  /// See [message] field
  paymentIntentNotRecovered(
      'Call this method with the [PaymentIntent] returned from the [StripeTerminal.createPaymentIntent] '
      'or [StripeTerminal.retrievePaymentIntent] methods.'),

  /// See [message] field
  setupIntentNotRecovered(
      'Call this method with the [SetupIntent] returned from the [StripeTerminal.createSetupIntent] '
      'or [StripeTerminal.retrieveSetupIntent] methods.'),

  // Android/IOS sdk

  /// Only Android. Cancelling an operation failed
  cancelFailed,

  /// No reader is connected. Connect to a reader before trying again.
  notConnectedToReader,

  /// Already connected to a reader.
  alreadyConnectedToReader,

  /// Only IOS. This error indicates that Bluetooth is turned off, and the user should use Settings to turn Bluetooth on.
  /// If Bluetooth is on but the app does not have permission to use it, a different error (SCPErrorBluetoothError) occurs.
  bluetoothDisabled,

  /// Android: Either android.permission.BLUETOOTH_CONNECT or android.permission.BLUETOOTH_SCAN must be enabled.
  /// IOS: Bluetooth is turned on on the device, but access to Bluetooth has been denied for your app.
  ///   The user needs to go to Settings > Your App > and enable Bluetooth
  bluetoothPermissionDenied,

  /// [StripeTerminal.confirmPaymentIntent] was called with an unknown or invalid PaymentIntent.
  /// You must confirm a payment after collecting a payment method. Successfully confirmed payments
  /// may not be confirmed again.
  confirmInvalidPaymentIntent,

  /// A [PaymentIntent] or [SetupIntent] was referenced using an invalid client secret.
  invalidClientSecret,

  /// Only IOS. [StripeTerminal.installUpdate] was passed an update that is for a different reader. ù
  ///   Updates can only be installed on the reader that was connected when the update was announced.
  invalidReaderForUpdate,

  /// Only Android. The Terminal operation that was called isn't supported for this device type
  unsupportedOperation,

  /// Only Android. The Terminal operation shouldn't have been called at this time.
  unexpectedOperation,

  /// [StripeTerminal.connectBluetoothReader] was called from an unsupported version of the SDK.
  /// In order to fix this you will need to update your app to the most recent version of the SDK.
  /// We suggest you prompt your user to update their app, assuming there is an update app version
  /// with a supported version of our SDK.
  unsupportedSdk,

  /// Only IOS. This feature is currently not available for the selected reader.
  featureNotAvailableWithConnectedReader,

  /// Only Android. User denied USB access when requested by the SDK.
  usbPermissionDenied,

  /// Only Android. Scanning for USB devices timed out.
  usbDiscoveryTimedOut,

  /// Android:
  /// - MISSING_REQUIRED_PARAMETER: A parameter that is required for your Terminal configuration is missing.
  /// - COLLECT_INPUTS_INVALID_PARAMETER: Error reported when invalid parameters are used while processing a collect inputs operation.
  /// IOS:
  /// - InvalidRefundParameters: The RefundParameters object has invalid values. The Charge
  /// ID (ch_123abc) can be found on the PaymentIntent object, which you should get from your backend.
  /// - InvalidListLocationsLimitParameter: The ListLocationsParameters object has invalid values.
  /// - BluetoothConnectionInvalidLocationIdParameter: The locationId parameter to
  ///   BluetoothConnectionConfiguration is required but a valid one was not provided.
  /// - InvalidLocationIdParameter: The provided location ID parameter was invalid.
  /// - ReaderConnectionConfigurationInvalid: An invalid ConnectionConfiguration was passed through connect.
  invalidParameter,

  /// A required parameter was invalid or missing.
  invalidRequiredParameter,

  /// An invalid usage of eligibleAmount or skipTipping was passed into collect.
  invalidTipParameter,

  /// Only Android: The Android device the SDK is running on is unsupported by the local mobile library.
  /// Reasons for this might include:
  /// - Device is missing a NFC reader
  /// - Device does not have a hardware keystore
  localMobileUnsupportedDevice,

  /// Only Android. The SDK is running on a version of Android older
  localMobileUnsupportedOperatingSystemVersion,

  /// Only Android. The Android device the SDK is running on has been tampered. Some examples of tampering include:
  /// - unlocking the bootloader or rooting the device
  /// - replacing factory-provisioned hardware in the device (ex. the motherboard)
  localMobileDeviceTampered,

  /// Only Android. The SDK is running in a debuggable application. This is not supported for
  /// security and compliance reasons. Please test the Tap to Pay on Android SDK with a simulated
  /// version of the reader by setting DiscoveryConfiguration.isSimulated to true.
  localMobileDebugNotSupported,

  /// Only Android. The Android device the SDK is running on does not support offline mode.
  offlineModeUnsupportedOperatingSystemVersion,

  /// The command was canceled by your app.
  canceled,

  /// Access to location services is currently disabled. This may be because:
  /// - The user disabled location services in the system settings.
  /// - The user denied access to location services for your app.
  /// - The user’s device is in Airplane Mode and unable to gather location data.
  locationServicesDisabled,

  /// Scanning for bluetooth devices timed out.
  bluetoothScanTimedOut,

  /// Bluetooth Low Energy is unsupported on this device. Use a different device that
  /// supports BLE (also known as Bluetooth 4.0)
  bluetoothLowEnergyUnsupported,

  /// Updating the reader software failed because the reader’s battery is too low.
  /// Charge the reader before trying again.
  readerSoftwareUpdateFailedBatteryLow,

  /// Updating the reader software failed because the update was interrupted.
  readerSoftwareUpdateFailedInterrupted,

  /// Only IOS. Updating the reader software failed because the update has expired.
  /// Please disconnect and reconnect from the reader to retrieve a new update.
  readerSoftwareUpdateFailedExpiredUpdate,

  /// Only IOS. The reader has a critically low battery and cannot connect to the device.
  /// Charge the reader before trying again.
  bluetoothConnectionFailedBatteryCriticallyLow,

  /// The card is not a chip card.
  cardInsertNotRead,

  /// The swipe could not be read.
  cardSwipeNotRead,

  /// Reading a card timed out.
  cardReadTimedOut,

  /// The card was removed during the transaction
  cardRemoved,

  /// The cardholder must give consent in order for this operation to succeed.
  customerConsentRequired,

  /// A card can only be used for one transaction, and must be removed after being read. Otherwise,
  /// subsequent collectPaymentMethod attempts will fail with this error.
  /// Your terminal delegate will receive [ReaderDelegate.onReportReaderEvent] with
  /// [ReaderEventCardRemoved] when the card is removed.
  /// The Chipper 2x and WisePad 3 will beep until the card is removed.
  cardLeftInReader,

  /// Android: The connected account is not enabled to use the specified feature. Retry without
  ///   the parameter in question or contact Stripe support to enable the feature on this account.
  /// IOS: This feature is not currently available.
  featureNotEnabledOnAccount,

  /// Only IOS. The mobile device on which the app is running must have a passcode set.
  passcodeNotEnabled,

  /// Only IOS. The card reader cannot be used while a phone call is active.
  commandNotAllowedDuringCall,

  /// Only IOS. An attempt was made to charge an amount not supported by the reader.
  invalidAmount,

  /// Only IOS. An attempt was made to charge an amount in a currency not supported by the reader.
  invalidCurrency,

  /// Only IOS. Failed to accept reader-specific terms of service because there is no iCloud user
  /// signed in. Direct the user to sign into an appropriate iCloud account via iOS Settings and try again.
  appleBuiltInReaderTOSAcceptanceRequiresiCloudSignIn,

  /// Only IOS. The user cancelled reader-specific terms of service acceptance.
  appleBuiltInReaderTOSAcceptanceCanceled,

  /// Only IOS. Preparing the Apple Built-In reader to collect payments failed. Try connecting again.
  appleBuiltInReaderFailedToPrepare,

  /// Only IOS. This device cannot be used to process using the Apple Built-In reader as it has been banned.
  appleBuiltInReaderDeviceBanned,

  /// Only IOS. The operation could not be completed because the reader-specific terms of service
  /// have not yet been accepted. Try connecting again.
  appleBuiltInReaderTOSNotYetAccepted,

  /// Only IOS. Failed to accept reader-specific terms of service using the signed-in Apple ID.
  /// Ensure the Apple ID is still active and in a good standing and try again.
  appleBuiltInReaderTOSAcceptanceFailed,

  /// Only IOS. This merchant account cannot be used with Apple Built-In reader as it has been blocked.
  appleBuiltInReaderMerchantBlocked,

  /// Only IOS. This merchant account cannot be used with the Apple Built-In reader as it is invalid.
  appleBuiltInReaderInvalidMerchant,

  /// The reader is busy.
  readerBusy,

  /// Only IOS. An incompatible reader was detected. You can only use the Stripe Terminal iOS SDK
  /// with one of Stripe’s pre-certified readers.
  incompatibleReader,

  /// Could not communicate with the reader.
  readerCommunicationError,

  /// Only IOS. The reader returned from discovery does not have an IP address and cannot be
  /// connected to. The IP address should have been set by the SDK during registration of
  /// the reader. Try registering the reader again.
  unknownReaderIpAddress,

  /// Only IOS. Connecting to reader over the internet timed out. Make sure your device and reader
  /// are on the same Wifi network and your reader is connected to the Wifi network.
  internetConnectTimeOut,

  /// Only IOS. Connecting to the reader failed because it is currently in use and [failIfInUse] was set to true.
  /// Try to connect again with failIfInUse:false, or choose a different reader.
  /// A reader is in use while it’s collecting a payment.
  connectFailedReaderIsInUse,

  /// Only IOS. An attempt was made to interact with the reader while the the app is in the background.
  readerNotAccessibleInBackground,

  /// Generic Bluetooth error.
  bluetoothError,

  /// Only IOS. Connecting to the bluetooth device timed out. Make sure the device is powered on,
  /// in range, and not connected to another app or device. If this error continues to occur,
  /// you may need to charge the device.
  bluetoothConnectTimedOut,

  /// The Bluetooth device was disconnected unexpectedly.
  bluetoothDisconnected,

  /// Only IOS. Bluetooth pairing error, the reader has removed this device pairing information.
  /// Forget the reader in iOS Settings.
  bluetoothPeerRemovedPairingInformation,

  /// Only IOS. The Bluetooth reader is already paired to another device. The Bluetooth reader
  /// must have its pairing reset to connect to this device.
  bluetoothAlreadyPairedWithAnotherDevice,

  /// The Bluetooth reader has disconnected and we are attempting to reconnect.
  bluetoothReconnectStarted,

  /// Only Android. The USB device was disconnected unexpectedly.
  usbDisconnected,

  /// Only Android. The USB device was disconnected unexpectedly, reconnecting.
  usbReconnectStarted,

  /// Only Android. The reader cannot be reached because it is already connected to a different device.
  readerConnectedToAnotherDevice,

  /// Generic reader software update error.
  readerSoftwareUpdateFailed,

  /// Updating the reader software failed because there was an error communicating with the reader.
  readerSoftwareUpdateFailedReaderError,

  /// Updating the reader software failed because there was an error communicating with the update server.
  readerSoftwareUpdateFailedServerError,

  /// NFC functionality is disabled. Among other things, it may indicate that the app does not have
  /// permission to use NFC.
  nfcDisabled,

  /// [StripeTerminal.confirmPaymentIntent] was called from a reader with an unsupported reader version.
  /// You will need to update your reader to the most recent version in order to accept payments.
  /// We suggest you prompt your user to disconnect and reconnect their reader in order to update the reader.
  unsupportedReaderVersion,

  /// Unexpected SDK error.
  unexpectedSdkError,

  /// Only IOS. Unexpected reader error.
  unexpectedReaderError,

  /// The Stripe API declined the transaction. Inspect the error’s requestError property for more
  /// information about the decline, including the decline code.
  declinedByStripeApi,

  /// The reader declined the transaction. Try another card.
  declinedByReader,

  /// Only IOS. The SDK is not connected to the internet.
  notConnectedToInternet,

  /// The underlying request timed out.
  requestTimedOut,

  /// Only android. Failure to connect to Stripe's API.
  stripeApiConnectionError,

  /// Only android. The underlying request returned an API error.
  stripeApiError,

  /// The API response from Stripe could not be decoded.
  stripeApiResponseDecodingError,

  /// Only IOS. Generic network error
  internalNetworkError,

  /// Your implementation of [StripeTerminal.getInstance:fetchToken] throws an error.
  connectionTokenProviderError,

  /// The current session has expired and the reader must be disconnected and reconnected. The SDK
  /// will attempt to auto-disconnect for you and you should instruct your user to reconnect it.
  /// [StripeTerminal.onUnexpectedReaderDisconnect] will be called if the SDK is able to successfully
  /// auto-disconnect. If it does not successfully auto-disconnect (onUnexpectedReaderDisconnect will
  /// not be called and StripeTerminal.connectionStatus will still be ConnectionStatusConnected)
  /// you can attempt again via [StripeTerminal.disconnectReader] or you can instruct your user
  /// to disconnect manually by turning the reader off.
  ///
  /// NOTE: This error will only occur in one of the following calls: [StripeTerminal.createPaymentIntent],
  /// [StripeTerminal.retrievePaymentIntent], [StripeTerminal.confirmPaymentIntent], and [StripeTerminal.cancelPaymentIntent].
  sessionExpired,

  /// Android:
  /// - ANDROID_API_LEVEL_ERROR: The SDK is running on an unsupported version of Android. This occurs
  ///     when an integrator overrides minSdkVersion.
  /// IOS:
  /// - UnsupportedMobileDeviceConfiguration: The mobile device on which the app is running is in an
  ///     unsupported configuration. Verify that the device is running a supported version of iOS
  ///     and that the mobile device has the capability you are attempting to use.
  unsupportedMobileDeviceConfiguration,

  /// Only IOS: The command was not permitted to execute by the operating system.
  ///   This can happen for a number of reasons, but most commonly:
  ///   - Your application does not have the necessary entitlements.
  ///   - Your application bundle is invalid.
  commandNotAllowed,

  /// Error reported when the [PaymentIntent]’s amount exceeds the configured allowable maximum amount
  /// for offline transactions.
  amountExceedsMaxOfflineAmount,

  /// Error reported when the offline payments database has too many records.
  /// The Terminal should be brought back online to forward payments before collecting more.
  offlinePaymentsDatabaseTooLarge,

  /// Connecting to the reader failed because the most recently connected account hasn’t connected
  /// to a reader of this type while online. To connect to a reader offline, the SDK must have
  /// connected to a reader of the same type and location within the past 90 days.
  readerConnectionNotAvailableOffline,

  /// Only IOS. Connecting to the reader failed because the reader was most recently connected
  /// to a different location while online.
  readerConnectionOfflineLocationMismatch,

  /// Only Android. Connecting to the reader at this location failed. To connect a reader at a
  /// specified location while offline, a reader must have been connected online at that location
  /// within the last several weeks.
  locationConnectionNotAvailableOffline,

  /// The SDK has not activated a reader online yet, meaning there is no account with which
  /// the SDK can associate offline operations.
  noLastSeenAccount,

  /// Error reported when the PaymentIntent’s currency is not configured as a valid currency for offline transactions.
  invalidOfflineCurrency,

  /// Only IOS. The refund failed. The customer’s bank or card issuer was unable to process
  /// it correctly (e.g., a closed bank account or a problem with the card)
  refundFailed,

  /// Error reported when collectPaymentMethod or confirmPaymentIntent was called while offline
  /// and the card was read using the swipe method.
  /// Payment method data collected using the Swipe card read method cannot be processed online.
  /// Retry the payment by calling collectPaymentMethod() again.
  cardSwipeNotAvailable,

  /// Error reported when collectPaymentMethod or confirmPaymentIntent was called while offline
  /// and the presented card was an Interac card.
  /// Retry the payment by calling collectPaymentMethod() again.
  interacNotSupportedOffline,

  /// Only Android. Error reported when confirmPaymentIntent was called while offline and the
  /// presented card was authenticated with an online PIN. Retry the payment by calling collectPaymentMethod() again.
  onlinePinNotSupportedOffline,

  /// Confirming a payment while offline and the card was identified as being expired.
  offlineAndCardExpired,

  /// Confirming a payment while offline and the card’s verification failed.
  /// Retry the payment by calling collectPaymentMethod() again and try a different card if the error persists.
  offlineTransactionDeclined,

  /// Error reported when collectPaymentMethod was called while online and confirmPaymentIntent was called while offline.
  /// Retry the payment by calling collectPaymentMethod() again.
  offlineCollectAndConfirmMismatch,

  /// Error reported when a test payment attempted to forward while operating in livemode.
  /// The testmode transaction will be deleted.
  forwardingTestModePaymentInLiveMode,

  /// Error reported when a live payment attempted to forward while operating in testmode.
  /// Reconnect to this account with livemode keys to resume forwarding livemode transactions.
  forwardingLiveModePaymentInTestMode,

  /// Only Android. Error reported when processing a PaymentIntent that doesn't have a corresponding
  /// create request. In this situation, the PaymentIntent should be created again. This would typically happen if:
  /// 1. The PaymentIntent was created offline.
  /// 2. The SDK re-established connection to Stripe's backend and successfully forwarded the PaymentIntent.
  /// 3. Your application attempted to process the PaymentIntent, but it was already forwarded.
  offlinePaymentIntentNotFound,

  /// Only IOS. Error reported when calling collectPaymentMethod with an offline PaymentIntent
  /// and a CollectConfiguration with updatePaymentIntent set to true.
  updatePaymentIntentUnavailableWhileOffline,

  /// Only IOS. Error reported when calling collectPaymentMethod with offline mode enabled and
  /// a CollectConfiguration with updatePaymentIntent set to true.
  updatePaymentIntentUnavailableWhileOfflineModeEnabled,

  /// The reader failed to read the data from the presented payment method. If you encounter
  /// this error repeatedly, the reader may be faulty.
  missingEmvData,

  /// Error reported while forwarding offline payments when the connection token provider neither
  /// returns a token nor an error.
  connectionTokenProviderErrorWhileForwarding,

  /// Only IOS. Your implementation of [StripeTerminal.getInstance:fetchToken] did not call
  /// the provided completion block within 60 seconds.
  connectionTokenProviderTimedOut,

  /// Error reported when forwarding stored offline payments. The fetched connection token
  /// was generated with a different account ID than the stored payment.
  accountIdMismatchWhileForwarding,

  /// Error reported when a [PaymentIntent] was created with [OfflineBehaviorForceOffline]
  /// and the reader in use is not configured to operate offline. Use the Terminal Configuration
  /// API to enable the functionality or retry with another value for OfflineBehavior.
  offlineBehaviorForceOfflineWithFeatureDisabled,

  /// Error reported when the device is offline and the [PaymentIntent] was created with
  /// offlineBehavior set to requireOnline.
  notConnectedToInternetAndOfflineBehaviorRequireOnline,

  /// The card used is a known test card and the SDK is operating in livemode.
  testCardInLiveMode,

  /// An unexpected error occurred when using collectInputs
  collectInputsApplicationError,

  /// Error reported when a timeout occurs while processing a collect inputs operation.
  collectInputsTimedOut;

  final String? message;

  const TerminalExceptionCode([this.message]);
}

@SerializableClass(hostToFlutter: true)
class TerminalException {
  final TerminalExceptionCode code;
  final String message;
  final String? stackTrace;
  final PaymentIntent? paymentIntent;
  final Object? apiError;

  TerminalException({
    required this.code,
    required String message,
    required this.stackTrace,
    required this.paymentIntent,
    required this.apiError,
  }) : message = (message.isEmpty ? null : code.message) ?? '';

  @override
  String toString() => [
        '$runtimeType: ${code.name}',
        message,
        paymentIntent,
        apiError,
        stackTrace,
      ].nonNulls.join('\n');
}

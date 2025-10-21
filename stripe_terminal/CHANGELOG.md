
## 4.6.2
- feat(terminal): Added `id`, `ipAddress`, and `networkStatus` fields to the `Reader` object. Added by [@mahmoud-othmane](https://github.com/mahmoud-othmane).
- build: bumped `mek_data_class` package to `2.0.0`

## 4.6.1
- feat: added support for optional ios parameters on internet and tap-to-pay connection configurations

## 4.6.0
- feat: bumped android and ios sdk version to `4.6.0`

## 4.4.1
- feat: added `allowRedisplay` param on `collectPaymentMethod` method

## 4.4.0
- feat: bumped android and ios sdk version to `4.4.0`
- fix(ios): fixed wrong mapping tap to pay configuration
- feat(android): configure tap to pay UX. Thanks [@hrueger](https://github.com/hrueger)

## 4.0.4
- chore(android): when plugin si attached to activity the `Terminal.onCreate` method is called [#104](https://github.com/BreX900/mek-packages/issues/104)

## 4.0.3
- chore(android): removed permission check when initializing terminal

## 4.0.2
- build: updated `meta` to `1.15.0` and `one_for_all` to `1.1.1` dependency
- build: updated `dart` constraints to `>=3.5.0 <4.0.0` and `flutter` to `>=3.24.0`
- docs: updated README.md file

## 4.0.1

- docs: updated documentation

## 4.0.0
- feat: added support to [ReaderDelegate.onAcceptTermsOfService] method listener
- fix(android): execute reader disconnect after hot restart in main thread
- build!: Bumped [Android](https://github.com/stripe/stripe-terminal-android/blob/master/CHANGELOG.md#410---2024-11-18)
  sdk version to `4.1.0` and [IOS](https://github.com/stripe/stripe-terminal-android/blob/master/CHANGELOG.md#410---2024-11-18)
  sdk version to `4.1.0`. Please watch the official CHANGELOG.md to know the breaking changes
- refactor!: Aligned terminal initialization with official native sdk. Now you will need to initialize the sdk by
  calling `Terminal.initTerminal`

## 3.8.1
- doc: updated README.md file adding official documentation links

## 3.8.0
- build: Bumped [Android](https://github.com/stripe/stripe-terminal-android/blob/master/CHANGELOG.md#3101---2024-11-05)
  sdk version to `3.10.1` and [IOS](https://github.com/stripe/stripe-terminal-android/blob/master/CHANGELOG.md#3101---2024-11-05)
  sdk version to `3.9.1`
- feat: Added to `Terminal.collectPaymentMethod` method the `requestDynamicCurrencyConversion` and `surchargeNotice` params
- feat: Added to `TerminalExceptionCode` enum the `allowRedisplayInvalid`, `surchargingNotAvailable`, `surchargeNoticeRequiresUpdatePaymentIntent`,
  `surchargeUnavailableWithDynamicCurrencyConversion` values
- build: Bumped android sdk compile version to `35` 

## 3.7.0
- chore: Bumped [Android](https://github.com/stripe/stripe-terminal-android/blob/master/CHANGELOG.md#371---2024-07-05)
  and [IOS](https://github.com/stripe/stripe-terminal-ios/blob/master/CHANGELOG.md#370-2024-06-24) sdks versions to
  `3.5.0`

## 3.5.0
- chore: Bumped [Android](https://github.com/stripe/stripe-terminal-android/blob/master/CHANGELOG.md#350---2024-04-09)
  and [IOS](https://github.com/stripe/stripe-terminal-ios/blob/master/CHANGELOG.md#350-2024-04-12) sdks versions to
  `3.5.0`. Fix [#67](https://github.com/BreX900/mek-packages/issues/67) thanks @jacopofranza
- fix(ios): Pass connected account to ios platform. Thanks @jermaine-uome

## 3.4.0
- chore: Bumped [Android](https://github.com/stripe/stripe-terminal-android/blob/master/CHANGELOG.md#340---2024-03-04)
  and [IOS](https://github.com/stripe/stripe-terminal-ios/blob/master/CHANGELOG.md#340-2024-03-04) sdks versions to `3.4.0`
- refactor: Renamed `TerminalExceptionCode.bluetoothConnectionFailedBatteryCriticallyLow` to `TerminalExceptionCode.readerBatteryCriticallyLow`
- feat: Added new `TerminalExceptionCode.readerMissingEncryptionKeys`. Returned in a rare condition
  where the reader is missing the required keys to encrypt payment method data. The reader will
  disconnect if this error is hit. Reconnecting to the reader should re-install the keys.
- feat: Added a `DisconnectReason` to the `ReaderReconnectionDelegate.onReaderReconnectStarted2` callback.
- build(android): Increased the minimum API version requirement to 30 (Android 11).
- build(android): SDKs have been updated to depend on [Kotlin 1.9.10](https://github.com/JetBrains/kotlin/releases/tag/v1.9.10).
- build(ios): The SDK now requires that a `NSBluetoothAlwaysUsageDescription` key be present in your
  app's Info.plist instead of a `NSBluetoothPeripheralUsageDescription` key.

## 3.2.1
- chore: Bumped [Android](https://github.com/stripe/stripe-terminal-android/blob/master/CHANGELOG.md#321---2023-12-18)
  and [IOS](https://github.com/stripe/stripe-terminal-ios/blob/master/CHANGELOG.md#321-2023-12-18) sdks versions to `3.2.1`

## 3.2.0
- feat: Added to `Terminal.setSimulatorConfiguration` method
- chore(android): Replaced `compileSdkVersion` with `compileSdk` and bumped version to `34`
- chore(android): Bumped tools gradle version to `8.1.3`
- feat: Bumped [Android](https://github.com/stripe/stripe-terminal-android/blob/master/CHANGELOG.md#320---2023-11-15)
  and [IOS](https://github.com/stripe/stripe-terminal-ios/blob/master/CHANGELOG.md#320-2023-11-17) sdks versions to `3.2.0`
- feat: Added to `PaymentIntent` class `charges`, `paymentMethod`, `amountDetails` properties

## 3.1.2
- fix: Fixed incorrect Terminal instance access when unmounting the plugin from the engine

## 3.1.1
- fix(android): Fixed `Terminal.discoverReaders` method errors not being propagated
- fix: Fixed `Terminal.discoverReaders` method errors are not mapped to `TerminalException`
- fix: Fixed `Terminal.supportsReadersOfType` to support deviceType to null for UNKNOWN deviceType on android
- fix: Fixed `TerminalException.message` was not properly mapped

## 3.1.0
- feat: Mapped more exception codecs: Android (`collectInputsUnsupported`), IOS (`readerConnectionOfflineNeedsUpdate`, 
  `encryptionKeyFailure`, `encryptionKeyStillInitializing`)
- feat: Allow to customize tipping on `Terminal.collectPaymentMethod` method
- feat: Allow to update payment intent on `Terminal.collectPaymentMethod` method
- feat: Beta: Allow customer-initiated cancellation for PaymentIntent, SetupIntent, and Refund payment method collection
  with internet readers. See customerCancellationEnabled: on collectPaymentMethod, collectSetupIntentPaymentMethod, and 
  collectRefundPaymentMethod Terminal methods. Note: This feature requires reader software version 2.17 or later to be
  installed on your internet reader. Please contact us if you want to support customer-initiated cancellation.
- fix(android): Fixes TapToPay error "Must have a country code to connect to reader" [#29](https://github.com/BreX900/mek-packages/issues/29)
- feat: Bumped [Android](https://github.com/stripe/stripe-terminal-android/blob/master/CHANGELOG.md#310---2023-10-10) 
  and [IOS](https://github.com/stripe/stripe-terminal-ios/blob/master/CHANGELOG.md#310-2023-10-10) sdks versions to `3.1.0`

## 3.0.0
- fix: Attached the delegate reader before trying the connection
- refactor: Renamed `StripeTerminal` class to `Terminal`. The name has been aligned with the native SDKs.
- docs: Added docs to all `TerminalExceptionCode` enum values
- feat: Added to `TerminalException` class a updated `PaymentIntent` and `ApiError`
- feat: Mapped all Android and IOS sdk errors to `TerminalExceptionCode` enum

*BREAKING CHANGES*
- refactor: Removed handoff, localMobile, bluetooth and usb `*ReaderDelegate` in favour of `PhysicalReaderDelegate`
- refactor: Now `PaymentIntent.captureMethod` is a Enum `CaptureMethod`
- refactor: Now `PaymentIntent.confirmationMethod` is a Enum `ConfirmationMethod`
- refactor: Now `PaymentIntent.setupFutureUsage` is a Enum `PaymentIntentUsage`
- refactor: Renamed on `PaymentIntent`: `application` to `applicationId`, `customer` to `customerId`, `invoice` to `invoiceId`, `review` to `reviewId`
- fix: Added support on `PaymentIntentStatus` to `requiresAction` value
- refactor: Now `PaymentIntentParameters.setupFutureUsage` is a Enum `PaymentIntentUsage`
- refactor: Renamed on `SetupAttempt`: `onBehalfOfId` to `onBehalfOf`
- refactor: Removed `TerminalException.rawCode` in favour of `TerminalException.code` enum field

## 3.0.0-dev.1
- docs: Added docs to `PaymentIntent` and `PaymentIntentParams` classes and all daughter classes
- docs: Added docs to `SetupIntent` class and all daughter classes
- docs: Added docs to all `Saving payment details for later use` methods on `StripeTerminal` class
- docs: Added docs to all `Display information to customers` methods on `StripeTerminal` class

## 3.0.0-dev
- fix(ios): Fixes incorrect checking `null` values from flutter
- feat: added more parameters to `PaymentIntentParams` class
- build(android): The `minSdkVersion` has been updated to 26. This means that the SDK will no longer support devices running Android 7.1.2 (Nougat) or earlier. Older devices can continue to use the 2.x versions of the SDK while on the maintenance schedule.
- feat: Added to `Reader` class the `location` field.
- fix(android): `Terminal.onUnexpectedReaderDisconnect` will be emit if a command cannot be sent to an internet reader. Previously, this callback was only invoked when a periodic status check failed.
- refactor: Removed `moto` param on `Terminal.startCollectPaymentMethod` method
- fix(android): For readers that require updates to be installed upon connecting, `Terminal.onConnectionStatusChange` will now be emitted with `connected` _after_ the updates complete successfully, not before.

*BREAKING CHANGES*
- feat: `ReconnectionDelegate` methods now provide the instance of the `Reader` that is being reconnected.
- refactor: Deprecated classes and members have been replaced or removed:
    - `CardDetails.fingerprint` and `CardPresentDetails.fingerprint` have been removed from mobile SDKs. You will still be able to access the fingerprint server-side.
- refactor: `DiscoveryConfiguration` has been converted to a sealed type, instead of relying on the `DiscoveryMethod` enum to disambiguate different discovery methods.
- refactor: `Terminal.processPayment` has been renamed to `Terminal.confirmPaymentIntent`.
- refactor: `Terminal.processRefund` has been renamed to `Terminal.confirmRefund`.
- refactor: Removed `embedded` readers support 
- refactor: `Terminal.readReusableCard` has been removed. This functionality is replaced by [Setup Intents](https://stripe.com/docs/terminal/features/saving-cards/save-cards-directly?terminal-sdk-platform=android).

## 2.1.4
- fix(ios): fix: store readers after discovery, otherwise lookup for connection will always fail. Thanks [@Kuama-IT](https://github.com/Kuama-IT)
- fix(ios): TimeInterval to Int inside DateTimeDartApiCodec. Thanks [@Kuama-IT](https://github.com/Kuama-IT)
- fix(ios): Error codes are correctly transmitted to dart. Thanks [@Kuama-IT](https://github.com/Kuama-IT)

## 2.1.3
- fix(ios): Fixed discoveryReaders method, it does not emit any readers and the new stream was immediately closed on subsequent invocations

## 2.1.2
- fix(ios): Executed fetch token and more actions on main thread

## 2.1.0
- docs: Documented readers (methods, classes) and payment intents (methods)
- feat: added `Readers.batteryStatus` field

## 2.0.0
- feat: added support to `getPaymentStatus`
- feat: added support to `clearCachedCredentials`
- feat: added support to `collectRefundPaymentMethod` and `processRefund`
- feat: added support to `createSetupIntent`, `retrieveSetupIntent`, `collectSetupIntentPaymentMethod`, `confirmSetupIntent` and `cancelSetupIntent`
- feat: added support to `createPaymentIntent` and `cancelPaymentIntent`
- chore: update android StripeTerminal dependency to 2.23.0
- chore: update ios StripeTerminal dependency to 2.23.1

**Braking Changes**
- refactor: removed `liveMode` on `PaymentIntent` and `PaymentMethod` classes, not supported on ios
- refactor: renamed `PaymentMethod.cardDetails` to `PaymentMethod.card`
- refactor: renamed `connectionStatus` to `getConnectionStatus` and `connectedReader` to `getConnectedReader` on StripeTerminal class

## 1.0.0
- Initial version.

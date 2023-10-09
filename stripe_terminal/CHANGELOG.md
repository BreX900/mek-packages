- refactor: Renamed `StripeTerminal` class to `Terminal`. The name has been aligned with the native SDKs.
- docs: Added docs to all `TerminalExceptionCode` enum values
- feat: Added to `TerminalException` class a updated `PaymentIntent` and `ApiError`
- feat: Mapped all Android and IOS sdk errors to `TerminalExceptionCode` enum

*BREAKING CHANGES*
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

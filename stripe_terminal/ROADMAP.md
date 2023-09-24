#### Ready
- Update [README.md](./README.md)

#### Done
- https://github.com/BreX900/mek-packages/issues/11

# Android

## 3.0.0 - 2023-09-08

### Done
- Update: `Terminal.processPayment` has been renamed to [`Terminal.confirmPaymentIntent`](https://stripe.dev/stripe-terminal-android/core/com.stripe.stripeterminal/-terminal/confirm-payment-intent.html).
- Update: `Terminal.processRefund` has been renamed to [`Terminal.confirmRefund`](https://stripe.dev/stripe-terminal-android/core/com.stripe.stripeterminal/-terminal/confirm-refund.html).
- Update: The `minSdkVersion` has been updated to 26. This means that the SDK will no longer support devices running Android 7.1.2 (Nougat) or earlier. Older devices can continue to use the 2.x versions of the SDK while on the maintenance schedule.
- Update: [`TerminalListener.onUnexpectedReaderDisconnect()`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.callable/-terminal-listener/on-unexpected-reader-disconnect.html) will be invoked if a command cannot be sent to an internet reader. Previously, this callback was only invoked when a periodic status check failed.
- Update: [`Terminal.collectPaymentMethod`](https://stripe.dev/stripe-terminal-android/core/com.stripe.stripeterminal/-terminal/collect-payment-method.html) now takes an optional non-null [`CollectConfiguration`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-collect-configuration/index.html) parameter.
- Update: [`Terminal.collectSetupIntentPaymentMethod`](https://stripe.dev/stripe-terminal-android/core/com.stripe.stripeterminal/-terminal/collect-setup-intent-payment-method.html) now takes an optional non-null [`SetupIntentConfiguration`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-setup-intent-configuration/index.html) parameter.
- Update: For readers that require updates to be installed upon connecting, [`TerminalListener.onConnectionStatusChange()`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.callable/-terminal-listener/on-connection-status-change.html) will now be called with [`CONNECTED`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-connection-status/-c-o-n-n-e-c-t-e-d/index.html) _after_ the updates complete successfully, not before.
- Update: Deprecated classes and members have been replaced or removed:
  - `CardDetails.fingerprint` and `CardPresentDetails.fingerprint` have been removed from mobile SDKs. You will still be able to access the fingerprint server-side.
  - `TerminalApplicationDelegate.onTrimMemory()` has been removed. It is automatically managed by the SDK.
  - The `locationId` parameter from the [`HandoffConnectionConfiguration`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-connection-configuration/-handoff-connection-configuration/-handoff-connection-configuration.html) constructor has been removed.
  - `EmvBlob` has been marked as an internal class.
  - `ConnectConfiguration.registerToLocation` has been removed and replaced with [`ConnectConfiguration.locationId`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-connection-configuration/location-id.html).
  - `Reader.registeredLocation` has been removed and replaced with [`Reader.location`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-reader/location.html).
  - The `CollectConfiguration` constructor has been removed. Use [`CollectConfiguration.Builder`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-collect-configuration/-builder/index.html) instead.
  - [`CollectConfiguration.moto`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-collect-configuration/moto.html) is no longer mutable.
  - `CaptureMethod.getManual()` has been removed. Use [`CaptureMethod.MANUAL`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-capture-method/-companion/-manual.html) instead.
- Update: `Terminal.readReusableCard` has been removed. This functionality is replaced by [Setup Intents](https://stripe.com/docs/terminal/features/saving-cards/save-cards-directly?terminal-sdk-platform=android).
- Update: [`DiscoveryConfiguration`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-discovery-configuration/index.html) has been converted to a sealed type, instead of relying on the `DiscoveryMethod` enum to disambiguate different discovery methods.

### In progress

### Ready
- Update: The [`PaymentIntent::id`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-payment-intent/id.html) is now nullable to support creating Payment Intents while offline. This feature is in an invite-only beta. See [Collect payments while offline](https://stripe.com/docs/terminal/features/operate-offline/collect-payments) for details.

### Backlog
- Update: Runtime permission checks have been moved from [`Terminal.initTerminal()`](https://stripe.dev/stripe-terminal-android/core/com.stripe.stripeterminal/-terminal/-companion/init-terminal.html) to [`Terminal.discoverReaders()`](https://stripe.dev/stripe-terminal-android/core/com.stripe.stripeterminal/-terminal/discover-readers.html).
  - Bluetooth permissions are now only required when discovering readers via [`BluetoothDiscoveryConfiguration`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-discovery-configuration/-bluetooth-discovery-configuration/index.html).
  - Location permissions will continue to be required for all [`DiscoveryConfigurations`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-discovery-configuration/index.html). Location services will also need to be enabled on the device at the time of discovery.
- `BluetoothReaderListener` and `UsbReaderListener` have been removed and replaced with [`ReaderListener`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.callable/-reader-listener/index.html).
- (Not exist on ios) `Reader.device` has been removed and replaced with [`Reader.bluetoothDevice`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-reader/bluetooth-device.html) and [`Reader.usbDevice`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-reader/usb-device.html).

# Ios

### Backlog
* Update: Canceling `discoverReaders` now completes with an `SCPErrorCanceled` error. Previously no error was provided when canceled.
* New: Private beta support for offline payments.
  * See [Collect payments while offline](https://stripe.com/docs/terminal/features/operate-offline/collect-payments) for details.

### Ready
* Update: `SCPPaymentIntent.stripeId` is now nullable to support offline payments.
* Update: Removed the `SCPErrorBusy` error. The SDK will now queue incoming commands if another command is already running.

### In progress

### Done
* Update: Configuration and parameter classes are now immutable and need to be built with builders. Example: To create `SCPPaymentIntentParameters` use `SCPPaymentIntentParametersBuilder` which has setters for all the parameters and a `build:` method to create the `SCPPaymentIntentParameters` instance.
* Update: `DiscoveryConfiguration` is now a protocol with concrete classes for each discovery method: `BluetoothScanDiscoveryConfiguration`, `BluetoothProximityDiscoveryConfiguration`, `InternetDiscoveryConfiguration`, and `LocalMobileDiscoveryConfiguration`. Each class has a `Builder` exposing only the configuration values that apply to that discovery method.
* Update: Removed `SCPErrorCannotConnectToUndiscoveredReader` and `SCPErrorMustBeDiscoveringToConnect` errors. The SDK now supports connecting to an `SCPReader` instance that was previously discovered without needing to restart discovery.
* Update: Removed `Terminal.readReusableCard`. This functionality is replaced by [SetupIntents](https://stripe.com/docs/terminal/features/saving-cards/save-cards-directly?terminal-sdk-platform=ios).
* Update: `ReconnectionDelegate` methods now provide the instance of the `Reader` that is being reconnected to instead of the `Terminal` instance.
* Update: Minimum deployment target updated from iOS 11.0 to iOS 13.0.
* Update: `Terminal.processPayment` has been renamed to `Terminal.confirmPaymentIntent`.
* Update: `Terminal.processRefund` has been renamed to `Terminal.confirmRefund`.
* Update: `discoverReaders` is now completed when `connectReader` is called. This is a behavior change from 2.x where `discoverReaders` would continue running until connect succeeded. If connect fails you can retry connecting to a previously discovered `SCPReader` or restart `discoverReaders`.
* Update: Removed `CardDetails.fingerprint` and `CardPresentDetails.fingerprint`. You will still be able to access the fingerprint server-side using [Stripe server-side SDKs](https://stripe.com/docs/libraries#server-side-libraries).

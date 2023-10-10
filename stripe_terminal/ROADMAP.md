# ROADMAP

- *Backlog*: No plans to add support, try opening an issue.
- *Ready*: They will be implemented as soon as possible.
- *In progress*: They are being implemented
- *Done*: Implemented, you will find them in the next release

## Android

### Backlog
- Update: The [`PaymentIntent::id`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-payment-intent/id.html) is now nullable to support creating Payment Intents while offline. This feature is in an invite-only beta. See [Collect payments while offline](https://stripe.com/docs/terminal/features/operate-offline/collect-payments) for details.
- Update: Runtime permission checks have been moved from [`Terminal.initTerminal()`](https://stripe.dev/stripe-terminal-android/core/com.stripe.stripeterminal/-terminal/-companion/init-terminal.html) to [`Terminal.discoverReaders()`](https://stripe.dev/stripe-terminal-android/core/com.stripe.stripeterminal/-terminal/discover-readers.html).
  - Bluetooth permissions are now only required when discovering readers via [`BluetoothDiscoveryConfiguration`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-discovery-configuration/-bluetooth-discovery-configuration/index.html).
  - Location permissions will continue to be required for all [`DiscoveryConfigurations`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-discovery-configuration/index.html). Location services will also need to be enabled on the device at the time of discovery.
- (Not exist on ios) `Reader.device` has been removed and replaced with [`Reader.bluetoothDevice`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-reader/bluetooth-device.html) and [`Reader.usbDevice`](https://stripe.dev/stripe-terminal-android/external/com.stripe.stripeterminal.external.models/-reader/usb-device.html).

### Ready

### In progress

### Done

## Ios

### Backlog
* Update: `SCPPaymentIntent.stripeId` is now nullable to support offline payments.
* New: Private beta support for offline payments.
  * See [Collect payments while offline](https://stripe.com/docs/terminal/features/operate-offline/collect-payments) for details.

### Ready

### In progress

### Done


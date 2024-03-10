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

#### 3.4.0 - 2024-03-04

- Update: The [`Terminal.collectInputs`](https://stripe.com/docs/terminal/features/collect-inputs) method can now display optional toggles in each form.

#### 3.3.0 - 2024-01-30

- Beta: Added a [`Terminal.collectInputs`](https://stripe.com/docs/terminal/features/collect-inputs) method to display forms and collect information from customers. It requires the use of a new `@OptIn` annotation; `@CollectInputs`. Note that this feature is in beta.
  - If you are interested in joining this beta, please email stripe-terminal-betas@stripe.com
- Beta: Added support for retrieving and updating reader settings on WisePOS E and Stripe S700 by calling [`Terminal.getReaderSettings`](https://stripe.dev/stripe-terminal-android/core/com.stripe.stripeterminal/-terminal/get-reader-settings.html) and [`Terminal.setReaderSettings`](https://stripe.dev/stripe-terminal-android/core/com.stripe.stripeterminal/-terminal/set-reader-settings.html). Accessibility settings are provided at this time, allowing text-to-speech via speakers to be turned on and off as needed.
  - If you are interested in joining this beta, please email stripe-terminal-betas@stripe.com
  - _Note: this feature requires [reader software version](https://stripe.com/docs/terminal/readers/bbpos-wisepos-e#reader-software-version) `2.20` or later to be installed on your reader._


### Ready

### In progress

### Done

## Ios

### Backlog
* Update: `SCPPaymentIntent.stripeId` is now nullable to support offline payments.
* New: Private beta support for offline payments.
  * See [Collect payments while offline](https://stripe.com/docs/terminal/features/operate-offline/collect-payments) for details.

#### 3.3.0 2024-02-02
* New: Added support for retrieving and updating reader settings on WisePOS E and Stripe S700 by calling `retrieveReaderSettings` and `setReaderSettings` on `SCPTerminal`.
  * Beta: Accessibility settings are provided at this time, allowing text-to-speech via speakers to be turned on and off as needed.
  * Please [contact us](mailto:stripe-terminal-betas@stripe.com) if you are interested in joining this beta.
* Beta: Added a [`collectInputs`](https://stripe.com/docs/terminal/features/collect-inputs) method to display forms and collect information from customers.
  * If you are interested in joining this beta, please email stripe-terminal-betas@stripe.com.

### Ready

### In progress

### Done



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

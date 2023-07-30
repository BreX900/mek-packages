# mek_stripe_terminal

A flutter plugin to scan stripe readers and connect to the them and get the payment methods.

## Docs

This plugin tries to faithfully follow the signature of classes and methods.
Most of the classes in dart have the same name as the native classes. 
There may be some differences between this sdk and the native one to expose an API
more simply by supporting streams instead of callbacks for listeners

## Features

Terminal Methods:
- ❌ cancelPaymentIntent
- ❌ cancelSetupIntent
- ❌ clearCachedCredentials
- ✅ clearReaderDisplay
- ✅ collectPaymentMethod
- ❌ collectRefundPaymentMethod
- ❌ collectSetupIntentPaymentMethod
- ❌ confirmSetupIntent
- ✅ connectBluetoothReader
- ✅ connectHandoffReader
- ✅ connectInternetReader
- ✅ connectLocalMobileReader
- ✅ connectUsbReader
- ❌ createPaymentIntent
- ❌ createSetupIntent
- ✅ disconnectReader
- ✅ discoverReaders
- ✅ installAvailableUpdate
- ✅ listLocations
- ✅ processPayment
- ❌ processRefund
- ❌ readReusableCard
- ✅ retrievePaymentIntent
- ❌ retrieveSetupIntent
- ❌ setOfflineListener
- ❌ setReaderDisplay
- ❌ supportsReadersOfType

Terminal Listeners:
- ✅ onConnectionStatusChange
- ✅ onPaymentStatusChange
- ✅ onUnexpectedReaderDisconnect

Reader Listeners:
- ✅️ onReportAvailableUpdate
- ✅️ onFinishInstallingUpdate
- ✅ onReportReaderSoftwareUpdateProgress
- ✅️ onStartInstallingUpdate

Support: ✅ Fully | ☑️ Partially | ❌ Missing

# Installation

## Android
No Configuration needed, workes  out of the box.

## iOS
You need to provide permission request strings to your `Info.plist` file. A sample content can be

```
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location access is required in order to accept payments.</string>
	<key>NSBluetoothPeripheralUsageDescription</key>
	<string>Bluetooth access is required in order to connect to supported bluetooth card readers.</string>
	<key>NSBluetoothAlwaysUsageDescription</key>
	<string>This app uses Bluetooth to connect to supported card readers.</string>
```
You also need to authorize background modes authorization for `bluetooth-central`. Paste the following to your `Info.plist` file
```
	<key>UIBackgroundModes</key>
	<array>
		<string>bluetooth-central</string>
	</array>
```

# Usage

You can see the usage example in the [example folder](example/lib/main.dart)

## Initialization

1. Request the permissions
    ```dart
    import 'package:permission_handler/permission_handler.dart';
    
    final permissions = [
      Permission.locationWhenInUse,
      Permission.bluetooth,
      if (Platform.isAndroid) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ],
    ];
    await permissions.request();
    ```

2. Initialize the SDK
    ```
    stripeTerminal = StripeTerminal.getInstance(
      fetchToken: () async {
        // Call your backend to get the connection token and return to this function
        // Example token can be.
        const token = "pst_test_XXXXXXXXXX...."; 

        return token;
      },
    );
    ```

Example backend code to get the connection token written on node.js:
    ```
    import Stripe from "stripe";
    import express from "express"

    const stripe = new Stripe("sk_test_XXXXXXXXXXXXXXXXXX", {
        apiVersion: "2020-08-27"
    })

    const app = express();

    app.get("/connectionToken", async (req, res) => {
        const token = await stripe.terminal.connectionTokens.create();
        res.send({
            success: true,
            data: token.secret
        });
    });

    app.listen(8000, () => {
        console.log("Server started")
    });
    ```

## Discover and Connect Reader

1. Discover the devices nearby and show it to the user. [Stripe Docs](https://stripe.com/docs/terminal/payments/connect-reader?terminal-sdk-platform=android)
    ```dart
    stripeTerminal
        .discoverReaders(simulated: true)
        .listen((List<StripeReader> readers) {
            setState(() => _readers = readers);
        });
    ```
2. Connect to a reader
   - Bluetooth reader
      ```dart
      await stripeTerminal.connectBluetoothReader(readers[0].serialNumber);
      print("Connected to a device");
      ``` 
   - TapToPay
      ```dart
      await stripeTerminal.connectBluetoothReader(readers[0].serialNumber);
      print("Connected to a device");
      ```

## Process a Payment

1. Create a payment intent on backend side
    ```dart
    // Get this from your backend by creating a new payment intent
    final backendPaymentIntent = await backend.createPaymentIntent();
    ```
2. Retrieve payment intent
    ```dart
    final paymentIntent = await stripeTerminal.retrievePaymentIntent(backendPaymentIntent.clientSecret);
    ```
3. Collect payment method
    ```dart
    final processablePaymentIntent = await stripeTerminal.collectPaymentMethod(paymentIntent);
    ```
4. Collect payment method
    ```dart
    final capturablePaymentIntent = await stripeTerminal.processPayment(processablePaymentIntent)
    print("A payment intent has captured a payment method, send this payment intent to you backend to capture the payment");
    ```

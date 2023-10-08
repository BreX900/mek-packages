# mek_stripe_terminal

A flutter plugin to scan stripe readers and connect to the them and get the payment methods.

## Docs

This plugin tries to faithfully follow the signature of classes and methods.
Most of the classes in dart have the same name as the native classes. 
There may be some differences between this sdk and the native one to expose an API
more simply by supporting streams instead of callbacks for listeners

## Features

All features of android and ios sdk are supported (Also the TapToPay feature)
- [Android sdk](https://github.com/stripe/stripe-terminal-android) version: 3.0.0
- [IOS sdk](https://github.com/stripe/stripe-terminal-ios) version: 3.0.0

> Offline mode is not supported

# Installation

## Android

<details>
<summary>If you are using this plugin along with Stripe Terminal SDK see this section</summary>
[Issue #349][https://github.com/stripe/stripe-terminal-android/issues/349]

```groovy
android {
    // TODO: remove this two directives once stripe_terminal fixes its plugin
    //      these two snippets are excluding a dup dependency that is probably not transitive
    //      https://github.com/stripe/stripe-terminal-android/issues/349
    configurations {
        all*.exclude module: 'bcprov-jdk15to18'
    }
    packagingOptions {
        pickFirst 'org/bouncycastle/x509/CertPathReviewerMessages.properties'
        pickFirst 'org/bouncycastle/x509/CertPathReviewerMessages_de.properties'
    }
}
```
</details>

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
        .discoverReaders(BluetoothProximityDiscoveryConfiguration(isSimulated: true))
        .listen((List<StripeReader> readers) {
            setState(() => _readers = readers);
        });
    ```
2. Connect to a reader
   - Bluetooth reader
      ```dart
      await stripeTerminal.connectBluetoothReader(readers[0].serialNumber, locationId: locationId);
      print("Connected to a device");
      ``` 
   - TapToPay
      ```dart
      await stripeTerminal.connectMobileReader(readers[0].serialNumber, locationId: locationId);
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
    final capturablePaymentIntent = await stripeTerminal.confirmPaymentIntent(processablePaymentIntent)
    print("A payment intent has captured a payment method, send this payment intent to you backend to capture the payment");
    ```

## Contributing

The code is formatted with a line/page length of 100 characters.
Use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) for your commits.
Much code in this plugin is auto generated:
- [one_for_all](https://pub.dev/packages/one_for_all) is used to generate the code for communication between platforms.
  Run this [script](tool/generate_api.dart)
- [index_generator](https://pub.dev/packages/index_generator) is used to generate library exports

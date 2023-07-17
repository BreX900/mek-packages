import 'dart:async';

import 'package:example/backend.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

void main() async {
  await Backend().run();

  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StripeTerminal stripeTerminal;

  bool simulated = true;

  StreamSubscription? _sub;
  List<StripeReader>? readers;
  String? paymentIntentClientSecret;

  @override
  void initState() {
    super.initState();
    _initTerminal();
  }

  void _initTerminal() async {
    stripeTerminal = await StripeTerminal.getInstance(
      fetchToken: getConnectionString,
    );
    // stripeTerminal.onNativeLogs.listen(_pushLogs);
  }

  Future<String> getConnectionString() async {
    return '';
  }

  // final Dio _dio = Dio(
  //   BaseOptions(
  //     // TODO: THIS URL does not work
  //     baseUrl: "https://deb8-103-163-182-241.in.ngrok.io",
  //   ),
  // );
  //
  // Future<String> getConnectionString() async {
  //   // get api call using _dio to get connection token
  //   Response response = await _dio.get("/connectionToken");
  //   if (!(response.data)["success"]) {
  //     throw Exception(
  //       "Failed to get connection token because ${response.data["message"]}",
  //     );
  //   }
  //
  //   return (response.data)["data"];
  // }
  //
  // Future<String> createPaymentIntent() async {
  //   Response invoice = await _dio.post("/createPaymentIntent", data: {
  //     "email": "awazgyawali@gmail.com",
  //     "order": {"test": "1"},
  //     "ticketCount": 3,
  //     "price": 5,
  //   });
  //   return jsonDecode(invoice.data)["paymentIntent"]["client_secret"];
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: [
            ListTile(
              onTap: () {
                setState(() {
                  simulated = !simulated;
                  _initTerminal();
                });
              },
              title: const Text("Scanning mode"),
              trailing: Text(simulated ? "Simulator" : "Real"),
            ),
            TextButton(
              child: const Text("Init Stripe"),
              onPressed: () async {
                _initTerminal();
              },
            ),
            // TextButton(
            //   child: const Text("Get Connection Token"),
            //   onPressed: () async {
            //     String connectionToken = await getConnectionString();
            //     _showSnackbar(connectionToken);
            //   },
            // ),
            if (_sub == null)
              TextButton(
                child: const Text("Scan Devices"),
                onPressed: () async {
                  setState(() {
                    readers = [];
                  });
                  _sub = stripeTerminal
                      .discoverReaders(DiscoverConfig(
                    discoveryMethod: DiscoveryMethod.bluetoothScan,
                    simulated: simulated,
                  ))
                      .listen((readers) {
                    setState(() {
                      this.readers = readers;
                    });
                  });
                },
              ),
            if (_sub != null)
              TextButton(
                child: const Text("Stop Scanning"),
                onPressed: () async {
                  setState(() {
                    _sub?.cancel();
                    _sub = null;
                  });
                },
              ),
            TextButton(
              child: const Text("Connection Status"),
              onPressed: () async {
                stripeTerminal.connectionStatus().then((status) {
                  _showSnackbar("Connection status: ${status.toString()}");
                });
              },
            ),
            TextButton(
              child: const Text("Connected Device"),
              onPressed: () async {
                final reader = await stripeTerminal.fetchConnectedReader();
                _showSnackbar("Connection Device: ${reader?.batteryLevel}");
              },
            ),
            if (readers != null)
              ...readers!.map(
                (e) => ListTile(
                  title: Text(e.serialNumber),
                  trailing: Text('${e.batteryLevel}'),
                  leading: Text(e.locationId ?? "No Location Id"),
                  onTap: () async {
                    await stripeTerminal
                        .connectBluetoothReader(
                      e.serialNumber,
                      locationId: "tml_EoMcZwfY6g8btZ",
                    )
                        .then((value) {
                      _showSnackbar("Connected to a device");
                    }).catchError((e) {
                      if (e is PlatformException) {
                        _showSnackbar(e.message ?? e.code);
                      }
                    });
                  },
                  subtitle: Text(describeEnum(e.deviceType)),
                ),
              ),
            TextButton(
              child: const Text("Read Reusable Card Detail"),
              onPressed: () async {
                stripeTerminal.readReusableCardDetail().then((StripePaymentMethod paymentMethod) {
                  _showSnackbar(
                    "A card was read: ${paymentMethod.cardDetails}",
                  );
                });
              },
            ),
            TextButton(
              child: const Text("Set reader display"),
              onPressed: () async {
                stripeTerminal.setReaderDisplay(const Cart(
                  currency: "USD",
                  tax: 130,
                  total: 1000,
                  lineItems: [
                    CartLineItem(
                      description: "hello 1",
                      quantity: 1,
                      amount: 500,
                    ),
                    CartLineItem(
                      description: "hello 2",
                      quantity: 1,
                      amount: 500,
                    ),
                  ],
                ));
              },
            ),
            // TextButton(
            //   child: const Text("Collect Payment Method"),
            //   onPressed: () async {
            //     paymentIntentClientSecret = await createPaymentIntent();
            //     stripeTerminal
            //         .collectPaymentMethod()
            //         .then((StripePaymentIntent paymentIntent) async {
            //       _dio.post("/confirmPaymentIntent", data: {
            //         "paymentIntentId": paymentIntent.id,
            //       });
            //       _showSnackbar(
            //         "A payment method was captured",
            //       );
            //     });
            //   },
            // ),
            // TextButton(
            //   child: const Text("Misc Button"),
            //   onPressed: () async {
            //     StripeReader.fromJson(
            //       {
            //         "locationStatus": 2,
            //         "deviceType": 3,
            //         "serialNumber": "STRM26138003393",
            //         "batteryStatus": 0,
            //         "simulated": false,
            //         "availableUpdate": false
            //       },
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    ));
  }
}

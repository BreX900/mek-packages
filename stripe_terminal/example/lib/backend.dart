// // ignore_for_file: avoid_print
//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart';
// import 'package:shelf_router/shelf_router.dart';
// import 'package:stripe/stripe.dart';
//
// class Backend {
//   // static const _ipAddress = String.fromEnvironment('IP_ADDRESS');
//   static const _secretKey = String.fromEnvironment('SECRET_KEY');
//   // static const _customerId = String.fromEnvironment('CUSTOMER_ID');
//
//   final _stripe = Stripe(_secretKey);
//
//   Backend();
//
//   Future<void> run() async {
//     // await _fetchLocations();
//     // final data = await _stripe.paymentIntent.retrieve('pi_3NDlvVIfvO0ydn9b1LyrNcf1');
//     // print(jsonEncode(data.toJson()));
//
//     final router = Router()
//       ..post('/terminal/connection_tokens', _handleTerminal)
//       ..post('/terminal/locations', _createLocation)
//       ..get('/terminal/locations', _fetchLocations);
//
//     var handler = const Pipeline().addMiddleware(logRequests()).addHandler(router);
//
//     final server = await serve(handler, 'localhost', 8000);
//
//     print('Serving at http://${server.address.host}:${server.port}');
//   }
//
//   Future<Response> _handleTerminal(Request request) async {
//     final terminalToken = await _stripe.client.post('/terminal/connection_tokens');
//     // {"object":"terminal.connection_token","secret":"pst_test_YWNjdF8xRkZtOUhJZnZPMHlkbjliLDhnQjdZRHFOWkJtMUZWMDRJSW9BRnUyUjVUWmJBSEk_00UK91zG2t"}
//     print(jsonEncode(terminalToken));
//
//     // final data = await _stripe.client.post('/terminal/connection_tokens');
//     // // {"object":"terminal.connection_token","secret":"pst_test_YWNjdF8xRkZtOUhJZnZPMHlkbjliLDhnQjdZRHFOWkJtMUZWMDRJSW9BRnUyUjVUWmJBSEk_00UK91zG2t"}
//     // print(jsonEncode(data));
//
//     return Response.ok(jsonEncode(terminalToken), headers: {
//       HttpHeaders.contentTypeHeader: 'application/json',
//     });
//   }
//
//   Future<Response> _createLocation(Request request) async {
//     final location = await _stripe.client.post('/terminal/locations', data: {
//       'display_name': 'Kuama',
//       'address': {
//         'line1': 'Via Germania',
//         'city': 'Vigonza',
//         'state': 'PD',
//         'country': 'IT',
//         'postal_code': '35010',
//       }
//     });
//     // {id: tml_FKzZ8QFhWYrcfP, object: terminal.location, address: {city: Vigonza, country: IT, line1: Via Germania, line2: , postal_code: 35010, state: PD}, display_name: Kuama, livemode: false, metadata: {}}
//     print(location);
//     return Response.ok(jsonEncode(location), headers: {
//       HttpHeaders.contentTypeHeader: 'application/json',
//     });
//   }
//
//   Future<Response> _fetchLocations(Request request) async {
//     final locations = await _stripe.client.get('/terminal/locations');
//     // {object: list, data: [{id: tml_FKzZ8QFhWYrcfP, object: terminal.location, address: {city: Vigonza, country: IT, line1: Via Germania, line2: , postal_code: 35010, state: PD}, display_name: Kuama, livemode: false, metadata: {}}], has_more: false, url: /v1/terminal/locations}
//     print(locations);
//     return Response.ok(jsonEncode(locations), headers: {
//       HttpHeaders.contentTypeHeader: 'application/json',
//     });
//   }
//
//   // Future<Response> _handlePayment(Request request) async {
//   //   // final customer = await stripe.customer.create(CreateCustomerRequest(
//   //   //   name: 'Dart Test',
//   //   // ));
//   //   // {"object":"customer","id":"cus_NxBiJ2VbZYkIw8","metadata":{},"name":"Dart Test"}
//   //   // print(jsonEncode(customer.toJson()));
//   //
//   //   final customerEphemeralKey = await _stripe.client.post('/ephemeral_keys', data: {
//   //     'customer': _customerId,
//   //   });
//   //   // {"id":"ephkey_1NBHLTIfvO0ydn9br5uQq8Sv","object":"ephemeral_key","associated_objects":[{"id":"cus_NxBiJ2VbZYkIw8","type":"customer"}],"created":1684933395,"expires":1684936995,"livemode":false,"secret":"ek_test_YWNjdF8xRkZtOUhJZnZPMHlkbjliLDQ1T25vQWxpc0dUODh4V0FoZjJyOFU4bEdCajIyOXE_00ykadSD4r"}
//   //   print(jsonEncode(customerEphemeralKey));
//   //
//   //   final paymentIntent = await _stripe.paymentIntent.create(CreatePaymentIntentRequest(
//   //     amount: 100,
//   //     currency: 'EUR',
//   //     customer: _customerId,
//   //   ));
//   //   // {"object":"payment_intent","id":"pi_3NBJlmIfvO0ydn9b1B2yc3pU","amount":100,"amount_received":0,"automatic_payment_methods":{"enabled":false},"client_secret":"pi_3NBJlmIfvO0ydn9b1B2yc3pU_secret_TXqGAHJs8OCtJttSfQd7LptrN","currency":"eur","status":"requires_payment_method","created":1684942714,"customer":"cus_NxBiJ2VbZYkIw8","metadata":{},"payment_method_types":["card"]}
//   //   print(jsonEncode(paymentIntent.toJson()));
//   //
//   //   return Response.ok(
//   //       jsonEncode({
//   //         'merchantDisplayName': 'Toonie',
//   //         'customerId': _customerId,
//   //         'customerEphemeralKeySecret': customerEphemeralKey['secret'] as String,
//   //         'paymentIntentClientSecret': paymentIntent.clientSecret,
//   //       }),
//   //       headers: {
//   //         HttpHeaders.contentTypeHeader: 'application/json',
//   //       });
//   // }
// }

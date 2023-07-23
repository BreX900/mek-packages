// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:stripe/stripe.dart';

class StripeApi {
  static const _secretKey = String.fromEnvironment('SECRET_KEY');

  final _stripe = Stripe(_secretKey);

  StripeApi();

  Future<String> createTerminalConnectionToken() async {
    final terminalToken = await _stripe.client.post('/terminal/connection_tokens');
    print(jsonEncode(terminalToken));
    return terminalToken['secret'] as String;
  }

  Future<Map<String, dynamic>> createLocation() async {
    final location = await _stripe.client.post('/terminal/locations', data: {
      'display_name': 'Mek',
      'address': {
        'line1': 'Via Roma',
        'city': 'Venezia',
        'state': 'ML',
        'country': 'IT',
        'postal_code': '35040',
      }
    });
    print(jsonEncode(location));
    return location;
  }

  Future<Map<String, dynamic>> fetchLocations() async {
    final locations = await _stripe.client.get('/terminal/locations');
    print(jsonEncode(locations));
    return locations;
  }

  Future<String> createPaymentIntent() async {
    final paymentIntent = await _stripe.client.post('payment_intents', data: {
      'currency': 'gbp',
      'payment_method_types': ['card_present'],
      'capture_method': 'manual',
      'amount': 1000,
    });
    print(jsonEncode(paymentIntent));
    return paymentIntent['client_secret'];
  }

// Future<Response> _handlePayment(Request request) async {
//   // final customer = await stripe.customer.create(CreateCustomerRequest(
//   //   name: 'Dart Test',
//   // ));
//   // {"object":"customer","id":"cus_NxBiJ2VbZYkIw8","metadata":{},"name":"Dart Test"}
//   // print(jsonEncode(customer.toJson()));
//
//   final customerEphemeralKey = await _stripe.client.post('/ephemeral_keys', data: {
//     'customer': _customerId,
//   });
//   // {"id":"ephkey_1NBHLTIfvO0ydn9br5uQq8Sv","object":"ephemeral_key","associated_objects":[{"id":"cus_NxBiJ2VbZYkIw8","type":"customer"}],"created":1684933395,"expires":1684936995,"livemode":false,"secret":"ek_test_YWNjdF8xRkZtOUhJZnZPMHlkbjliLDQ1T25vQWxpc0dUODh4V0FoZjJyOFU4bEdCajIyOXE_00ykadSD4r"}
//   print(jsonEncode(customerEphemeralKey));
//
//   final paymentIntent = await _stripe.paymentIntent.create(CreatePaymentIntentRequest(
//     amount: 100,
//     currency: 'EUR',
//     customer: _customerId,
//   ));
//   // {"object":"payment_intent","id":"pi_3NBJlmIfvO0ydn9b1B2yc3pU","amount":100,"amount_received":0,"automatic_payment_methods":{"enabled":false},"client_secret":"pi_3NBJlmIfvO0ydn9b1B2yc3pU_secret_TXqGAHJs8OCtJttSfQd7LptrN","currency":"eur","status":"requires_payment_method","created":1684942714,"customer":"cus_NxBiJ2VbZYkIw8","metadata":{},"payment_method_types":["card"]}
//   print(jsonEncode(paymentIntent.toJson()));
//
//   return Response.ok(
//       jsonEncode({
//         'merchantDisplayName': 'Toonie',
//         'customerId': _customerId,
//         'customerEphemeralKeySecret': customerEphemeralKey['secret'] as String,
//         'paymentIntentClientSecret': paymentIntent.clientSecret,
//       }),
//       headers: {
//         HttpHeaders.contentTypeHeader: 'application/json',
//       });
// }
}

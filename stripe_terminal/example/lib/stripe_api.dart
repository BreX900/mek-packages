// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:stripe/stripe.dart';

class StripeApi {
  static const String secretKey = String.fromEnvironment('STRIPE_SECRET_KEY');

  final _stripe = Stripe(secretKey);

  StripeApi();

  Future<String> createTerminalConnectionToken() async {
    try {
      final terminalToken = await _stripe.client.post('/terminal/connection_tokens');
      print(jsonEncode(terminalToken));
      return terminalToken['secret'] as String;
    } catch (error, stackTrace) {
      print('$error\n$stackTrace');
      rethrow;
    }
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

  Future<void> createReader() async {
    final paymentIntent = await _stripe.client.post('/terminal/readers', data: {
      'registration_code': 'simulated',
      'location': '',
      'label': 'Simulated device',
    });
    print(jsonEncode(paymentIntent));
  }
}

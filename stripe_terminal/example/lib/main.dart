// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:example/screens/initialization_screen.dart';
import 'package:example/screens/terminal_area.dart';
import 'package:example/utils/stripe_api.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Stripe Secret Key: ${StripeApi.secretKey.isNotEmpty}');

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _isInitialized = Terminal.isInitialized;

  void _onInitialized() {
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          brightness: PlatformDispatcher.instance.platformBrightness,
          seedColor: Colors.amber,
        ),
      ),
      home: _isInitialized
          ? const TerminalArea()
          : InitializationScreen(onInitialized: _onInitialized),
    );
  }
}

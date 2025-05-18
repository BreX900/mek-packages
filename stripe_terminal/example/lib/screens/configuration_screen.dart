import 'package:example/utils/linear_progress_indicator_bar.dart';
import 'package:example/utils/state_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class ConfigurationScreen extends ConsumerStatefulWidget {
  final ValueListenable<PaymentStatus> paymentStatusListenable;
  final ValueListenable<Reader?> connectedReaderListenable;

  const ConfigurationScreen({
    super.key,
    required this.paymentStatusListenable,
    required this.connectedReaderListenable,
  });

  @override
  State<ConfigurationScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<ConfigurationScreen> with StateTools {
  Future<void> _setConfig() async {
    await Terminal.instance.setTapToPayUXConfiguration(const TapToPayUxConfiguration(
      tapZone: TapToPayUxConfigurationTapZone(
        indicator: TapToPayUxConfigurationTapZoneIndicator.below,
        position: TapToPayUxConfigurationTapZonePosition(
          xBias: 0.5,
          yBias: 0.5,
        ),
      ),
      colors: TapToPayUxConfigurationColorScheme(
        primary: 0xFF0000FF,
        success: 0xFF00FF00,
        error: 0xFFFF0000,
      ),
      darkMode: TapToPayUxConfigurationDarkMode.dark,
    ));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configured!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        bottom: isMutating ? const LinearProgressIndicatorBar() : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.tonal(
              onPressed: _setConfig,
              child: const Text('Set Config'),
            ),
          ],
        ),
      ),
    );
  }
}

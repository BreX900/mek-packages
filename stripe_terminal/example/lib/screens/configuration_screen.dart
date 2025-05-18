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
    await Terminal.instance.setTapToPayUXConfiguration(const TapToPayUXConfiguration(
      tapZone: TapToPayUxConfigurationTapZone(
        indicator: TapToPayUxConfigurationTapZoneIndicator.below,
        position: TapToPayUxConfigurationTapZonePosition(
          xBias: 0.5,
          yBias: 0.5,
        ),
      ),
      colors: TapToPayUxConfigurationColors(
        primary: '#FF0000FF',
        success: '#FF00FF00',
        error: '#FFFF0000',
      ),
      theme: TapToPayUxConfigurationTheme.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final paymentStatus = ref.watch(widget.paymentStatusListenable);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        bottom: isMutating ? const LinearProgressIndicatorBar() : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              selected: true,
              title: Text('Payment Status: ${paymentStatus.name}'),
            ),
            const Divider(height: 32.0),
            FilledButton.tonal(
              onPressed: () async {
                await _setConfig();
              },
              child: const Text('Set Config'),
            ),
          ],
        ),
      ),
    );
  }
}

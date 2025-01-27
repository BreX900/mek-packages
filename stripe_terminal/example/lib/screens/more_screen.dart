import 'package:example/utils/linear_progress_indicator_bar.dart';
import 'package:example/utils/state_tools.dart';
import 'package:example/utils/stripe_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class MoreScreen extends ConsumerStatefulWidget {
  final ValueListenable<ConnectionStatus> connectionStatusListenable;

  const MoreScreen({
    super.key,
    required this.connectionStatusListenable,
  });

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> with StateTools {
  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(widget.connectionStatusListenable);

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        bottom: isMutating ? const LinearProgressIndicatorBar() : null,
      ),
      body: Column(
        children: [
          FilledButton.tonal(
            onPressed: !isMutating && connectionStatus == ConnectionStatus.notConnected
                ? () => mutate(Terminal.instance.clearCachedCredentials)
                : null,
            child: const Text('Clear cached credentials'),
          ),
          Text('You can use this method to switch Stripe accounts in your app.',
              style: textTheme.bodySmall),
          const Divider(height: 32.0),
          OutlinedButton(
            onPressed: () async => StripeApi.instance.createReader(),
            child: const Text('Random button'),
          ),
        ],
      ),
    );
  }
}

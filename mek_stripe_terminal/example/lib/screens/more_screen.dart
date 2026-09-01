import 'package:example/utils/linear_progress_indicator_bar.dart';
import 'package:example/utils/state_tools.dart';
import 'package:example/utils/stripe_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class MoreScreen extends ConsumerStatefulWidget {
  final ValueListenable<ConnectionStatus> connectionStatusListenable;

  const MoreScreen({super.key, required this.connectionStatusListenable});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> with StateTools {
  void _clearCachedCredentials() => mutate(() async {
    final result = await Terminal.instance.clearCachedCredentials();
    if (!result.isSuccessful) {
      // ignore: only_throw_errors
      throw result.error ?? Exception('Clear cached credentials failed.');
    }
    showSnackBar('Terminal cleared!');
  });

  String? _token;
  String get token => ArgumentError.checkNotNull(_token, '_MoreScreenState._token');

  void _isAccountLinked() => mutate(() async {
    // ignore: experimental_member_use
    final isAccountLinked = await ProximityReader().isAccountLinked(token: token);
    showSnackBar('isAccountLinked? $isAccountLinked');
  });

  void _linkAccount() => mutate(() async {
    // ignore: experimental_member_use
    await ProximityReader().linkAccount(token: token);
    showSnackBar('_linkAccount: Done');
  });

  void _presentHowToTap() => mutate(() async {
    // ignore: experimental_member_use
    await ProximityReader().presentHowToTap();
    showSnackBar('presentHowToTap: Done');
  });

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
        spacing: 12.0,
        children: [
          Text('Change account', style: textTheme.titleLarge),

          FilledButton.tonal(
            onPressed: !isMutating && connectionStatus == ConnectionStatus.notConnected
                ? _clearCachedCredentials
                : null,
            child: const Text('Clear cached credentials'),
          ),
          Text(
            'You can use this method to switch Stripe accounts in your app.',
            style: textTheme.bodySmall,
          ),

          const Divider(height: 32.0),

          Text('Proximity Reader Api', style: textTheme.titleLarge),

          OutlinedButton(
            onPressed: !isMutating ? _isAccountLinked : null,
            child: const Text('Is account linked?'),
          ),
          OutlinedButton(
            onPressed: !isMutating ? _linkAccount : null,
            child: const Text('Link account'),
          ),
          OutlinedButton(
            onPressed: !isMutating ? _presentHowToTap : null,
            child: const Text('Present how to tap?'),
          ),

          const Divider(height: 32.0),

          Text('Random buttons', style: textTheme.titleLarge),

          OutlinedButton(
            onPressed: () async => StripeApi.instance.createReader(),
            child: const Text('Random button'),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:example/utils/linear_progress_indicator_bar.dart';
import 'package:example/utils/permission_utils.dart';
import 'package:example/utils/state_tools.dart';
import 'package:example/utils/stripe_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:permission_handler/permission_handler.dart';

class InitializationScreen extends StatefulWidget {
  final VoidCallback onInitialized;

  const InitializationScreen({
    super.key,
    required this.onInitialized,
  });

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> with StateTools {
  Future<void> _initTerminal() async {
    final permissions = [
      Permission.locationWhenInUse,
      Permission.bluetooth,
      if (Platform.isAndroid) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ],
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      report('$permission: $status');

      if (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
        showSnackBar('Please grant ${permission.name} permission.');
        return;
      }
    }

    if (kReleaseMode) {
      for (final service in permissions.whereType<PermissionWithService>()) {
        final status = await service.serviceStatus;
        report('$service: $status');

        if (status != ServiceStatus.enabled) {
          showSnackBar('Please enable ${service.name} service.');
          return;
        }
      }
    }

    await Terminal.initTerminal(
      shouldPrintLogs: true,
      fetchToken: StripeApi.instance.createTerminalConnectionToken,
    );

    widget.onInitialized();
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    if (StripeApi.secretKey.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'STRIPE_SECRET_KEY is not provided!',
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium!.copyWith(color: colors.error),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Must provide a STRIPE_SECRET_KEY from command line. See README.md for more info.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge!.copyWith(color: colors.error),
            ),
          ],
        ),
      );
    }

    return Center(
      child: FilledButton(
        onPressed: !isMutating ? () => mutate(_initTerminal) : null,
        child: const Text('Initialize terminal'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initialization'),
        bottom: isMutating ? const LinearProgressIndicatorBar() : null,
      ),
      body: _buildBody(),
    );
  }
}

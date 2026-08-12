import 'package:example/models/k.dart';
import 'package:example/utils/linear_progress_indicator_bar.dart';
import 'package:example/utils/state_tools.dart';
import 'package:example/utils/stripe_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  final ValueListenable<PaymentStatus> paymentStatusListenable;
  final ValueListenable<Reader?> connectedReaderListenable;

  const PaymentsScreen({
    super.key,
    required this.paymentStatusListenable,
    required this.connectedReaderListenable,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> with StateTools {
  PaymentIntent? _paymentIntent;
  CancelableFuture<PaymentIntent>? _processingPaymentIntent;

  Future<void> _createPaymentIntent() async {
    final paymentIntent = await Terminal.instance.createPaymentIntent(
      PaymentIntentParameters(
        amount: 200,
        currency: K.currency,
        captureMethod: CaptureMethod.automatic,
        paymentMethodTypes: [PaymentMethodType.cardPresent],
      ),
    );
    setState(() => _paymentIntent = paymentIntent);
    showSnackBar('Payment intent created!');
  }

  Future<void> _createFromApiAndRetrievePaymentIntentFromSdk() async {
    final paymentIntentClientSecret = await StripeApi.instance.createPaymentIntent();
    final paymentIntent = await Terminal.instance.retrievePaymentIntent(paymentIntentClientSecret);
    setState(() => _paymentIntent = paymentIntent);
    showSnackBar('Payment intent retrieved!');
  }

  Future<void> _processPaymentIntent(PaymentIntent paymentIntent) async {
    final processingPaymentIntent = Terminal.instance.processPaymentIntent(
      paymentIntent,
      skipTipping: true,
    );
    setState(() {
      _processingPaymentIntent = processingPaymentIntent;
    });

    try {
      final processedPaymentIntent = await processingPaymentIntent;
      setState(() {
        _paymentIntent = processedPaymentIntent;
        _processingPaymentIntent = null;
      });
      showSnackBar('Payment processed!');
    } on TerminalException catch (exception) {
      setState(() => _processingPaymentIntent = null);
      switch (exception.code) {
        case TerminalExceptionCode.canceled:
          showSnackBar('Payment processing is cancelled!');
        default:
          rethrow;
      }
    }
  }

  Future<void> _cancelProcessingPaymentIntent(CancelableFuture<PaymentIntent> cancelable) async {
    await cancelable.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final paymentStatus = ref.watch(widget.paymentStatusListenable);
    final connectedReader = ref.watch(widget.connectedReaderListenable);
    final paymentIntent = _paymentIntent;
    final processingPaymentIntent = _processingPaymentIntent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        bottom: isMutating ? const LinearProgressIndicatorBar() : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(selected: true, title: Text('Payment Status: ${paymentStatus.name}')),
            const Divider(height: 32.0),
            FilledButton.tonal(
              onPressed: !isMutating ? () => mutate(_createPaymentIntent) : null,
              child: const Text('Create PaymentIntent via Skd'),
            ),
            const SizedBox(height: 8.0),
            FilledButton.tonal(
              onPressed:
                  !isMutating ? () => mutate(_createFromApiAndRetrievePaymentIntentFromSdk) : null,
              child: const Text('Create PaymentIntent via Api and Retrieve it via Sdk'),
            ),
            const SizedBox(height: 8.0),
            if (processingPaymentIntent == null)
              FilledButton(
                onPressed:
                    !isMutating &&
                            connectedReader != null &&
                            paymentIntent != null &&
                            paymentIntent.status == PaymentIntentStatus.requiresPaymentMethod
                        ? () => mutate(() async => _processPaymentIntent(paymentIntent))
                        : null,
                child: const Text('Process PaymentIntent'),
              )
            else
              FilledButton(
                onPressed: () async => _cancelProcessingPaymentIntent(processingPaymentIntent),
                child: const Text('Cancel Processing Payment'),
              ),
            const Divider(height: 32.0),
            if (paymentIntent != null) ListTile(title: Text('$paymentIntent')),
          ],
        ),
      ),
    );
  }
}

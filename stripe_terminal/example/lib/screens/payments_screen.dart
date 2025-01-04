import 'package:example/models/k.dart';
import 'package:example/utils/linear_progress_indicator_bar.dart';
import 'package:example/utils/state_tools.dart';
import 'package:example/utils/stripe_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class PaymentsScreen extends StatefulWidget {
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

class _PaymentsScreenState extends State<PaymentsScreen> with StateTools {
  PaymentIntent? _paymentIntent;
  CancelableFuture<PaymentIntent>? _collectingPaymentMethod;

  Future<void> _createPaymentIntent() async {
    final paymentIntent = await Terminal.instance.createPaymentIntent(PaymentIntentParameters(
      amount: 200,
      currency: K.currency,
      captureMethod: CaptureMethod.automatic,
      paymentMethodTypes: [PaymentMethodType.cardPresent],
    ));
    setState(() => _paymentIntent = paymentIntent);
    showSnackBar('Payment intent created!');
  }

  Future<void> _createFromApiAndRetrievePaymentIntentFromSdk() async {
    final paymentIntentClientSecret = await StripeApi.instance.createPaymentIntent();
    final paymentIntent = await Terminal.instance.retrievePaymentIntent(paymentIntentClientSecret);
    setState(() => _paymentIntent = paymentIntent);
    showSnackBar('Payment intent retrieved!');
  }

  Future<void> _collectPaymentMethod(PaymentIntent paymentIntent) async {
    final collectingPaymentMethod = Terminal.instance.collectPaymentMethod(
      paymentIntent,
      skipTipping: true,
    );
    setState(() {
      _collectingPaymentMethod = collectingPaymentMethod;
    });

    try {
      final paymentIntentWithPaymentMethod = await collectingPaymentMethod;
      setState(() {
        _paymentIntent = paymentIntentWithPaymentMethod;
        _collectingPaymentMethod = null;
      });
      showSnackBar('Payment method collected!');
    } on TerminalException catch (exception) {
      setState(() => _collectingPaymentMethod = null);
      switch (exception.code) {
        case TerminalExceptionCode.canceled:
          showSnackBar('Collecting Payment method is cancelled!');
        default:
          rethrow;
      }
    }
  }

  Future<void> _cancelCollectingPaymentMethod(CancelableFuture<PaymentIntent> cancelable) async {
    await cancelable.cancel();
  }

  Future<void> _confirmPaymentIntent(PaymentIntent paymentIntent) async {
    final processedPaymentIntent = await Terminal.instance.confirmPaymentIntent(paymentIntent);
    setState(() => _paymentIntent = processedPaymentIntent);
    showSnackBar('Payment processed!');
  }

  @override
  Widget build(BuildContext context) {
    final paymentStatus = watch(widget.paymentStatusListenable);
    final connectedReader = watch(widget.connectedReaderListenable);
    final paymentIntent = _paymentIntent;
    final collectingPaymentMethod = _collectingPaymentMethod;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
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
            if (collectingPaymentMethod == null)
              FilledButton(
                onPressed: !isMutating &&
                        connectedReader != null &&
                        paymentIntent != null &&
                        paymentIntent.status == PaymentIntentStatus.requiresPaymentMethod
                    ? () => mutate(() async => _collectPaymentMethod(paymentIntent))
                    : null,
                child: const Text('Collect Payment Method'),
              )
            else
              FilledButton(
                onPressed: () async => _cancelCollectingPaymentMethod(collectingPaymentMethod),
                child: const Text('Cancel Collecting Payment Method'),
              ),
            const SizedBox(height: 8.0),
            FilledButton(
              onPressed: !isMutating &&
                      paymentIntent != null &&
                      paymentIntent.status == PaymentIntentStatus.requiresConfirmation
                  ? () => mutate(() async => _confirmPaymentIntent(paymentIntent))
                  : null,
              child: const Text('Confirm PaymentIntent'),
            ),
            const Divider(height: 32.0),
            if (paymentIntent != null)
              ListTile(
                title: Text('$paymentIntent'),
              )
          ],
        ),
      ),
    );
  }
}

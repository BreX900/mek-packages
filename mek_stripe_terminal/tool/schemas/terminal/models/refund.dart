import 'card_api.dart';

class RefundApi {
  final String id;
  final int amount;
  final String chargeId;

  /// [DateTime.millisecondsSinceEpoch]
  final int createdInMilliseconds;
  final String currency;
  final Map<String, String> metadata;
  final String? reason;
  final RefundStatusApi? status;
  final PaymentMethodDetailsApi? paymentMethodDetails;
  final String? failureReason;

  const RefundApi({
    required this.id,
    required this.amount,
    required this.chargeId,
    required this.createdInMilliseconds,
    required this.currency,
    required this.metadata,
    required this.reason,
    required this.status,
    required this.paymentMethodDetails,
    required this.failureReason,
  });
}

enum RefundStatusApi { succeeded, pending, failed }

class PaymentMethodDetailsApi {
  final CardPresentDetailsApi? cardPresent;
  final CardPresentDetailsApi? interactPresent;

  const PaymentMethodDetailsApi({required this.cardPresent, required this.interactPresent});
}

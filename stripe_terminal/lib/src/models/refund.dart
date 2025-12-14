import 'package:mek_data_class/mek_data_class.dart';
import 'package:mek_stripe_terminal/src/models/card.dart';
import 'package:meta/meta.dart';

part 'refund.g.dart';

@DataClass()
class Refund with _$Refund {
  final String id;
  final int? amount;
  final String? chargeId;
  final DateTime? created;
  final String? currency;
  final Map<String, String>? metadata;
  final String? reason;
  final RefundStatus? status;
  final PaymentMethodDetails? paymentMethodDetails;
  final String? failureReason;

  @internal
  const Refund({
    required this.id,
    required this.amount,
    required this.chargeId,
    required this.created,
    required this.currency,
    required this.metadata,
    required this.reason,
    required this.status,
    required this.paymentMethodDetails,
    required this.failureReason,
  });
}

enum RefundStatus { succeeded, pending, failed }

@DataClass()
class PaymentMethodDetails with _$PaymentMethodDetails {
  final CardPresentDetails? cardPresent;
  final CardPresentDetails? interacPresent;

  PaymentMethodDetails({
    required this.cardPresent,
    required this.interacPresent,
  });
}

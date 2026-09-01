import 'package:mek_stripe_terminal/src/api/terminal_api.g.dart';

typedef Refund = RefundApi;

typedef RefundStatus = RefundStatusApi;

typedef PaymentMethodDetails = PaymentMethodDetailsApi;

extension RefundUtils on RefundApi {
  DateTime get created => DateTime.fromMillisecondsSinceEpoch(createdInMilliseconds, isUtc: true);
}

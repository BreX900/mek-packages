import 'package:mek_stripe_terminal/src/api/terminal_api.g.dart';

typedef PaymentIntent = PaymentIntentApi;

extension PaymentIntentUtils on PaymentIntentApi {
  DateTime get created => DateTime.fromMillisecondsSinceEpoch(createdInMilliseconds, isUtc: true);
}

typedef PaymentIntentStatus = PaymentIntentStatusApi;

typedef AmountDetails = AmountDetailsApi;

typedef PaymentIntentParameters = PaymentIntentParametersApi;

typedef CaptureMethod = CaptureMethodApi;

typedef ConfirmationMethod = ConfirmationMethodApi;

typedef PaymentIntentUsage = PaymentIntentUsageApi;

typedef PaymentMethodOptionsParameters = PaymentMethodOptionsParametersApi;

typedef ConfirmPaymentIntentConfiguration = ConfirmPaymentIntentConfigurationApi;

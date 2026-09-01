import 'package:mek_stripe_terminal/src/api/terminal_api.g.dart';

typedef SetupIntent = SetupIntentApi;

typedef SetupIntentUsage = SetupIntentUsageApi;

typedef SetupIntentStatus = SetupIntentStatusApi;

typedef SetupAttempt = SetupAttemptApi;

typedef SetupAttemptStatus = SetupAttemptStatusApi;

typedef SetupAttemptPaymentMethodDetails = SetupAttemptPaymentMethodDetailsApi;

typedef SetupAttemptCardPresentDetails = SetupAttemptCardPresentDetailsApi;

typedef AllowRedisplay = AllowRedisplayApi;

extension SetupIntentUtils on SetupIntentApi {
  DateTime get created => DateTime.fromMillisecondsSinceEpoch(createdInMilliseconds, isUtc: true);
}

extension SetupAttemptUtils on SetupAttemptApi {
  DateTime get created => DateTime.fromMillisecondsSinceEpoch(createdInMilliseconds, isUtc: true);
}

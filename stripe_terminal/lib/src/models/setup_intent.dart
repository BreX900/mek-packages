import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'setup_intent.g.dart';

@DataClass()
class SetupIntent with _$SetupIntent {
  final String id;
  final DateTime created;
  final String? customerId;
  final Map<String, String> metadata;
  final SetupIntentUsage usage;
  final SetupIntentStatus status;
  final SetupAttempt? latestAttempt;

  @internal
  const SetupIntent({
    required this.id,
    required this.created,
    required this.customerId,
    required this.metadata,
    required this.usage,
    required this.status,
    required this.latestAttempt,
  });
}

enum SetupIntentUsage { onSession, offSession }

enum SetupIntentStatus {
  requiresPaymentMethod,
  requiresConfirmation,
  requiresAction,
  processing,
  succeeded,
  cancelled
}

@DataClass()
class SetupAttempt with _$SetupAttempt {
  final String id;
  final String? applicationId;
  final DateTime created;
  final String? customerId;
  final String? onBehalfOfId;
  final String? paymentMethodId;
  final SetupAttemptPaymentMethodDetails? paymentMethodDetails;
  final String setupIntentId;
  final SetupAttemptStatus status;

  const SetupAttempt({
    required this.id,
    required this.applicationId,
    required this.created,
    required this.customerId,
    required this.onBehalfOfId,
    required this.paymentMethodId,
    required this.paymentMethodDetails,
    required this.setupIntentId,
    required this.status,
  });
}

enum SetupAttemptStatus {
  requiresConfirmation,
  requiresAction,
  processing,
  succeeded,
  failed,
  abandoned
}

@DataClass()
class SetupAttemptPaymentMethodDetails with _$SetupAttemptPaymentMethodDetails {
  final SetupAttemptCardPresentDetails? cardPresent;
  final SetupAttemptCardPresentDetails? interacPresent;

  const SetupAttemptPaymentMethodDetails({
    this.cardPresent,
    this.interacPresent,
  });
}

@DataClass()
class SetupAttemptCardPresentDetails with _$SetupAttemptCardPresentDetails {
  final String emvAuthData;
  final String generatedCard;

  const SetupAttemptCardPresentDetails({
    required this.emvAuthData,
    required this.generatedCard,
  });
}

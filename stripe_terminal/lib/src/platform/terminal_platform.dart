library stripe_terminal;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mek_stripe_terminal/src/models/card.dart';
import 'package:mek_stripe_terminal/src/models/cart.dart';
import 'package:mek_stripe_terminal/src/models/charge.dart';
import 'package:mek_stripe_terminal/src/models/connection_configuration.dart';
import 'package:mek_stripe_terminal/src/models/disconnect_reason.dart';
import 'package:mek_stripe_terminal/src/models/discovery_configuration.dart';
import 'package:mek_stripe_terminal/src/models/location.dart';
import 'package:mek_stripe_terminal/src/models/payment.dart';
import 'package:mek_stripe_terminal/src/models/payment_intent.dart';
import 'package:mek_stripe_terminal/src/models/payment_method.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/reader_software_update.dart';
import 'package:mek_stripe_terminal/src/models/refund.dart';
import 'package:mek_stripe_terminal/src/models/setup_intent.dart';
import 'package:mek_stripe_terminal/src/models/simultator_configuration.dart';
import 'package:mek_stripe_terminal/src/models/tap_to_pay_ux_configuration.dart';
import 'package:mek_stripe_terminal/src/models/tip.dart';
import 'package:mek_stripe_terminal/src/reader_delegates.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';
import 'package:one_for_all/one_for_all.dart';

part 'terminal_handlers.dart';
part 'terminal_platform.api.dart';

@HostApi(
  hostExceptionHandler: TerminalPlatform._throwIfIsHostException,
  kotlinMethod: MethodApiType.callbacks,
  swiftMethod: MethodApiType.async,
)
abstract class TerminalPlatform {
  factory TerminalPlatform() = _$TerminalPlatform;

  @MethodApi(kotlin: MethodApiType.sync)
  Future<void> init({required bool shouldPrintLogs});

  @MethodApi(kotlin: MethodApiType.sync, swift: MethodApiType.sync)
  Future<void> clearCachedCredentials();

//region Reader discovery, connection and updates

  @MethodApi(kotlin: MethodApiType.sync, swift: MethodApiType.sync)
  Future<ConnectionStatus> getConnectionStatus();

  @MethodApi(kotlin: MethodApiType.sync, swift: MethodApiType.sync)
  Future<bool> supportsReadersOfType({
    required DeviceType? deviceType,
    required DiscoveryConfiguration discoveryConfiguration,
  });

  Stream<List<Reader>> discoverReaders(DiscoveryConfiguration configuration);

  Future<Reader> connectReader(String serialNumber, ConnectionConfiguration configuration);

  @MethodApi(kotlin: MethodApiType.sync, swift: MethodApiType.sync)
  Future<Reader?> getConnectedReader();

  Future<void> cancelReaderReconnection();

  Future<List<Location>> listLocations({
    required String? endingBefore,
    required int? limit,
    required String? startingAfter,
  });

  @MethodApi(kotlin: MethodApiType.sync, swift: MethodApiType.sync)
  Future<void> installAvailableUpdate();

  Future<void> cancelReaderUpdate();

  Future<void> rebootReader();

  Future<void> disconnectReader();

  @MethodApi(kotlin: MethodApiType.sync, swift: MethodApiType.sync)
  Future<void> setSimulatorConfiguration(SimulatorConfiguration configuration);
//endregion

//region Taking payments
  @MethodApi(kotlin: MethodApiType.sync, swift: MethodApiType.sync)
  Future<PaymentStatus> getPaymentStatus();

  Future<PaymentIntent> createPaymentIntent(PaymentIntentParameters parameters);

  Future<PaymentIntent> retrievePaymentIntent(String clientSecret);

  @MethodApi(swift: MethodApiType.callbacks)
  Future<PaymentIntent> startCollectPaymentMethod({
    required int operationId,
    required String paymentIntentId,
    required bool requestDynamicCurrencyConversion,
    required String? surchargeNotice,
    required bool skipTipping,
    required TippingConfiguration? tippingConfiguration,
    required bool shouldUpdatePaymentIntent,
    required bool customerCancellationEnabled,
    required AllowRedisplay allowRedisplay,
  });

  Future<void> stopCollectPaymentMethod(int operationId);

  @MethodApi(swift: MethodApiType.callbacks)
  Future<PaymentIntent> startConfirmPaymentIntent(int operationId, String paymentIntentId);

  Future<void> stopConfirmPaymentIntent(int operationId);

  Future<PaymentIntent> cancelPaymentIntent(String paymentIntentId);
//endregion

//region Saving payment details for later use

  Future<SetupIntent> createSetupIntent({
    required String? customerId,
    required Map<String, String>? metadata,
    required String? onBehalfOf,
    required String? description,
    required SetupIntentUsage? usage,
  });

  Future<SetupIntent> retrieveSetupIntent(String clientSecret);

  @MethodApi(swift: MethodApiType.callbacks)
  Future<SetupIntent> startCollectSetupIntentPaymentMethod({
    required int operationId,
    required String setupIntentId,
    required AllowRedisplay allowRedisplay,
    required bool customerCancellationEnabled,
  });

  Future<void> stopCollectSetupIntentPaymentMethod(int operationId);

  @MethodApi(swift: MethodApiType.callbacks)
  Future<SetupIntent> startConfirmSetupIntent(int operationId, String setupIntentId);

  Future<void> stopConfirmSetupIntent(int operationId);

  Future<SetupIntent> cancelSetupIntent(String setupIntentId);
//endregion

//region Card-present refunds

  @MethodApi(swift: MethodApiType.callbacks)
  Future<void> startCollectRefundPaymentMethod({
    required int operationId,
    required String chargeId,
    required int amount,
    required String currency,
    required Map<String, String>? metadata,
    required bool? reverseTransfer,
    required bool? refundApplicationFee,
    required bool customerCancellationEnabled,
  });

  Future<void> stopCollectRefundPaymentMethod(int operationId);

  @MethodApi(swift: MethodApiType.callbacks)
  Future<Refund> startConfirmRefund(int operationId);

  Future<void> stopConfirmRefund(int operationId);

//endregion

//region Display information to customers

  Future<void> setReaderDisplay(Cart cart);

  Future<void> clearReaderDisplay();

  @MethodApi(kotlin: MethodApiType.sync, swift: MethodApiType.sync)
  Future<void> setTapToPayUXConfiguration(TapToPayUxConfiguration configuration);
//endregion

  // TODO: add support to collectData and setLocalMobileUxConfiguration methods

  static void _throwIfIsHostException(PlatformException exception) {
    if (exception.code != 'mek_stripe_terminal') return;

    throw _$deserializeTerminalException(exception.details);
  }
}

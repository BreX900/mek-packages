library stripe_terminal;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mek_stripe_terminal/src/models/cart.dart';
import 'package:mek_stripe_terminal/src/models/discover_config.dart';
import 'package:mek_stripe_terminal/src/models/location.dart';
import 'package:mek_stripe_terminal/src/models/payment.dart';
import 'package:mek_stripe_terminal/src/models/payment_intent.dart';
import 'package:mek_stripe_terminal/src/models/payment_method.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/reader_software_update.dart';
import 'package:mek_stripe_terminal/src/reader_delegates.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';
import 'package:one_for_all/one_for_all.dart';

part '_stripe_terminal_handlers.dart';
part 'stripe_terminal_platform.api.dart';

@HostApi(
  hostExceptionHandler: StripeTerminalPlatform._throwIfIsHostException,
  kotlinMethod: MethodApiType.callbacks,
  swiftMethod: MethodApiType.async,
)
class StripeTerminalPlatform extends _$StripeTerminalPlatform {
  @MethodApi(kotlin: MethodApiType.sync)
  @override
  Future<void> init();

//region Reader discovery, connection and updates

  @MethodApi(kotlin: MethodApiType.sync)
  @override
  Future<ConnectionStatus> connectionStatus();

  @override
  Stream<List<Reader>> discoverReaders({
    required DiscoveryMethod discoveryMethod,
    required bool simulated,
    required String? locationId,
  });

  @override
  Future<Reader> connectBluetoothReader(
    String serialNumber, {
    required String locationId,
    required bool autoReconnectOnUnexpectedDisconnect,
  });

  @override
  Future<Reader> connectHandoffReader(String serialNumber);

  @override
  Future<Reader> connectInternetReader(
    String serialNumber, {
    required bool failIfInUse,
  });

  @override
  Future<Reader> connectMobileReader(
    String serialNumber, {
    required String locationId,
  });

  @override
  Future<Reader> connectUsbReader(
    String serialNumber, {
    required String locationId,
    required bool autoReconnectOnUnexpectedDisconnect,
  });

  @MethodApi(kotlin: MethodApiType.sync)
  @override
  Future<Reader?> connectedReader();

  @override
  Future<void> cancelReaderReconnection();

  @override
  Future<List<Location>> listLocations({
    required String? endingBefore,
    required int? limit,
    required String? startingAfter,
  });

  @MethodApi(kotlin: MethodApiType.sync)
  @override
  Future<void> installAvailableUpdate();

  @override
  Future<void> cancelReaderUpdate();

  @override
  Future<void> disconnectReader();
//endregion

//region Taking payments
  @override
  Future<PaymentIntent> retrievePaymentIntent(String clientSecret);

  @MethodApi(swift: MethodApiType.callbacks)
  @override
  Future<PaymentIntent> startCollectPaymentMethod({
    required int operationId,
    required String paymentIntentId,
    required bool moto,
    required bool skipTipping,
  });

  @override
  Future<void> stopCollectPaymentMethod(int operationId);

  @override
  Future<PaymentIntent> processPayment(String paymentIntentId);
//endregion

//region Saving payment details for later use
  @MethodApi(swift: MethodApiType.callbacks)
  @override
  Future<PaymentMethod> startReadReusableCard({
    required int operationId,
    required String? customer,
    required Map<String, String>? metadata,
  });

  @override
  Future<void> stopReadReusableCard(int operationId);
//endregion

//region Display information to customers
  @override
  Future<void> setReaderDisplay(Cart cart);

  @override
  Future<void> clearReaderDisplay();
//endregion

  static void _throwIfIsHostException(PlatformException exception) {
    if (exception.code.isEmpty) return;
    throw TerminalException(
      rawCode: exception.code,
      message: exception.message,
      details: exception.details,
    );
  }
}

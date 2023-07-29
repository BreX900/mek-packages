library stripe_terminal;

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:mek_stripe_terminal/src/cancellable_future.dart';
import 'package:mek_stripe_terminal/src/models/cart.dart';
import 'package:mek_stripe_terminal/src/models/discover_config.dart';
import 'package:mek_stripe_terminal/src/models/location.dart';
import 'package:mek_stripe_terminal/src/models/payment.dart';
import 'package:mek_stripe_terminal/src/models/payment_intent.dart';
import 'package:mek_stripe_terminal/src/models/payment_method.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/stripe_terminal_exception.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:recase/recase.dart';

part '_stripe_terminal_handlers.dart';
part 'stripe_terminal.api.dart';

@HostApi(
  hostExceptionHandler: StripeTerminal._throwIfIsHostException,
  kotlinMethod: MethodApiType.callbacks,
  swiftMethod: MethodApiType.async,
)
class StripeTerminal extends _$StripeTerminal {
  static StripeTerminal? _instance;
  final _StripeTerminalHandlers _handlers;

  /// Creates an internal `StripeTerminal` instance
  StripeTerminal._(this._handlers);

  /// Initializes the terminal SDK
  static Future<StripeTerminal> getInstance({
    /// A callback function that returns a Future which resolves to a connection token from your backend
    /// Check out more at https://stripe.com/docs/terminal/payments/setup-integration#connection-token
    required Future<String> Function() fetchToken,
  }) async {
    if (_instance != null) return _instance!;

    final handlers = _StripeTerminalHandlers(fetchToken: fetchToken);
    _$setupStripeTerminalHandlers(handlers);
    final stripeTerminal = StripeTerminal._(handlers);

    await stripeTerminal._init();

    _instance = stripeTerminal;
    return stripeTerminal;
  }

  /// Returns a list of Location objects.
  @override
  Future<List<Location>> listLocations({
    String? endingBefore,
    int? limit,
    String? startingAfter,
  });

  /// Get the current [ConnectionStatus]
  @MethodApi(kotlin: MethodApiType.sync)
  @override
  Future<ConnectionStatus> connectionStatus();

  Stream<ConnectionStatus> get onConnectionStatusChange => _handlers.connectionStatusChangeStream;

  StreamController<List<Reader>>? _controller;

  /// Begins discovering readers matching the given DiscoveryConfiguration.
  Stream<List<Reader>> discoverReaders({
    DiscoveryMethod discoveryMethod = DiscoveryMethod.bluetoothScan,
    bool simulated = false,
    String? locationId,
  }) {
    unawaited(_controller?.close());
    final controller = StreamController<List<Reader>>(sync: true);
    _controller = controller;
    late StreamSubscription subscription;
    controller.onListen = () {
      final stream = _discoverReaders(
        discoveryMethod: discoveryMethod,
        simulated: simulated,
        locationId: locationId,
      );
      subscription = stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
    };
    controller.onCancel = () async => await subscription.cancel();
    return controller.stream;
  }

  /// Attempts to connect to the given bluetooth reader.
  /// [autoReconnectOnUnexpectedDisconnect] (Not implemented in IOS)
  ///
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  @override
  Future<Reader> connectBluetoothReader(
    String serialNumber, {
    required String locationId,
    bool autoReconnectOnUnexpectedDisconnect = false,
  });

  /// Attempts to connect to the given internet reader.
  ///
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  @override
  Future<Reader> connectInternetReader(
    String serialNumber, {
    bool failIfInUse = false,
  });

  /// Setup: https://stripe.com/docs/terminal/payments/setup-reader/tap-to-pay
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  @override
  Future<Reader> connectMobileReader(
    String serialNumber, {
    required String locationId,
  });

  /// Fetches the connected reader from the SDK. `null` if not connected
  @MethodApi(kotlin: MethodApiType.sync)
  @override
  Future<Reader?> connectedReader();

  /// Attempts to disconnect from the currently connected reader.
  @override
  Future<void> disconnectReader();

  Stream<Reader> get onUnexpectedReaderDisconnect => _handlers.unexpectedReaderDisconnectStream;

  @MethodApi(kotlin: MethodApiType.sync)
  @override
  Future<void> installAvailableUpdate(String serialNumber);

  /// Only available on IOS
  Stream<bool> get onReaderAvailableUpdate => _handlers.availableUpdateStream;

  /// Only available on IOS
  Stream<double> get onReportReaderSoftwareUpdateProgress =>
      _handlers.reportReaderSoftwareUpdateProgressStream;

  /// Updates the reader display with transaction information. This method is for display purposes
  /// only and has no correlation with what the customer is actually charged. Tax and total
  /// are also not automatically calculated and must be set in [Cart].
  @override
  Future<void> setReaderDisplay(Cart cart);

  /// Clears the reader display and resets it to the splash screen
  @override
  Future<void> clearReaderDisplay();

  /// Extracts payment method from the reader
  ///
  /// Only support `insert` operation on the reader
  CancelableFuture<PaymentMethod> readReusableCard({
    String? customer,
    Map<String, String>? metadata,
  }) {
    return CancelableFuture(_stopReadReusableCard, (id) async {
      return await _startReadReusableCard(
        operationId: id,
        customer: customer,
        metadata: metadata,
      );
    });
  }

  /// Starts reading payment method based on payment intent.
  ///
  /// Payment intent is supposed to be generated on your backend and the `clientSecret` of the payment intent
  /// should be passed to this function.
  @override
  Future<PaymentIntent> retrievePaymentIntent(String clientSecret);

  Stream<PaymentStatus> get onPaymentStatusChange => _handlers.paymentStatusChangeStream;

  ///
  /// With the payment intent retrieved capture the payment method. A sucessful function call
  /// should return an instance of `StripePaymentIntent` with status `requiresPaymentMethod`;
  ///
  /// Only supports `swipe`, `tap` and `insert` method
  CancelableFuture<PaymentIntent> collectPaymentMethod(
    PaymentIntent paymentIntent, {
    bool moto = false,
    bool skipTipping = false,
  }) {
    return CancelableFuture(_stopCollectPaymentMethod, (id) async {
      return await _startCollectPaymentMethod(
        operationId: id,
        paymentIntentId: paymentIntent.id,
        moto: moto,
        skipTipping: skipTipping,
      );
    });
  }

  Future<PaymentIntent> processPayment(PaymentIntent paymentIntent) async =>
      await _processPayment(paymentIntent.id);

  @MethodApi(kotlin: MethodApiType.sync)
  @override
  Future<void> _init();

  @override
  Stream<List<Reader>> _discoverReaders({
    DiscoveryMethod discoveryMethod = DiscoveryMethod.bluetoothScan,
    bool simulated = false,
    String? locationId,
  });

  @MethodApi(swift: MethodApiType.callbacks)
  @override
  Future<PaymentMethod> _startReadReusableCard({
    required int operationId,
    required String? customer,
    required Map<String, String>? metadata,
  });

  @override
  Future<void> _stopReadReusableCard(int operationId);

  @MethodApi(swift: MethodApiType.callbacks)
  @override
  Future<PaymentIntent> _startCollectPaymentMethod({
    required int operationId,
    required String paymentIntentId,
    required bool moto,
    required bool skipTipping,
  });

  @override
  Future<void> _stopCollectPaymentMethod(int operationId);

  @override
  Future<PaymentIntent> _processPayment(String paymentIntentId);

  static void _throwIfIsHostException(PlatformException exception) {
    final snakeCaseCode = exception.code.camelCase;
    final code =
        StripeTerminalExceptionCode.values.firstWhereOrNull((e) => e.name == snakeCaseCode);
    if (code == null) return;
    throw StripeTerminalException(code, exception.message, exception.details);
  }
}

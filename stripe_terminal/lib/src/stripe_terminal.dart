library stripe_terminal;

import 'dart:async';

import 'package:mek_stripe_terminal/src/cancellable_future.dart';
import 'package:mek_stripe_terminal/src/models/cart.dart';
import 'package:mek_stripe_terminal/src/models/discover_config.dart';
import 'package:mek_stripe_terminal/src/models/location.dart';
import 'package:mek_stripe_terminal/src/models/payment.dart';
import 'package:mek_stripe_terminal/src/models/payment_intent.dart';
import 'package:mek_stripe_terminal/src/models/payment_method.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/refund.dart';
import 'package:mek_stripe_terminal/src/models/setup_intent.dart';
import 'package:mek_stripe_terminal/src/platform/stripe_terminal_platform.dart';
import 'package:mek_stripe_terminal/src/reader_delegates.dart';

class StripeTerminal {
  static final _platformInstance = StripeTerminalPlatform();
  static StripeTerminalHandlers? _handlersInstance;

  static Future<StripeTerminal>? _instance;

  final StripeTerminalPlatform _platform;
  final StripeTerminalHandlers _handlers;

  /// Creates an internal `StripeTerminal` instance
  StripeTerminal._(this._platform, this._handlers);

  /// Initializes the terminal SDK
  static Future<StripeTerminal> getInstance({
    bool shouldPrintLogs = false,

    /// A callback function that returns a Future which resolves to a connection token from your backend
    /// Check out more at https://stripe.com/docs/terminal/payments/setup-integration#connection-token
    required Future<String> Function() fetchToken,
  }) {
    final platform = _platformInstance;
    final handlers = _handlersInstance ??= StripeTerminalHandlers(
      platform: platform,
      fetchToken: fetchToken,
    );

    return _instance ??= (() async {
      try {
        await platform.init(shouldPrintLogs: shouldPrintLogs);
        return StripeTerminal._(platform, handlers);
      } catch (_) {
        _instance = null;
        rethrow;
      }
    }());
  }

  Future<void> clearCachedCredentials() async => await _platform.clearCachedCredentials();

//region Reader discovery, connection and updates
  Stream<ConnectionStatus> get onConnectionStatusChange => _handlers.connectionStatusChangeStream;

  /// Get the current [ConnectionStatus]
  Future<ConnectionStatus> connectionStatus() async => await _platform.connectionStatus();

  Stream<Reader> get onUnexpectedReaderDisconnect => _handlers.unexpectedReaderDisconnectStream;

  StreamController<List<Reader>>? _controller;

  /// Begins discovering readers matching the given DiscoveryConfiguration.
  Stream<List<Reader>> discoverReaders({
    DiscoveryMethod discoveryMethod = DiscoveryMethod.bluetoothScan,
    bool simulated = false,
    String? locationId,
  }) {
    _controller = _handleStream(_controller, () {
      return _platform.discoverReaders(
        discoveryMethod: discoveryMethod,
        simulated: simulated,
        locationId: locationId,
      );
    });
    return _controller!.stream;
  }

  /// Attempts to connect to the given bluetooth reader.
  /// [autoReconnectOnUnexpectedDisconnect] (Not implemented in IOS)
  ///
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  Future<Reader> connectBluetoothReader(
    Reader reader, {
    required String locationId,
    bool autoReconnectOnUnexpectedDisconnect = false,
    BluetoothReaderDelegate? delegate,
    ReaderReconnectionDelegate? reconnectionDelegate,
  }) async {
    assert(!autoReconnectOnUnexpectedDisconnect || reconnectionDelegate == null);
    final connectedReader = await _platform.connectBluetoothReader(
      reader.serialNumber,
      locationId: locationId,
      autoReconnectOnUnexpectedDisconnect: autoReconnectOnUnexpectedDisconnect,
    );
    _handlers.attachReaderDelegates(delegate, reconnectionDelegate);
    return connectedReader;
  }

  /// Attempts to connect to the given internet reader.
  ///
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  Future<Reader> connectHandoffReader(Reader reader, {HandoffReaderDelegate? delegate}) async {
    final connectedReader = await _platform.connectHandoffReader(reader.serialNumber);
    _handlers.attachReaderDelegates(delegate, null);
    return connectedReader;
  }

  /// Attempts to connect to the given internet reader.
  ///
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  Future<Reader> connectInternetReader(
    Reader reader, {
    bool failIfInUse = false,
  }) async {
    return await _platform.connectInternetReader(reader.serialNumber, failIfInUse: failIfInUse);
  }

  /// Setup: https://stripe.com/docs/terminal/payments/setup-reader/tap-to-pay
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  Future<Reader> connectMobileReader(
    Reader reader, {
    required String locationId,
    LocalMobileReaderDelegate? delegate,
  }) async {
    final connectedReader = await _platform.connectMobileReader(
      reader.serialNumber,
      locationId: locationId,
    );
    _handlers.attachReaderDelegates(delegate, null);
    return connectedReader;
  }

  /// Attempts to connect to the given bluetooth reader.
  /// [autoReconnectOnUnexpectedDisconnect] (Not implemented in IOS)
  ///
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  Future<Reader> connectUsbReader(
    Reader reader, {
    required String locationId,
    bool autoReconnectOnUnexpectedDisconnect = false,
    ReaderDelegate? delegate,
    ReaderReconnectionDelegate? reconnectionDelegate,
  }) async {
    assert(!autoReconnectOnUnexpectedDisconnect || reconnectionDelegate == null);
    final connectedReader = await _platform.connectUsbReader(
      reader.serialNumber,
      locationId: locationId,
      autoReconnectOnUnexpectedDisconnect: autoReconnectOnUnexpectedDisconnect,
    );
    _handlers.attachReaderDelegates(delegate, reconnectionDelegate);
    return connectedReader;
  }

  /// Fetches the connected reader from the SDK. `null` if not connected
  Future<Reader?> connectedReader() async => await _platform.connectedReader();

  /// Returns a list of Location objects.
  Future<List<Location>> listLocations({
    String? endingBefore,
    int? limit,
    String? startingAfter,
  }) async {
    return await _platform.listLocations(
      endingBefore: endingBefore,
      limit: limit,
      startingAfter: startingAfter,
    );
  }

  Future<void> installAvailableUpdate() async => await _platform.installAvailableUpdate();

  /// Attempts to disconnect from the currently connected reader.
  Future<void> disconnectReader() async {
    await _platform.disconnectReader();
    _handlers.detachReaderDelegates();
  }
//endregion

//region Taking payments
  Stream<PaymentStatus> get onPaymentStatusChange => _handlers.paymentStatusChangeStream;

  Future<PaymentIntent> createPaymentIntent(PaymentIntentParameters parameters) async =>
      await _platform.createPaymentIntent(parameters);

  /// Starts reading payment method based on payment intent.
  ///
  /// Payment intent is supposed to be generated on your backend and the `clientSecret` of the payment intent
  /// should be passed to this function.
  Future<PaymentIntent> retrievePaymentIntent(String clientSecret) async =>
      await _platform.retrievePaymentIntent(clientSecret);

  /// With the payment intent retrieved capture the payment method. A sucessful function call
  /// should return an instance of `StripePaymentIntent` with status `requiresPaymentMethod`;
  ///
  /// Only supports `swipe`, `tap` and `insert` method
  CancelableFuture<PaymentIntent> collectPaymentMethod(
    PaymentIntent paymentIntent, {
    bool moto = false,
    bool skipTipping = false,
  }) {
    return CancelableFuture(_platform.stopCollectPaymentMethod, (id) async {
      return await _platform.startCollectPaymentMethod(
        operationId: id,
        paymentIntentId: paymentIntent.id,
        moto: moto,
        skipTipping: skipTipping,
      );
    });
  }

  Future<PaymentIntent> processPayment(PaymentIntent paymentIntent) async =>
      await _platform.processPayment(paymentIntent.id);

  Future<void> cancelPaymentIntent(PaymentIntent paymentIntent) async =>
      await _platform.cancelPaymentIntent(paymentIntent.id);
//endregion

//region Saving payment details for later use
  /// Extracts payment method from the reader
  ///
  /// Only support `insert` operation on the reader
  CancelableFuture<PaymentMethod> readReusableCard({
    String? customer,
    Map<String, String>? metadata,
  }) {
    return CancelableFuture(_platform.stopReadReusableCard, (id) async {
      return await _platform.startReadReusableCard(
        operationId: id,
        customer: customer,
        metadata: metadata,
      );
    });
  }

  Future<SetupIntent> createSetupIntent({
    required String? customerId,
    Map<String, String>? metadata,
    String? onBehalfOf,
    String? description,
    SetupIntentUsage? usage,
  }) async {
    return await _platform.createSetupIntent(
      customerId: customerId,
      metadata: metadata,
      onBehalfOf: onBehalfOf,
      description: description,
      usage: usage,
    );
  }

  Future<SetupIntent> retrieveSetupIntent(String clientSecret) async =>
      await _platform.retrieveSetupIntent(clientSecret);

  CancelableFuture<SetupIntent> collectSetupIntentPaymentMethod(
    SetupIntent setupIntent, {
    required bool customerConsentCollected,
  }) {
    return CancelableFuture(_platform.stopCollectSetupIntentPaymentMethod, (id) async {
      return await _platform.startCollectSetupIntentPaymentMethod(
        operationId: id,
        setupIntentId: setupIntent.id,
        customerConsentCollected: customerConsentCollected,
      );
    });
  }

  Future<SetupIntent> confirmSetupIntent(SetupIntent setupIntent) async =>
      _platform.confirmSetupIntent(setupIntent.id);

  Future<SetupIntent> cancelSetupIntent(SetupIntent setupIntent) async =>
      _platform.cancelSetupIntent(setupIntent.id);

//endregion

//region Card-present refunds

  CancelableFuture<void> collectRefundPaymentMethod({
    required String chargeId,
    required int amount,
    required String currency,
    Map<String, String>? metadata,
    bool? reverseTransfer,
    bool? refundApplicationFee,
  }) {
    return CancelableFuture(_platform.stopCollectRefundPaymentMethod, (id) async {
      return await _platform.startCollectRefundPaymentMethod(
        operationId: id,
        chargeId: chargeId,
        amount: amount,
        currency: currency,
        metadata: metadata,
        reverseTransfer: reverseTransfer,
        refundApplicationFee: refundApplicationFee,
      );
    });
  }

  Future<Refund> processRefund() async => await _platform.processRefund();
//endregion

//region Display information to customers
  /// Updates the reader display with transaction information. This method is for display purposes
  /// only and has no correlation with what the customer is actually charged. Tax and total
  /// are also not automatically calculated and must be set in [Cart].
  Future<void> setReaderDisplay(Cart cart) async => await _platform.setReaderDisplay(cart);

  /// Clears the reader display and resets it to the splash screen
  Future<void> clearReaderDisplay() async => await _platform.clearReaderDisplay();
//endregion

  StreamController<T> _handleStream<T>(
    StreamController<T>? controller,
    Stream<T> Function() onListen,
  ) {
    unawaited(controller?.close());
    final newController = StreamController<T>(sync: true);
    late StreamSubscription subscription;
    newController.onListen = () {
      subscription = onListen().listen(
        newController.add,
        onError: newController.addError,
        onDone: newController.close,
      );
    };
    newController.onCancel = () async => await subscription.cancel();
    return newController;
  }
}

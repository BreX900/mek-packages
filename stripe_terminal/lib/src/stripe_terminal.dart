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
import 'package:mek_stripe_terminal/src/reader_delegates.dart';
import 'package:mek_stripe_terminal/src/stripe_terminal_platform.dart';

class StripeTerminal {
  static StripeTerminal? _instance;

  final StripeTerminalPlatform _platform;
  final StripeTerminalHandlers _handlers;

  /// Creates an internal `StripeTerminal` instance
  StripeTerminal._(this._platform, this._handlers);

  /// Initializes the terminal SDK
  static Future<StripeTerminal> getInstance({
    /// A callback function that returns a Future which resolves to a connection token from your backend
    /// Check out more at https://stripe.com/docs/terminal/payments/setup-integration#connection-token
    required Future<String> Function() fetchToken,
  }) async {
    if (_instance != null) return _instance!;

    final platform = StripeTerminalPlatform();
    await platform.init();

    final handlers = StripeTerminalHandlers(
      platform: platform,
      fetchToken: fetchToken,
    );

    final stripeTerminal = StripeTerminal._(platform, handlers);

    _instance = stripeTerminal;
    return stripeTerminal;
  }

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
    ReaderDelegate? delegate,
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
  Future<Reader> connectHandoffReader(Reader reader, {ReaderDelegate? delegate}) async {
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
  }) async {
    return await _platform.connectMobileReader(reader.serialNumber, locationId: locationId);
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

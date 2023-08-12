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

/// Parts documented with "???" are not yet validated
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
  /// The currently connected reader’s connectionStatus changed.
  ///
  /// You should not use this stream to detect when a reader unexpectedly disconnects from your app,
  /// as it cannot be used to accurately distinguish between expected and unexpected disconnect events.
  /// To detect unexpect disconnects (e.g. to automatically notify your user), you should instead use
  /// the [onUnexpectedReaderDisconnect] stream.
  Stream<ConnectionStatus> get onConnectionStatusChange => _handlers.connectionStatusChangeStream;

  /// Get the current [ConnectionStatus]
  Future<ConnectionStatus> getConnectionStatus() async => await _platform.getConnectionStatus();

  /// The reader disconnected unexpectedly (that is, without your app explicitly calling disconnectReader).
  ///
  /// In your implementation of this method, you should notify your user that the reader disconnected.
  /// You may also want to call discoverReaders to begin scanning for readers. Your app can attempt
  /// to automatically reconnect to the disconnected reader, or display UI for your user to re-connect to a reader.
  ///
  /// You can trigger this call in your app by powering off the connected reader.
  Stream<Reader> get onUnexpectedReaderDisconnect => _handlers.unexpectedReaderDisconnectStream;

  /// Use this method to determine whether the mobile device supports a given reader type using a
  /// particular discovery method.
  ///
  /// This is useful for the Local Mobile reader discovery method where support will vary according
  /// to operating system and hardware capabilities.
  ///
  /// [simulated] Determines whether to check for availability of simulated discovery to discover a device simulator.
  ///   The Terminal SDK comes with the ability to simulate behavior without using physical hardware.
  ///   This makes it easy to quickly test your integration end-to-end, from pairing with
  ///   a reader to taking payments.
  Future<bool> supportsReadersOfType({
    required DeviceType deviceType,
    required DiscoveryMethod discoveryMethod,
    required bool simulated,
  }) async {
    return _platform.supportsReadersOfType(
      deviceType: deviceType,
      discoveryMethod: discoveryMethod,
      simulated: simulated,
    );
  }

  StreamController<List<Reader>>? _controller;

  /// Begins discovering readers based on the given discovery configuration.
  ///
  /// When discoverReaders is called, the terminal begins scanning for readers using the settings.
  /// You must listen the stream to get notified of discovered readers and display discovery results to your user.
  ///
  /// You must call [connectBluetoothReader], [connectHandoffReader], [connectInternetReader],
  /// [connectMobileReader], [connectUsbReader] while a discovery is taking place. You can only
  /// connect to a reader that was returned from the stream.
  ///
  /// The discovery process will stop on its own when the terminal successfully connects to a reader,
  /// if the command is canceled, or if a discovery error occurs.
  ///
  /// If discoverReaders is canceled, the [StreamSubscription.onDone] listener will be called.
  ///
  /// When device is connected:
  /// - If the connection is successful, the [onConnectionStatusChange] stream will emit [ConnectionStatus.connected].
  /// - The SDK must be actively discovering readers in order to connect to one. The discovery process
  ///   will stop if this connection request succeeds, otherwise the SDK will continue discovering.
  /// When connect* method is called, the SDK uses a connection token and the given reader information
  ///   to register the reader to your Stripe account. If the SDK does not already have a connection token,
  ///   it will call the fetchToken method which was passed as an argument in [getInstance].
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

  /// Attempts to connect to the given Bluetooth reader with a given connection configuration.
  ///
  /// To connect to a Bluetooth reader, your app must register that reader to a Location upon connection.
  /// You should use a [DiscoveryMethod.bluetoothScan] at some point before connecting which specifies
  /// the location to which this reader belongs.
  ///
  /// Throughout the lifetime of the connection, the reader will communicate with your app via the
  /// [BluetoothReaderDelegate] to announce transaction status, battery level, and software update information.
  ///
  /// ??? If the reader’s battery is critically low the connect call will fail with
  /// SCPErrorBluetoothDisconnected. Plug your reader in to start charging and try again.
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

  /// Attempts to connect to the given Handoff reader with a given connection configuration.
  Future<Reader> connectHandoffReader(Reader reader, {HandoffReaderDelegate? delegate}) async {
    final connectedReader = await _platform.connectHandoffReader(reader.serialNumber);
    _handlers.attachReaderDelegates(delegate, null);
    return connectedReader;
  }

  /// Attempts to connect to the given Internet reader with a given connection configuration.
  Future<Reader> connectInternetReader(
    Reader reader, {
    bool failIfInUse = false,
  }) async {
    return await _platform.connectInternetReader(reader.serialNumber, failIfInUse: failIfInUse);
  }

  /// Attempts to connect to the given Local Mobile reader with a given connection configuration.
  ///
  /// To connect to a Local Mobile reader, your app must register that reader to a Location upon connection.
  /// You should pass a locationId to [discoverReaders] before connecting which specifies
  /// the location to which this reader belongs.
  ///
  /// Throughout the lifetime of the connection, the reader will communicate with your app via the
  /// [LocalMobileReaderDelegate] to announce transaction status, battery level, and software update information.
  ///
  /// Note that during connection, an update may occur to ensure that the local mobile reader has
  /// the most up to date software and configurations.
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

  /// Attempts to connect to the given Usb reader with a given connection configuration.
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

  /// Information about the connected SCPReader, or `null` if no reader is connected.
  Future<Reader?> getConnectedReader() async => await _platform.getConnectedReader();

  /// Retrieves a list of [Location] objects belonging to your merchant.
  ///
  /// You must specify the ID of one of these locations to register the reader to while connecting
  /// to a Bluetooth/Mobile/Usb readers.
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

  /// Installs the available update for the connected reader.
  ///
  /// Stripe Terminal reader updates will either be updated automatically upon connection,
  /// or announced as available but not automatically installed. When the Stripe Terminal SDK
  /// announces an optional update, you can present that update to your app’s user and let them
  /// decide when to perform that update. When your user chooses to perform a reader update, call
  /// this method to start the installation.
  ///
  /// In your app you should display the progress of the update to the user. You should also instruct
  /// the user to wait for the update to complete:
  /// “Do not leave this page, and keep the reader in range and powered on until the update is complete.”
  /// ??? You can set UIApplication.shared.isIdleTimerDisabled to true while the update is being installed to prevent the device from automatically locking.
  ///
  /// If an error occurs while installing the update (e.g. because the update was interrupted),
  /// delegate will receive [PhysicalReaderDelegate.onFinishInstallingUpdate] with the exception. If the
  /// update completed successfully, the same method will be called with `null` exception.
  ///
  /// You must implement the ability to update your reader’s software in your app. Though we expect
  /// required software updates to be very rare, by using Stripe Terminal, you are obligated
  /// to include this functionality.
  ///
  /// Note: It is an error to call this method when the SDK is connected to the Verifone P400 or WisePOS E readers.
  Future<void> installAvailableUpdate() async => await _platform.installAvailableUpdate();

  /// Attempts to disconnect from the currently connected reader.
  Future<void> disconnectReader() async {
    await _platform.disconnectReader();
    _handlers.detachReaderDelegates();
  }
//endregion

//region Taking payments
  /// The currently connected reader’s [PaymentStatus] changed.
  Stream<PaymentStatus> get onPaymentStatusChange => _handlers.paymentStatusChangeStream;

  /// The Terminal instance’s current payment status.
  Future<PaymentStatus> getPaymentStatus() async => await _platform.getPaymentStatus();

  /// Creates a new [PaymentIntent] with the given parameters.
  ///
  /// Note: If the information required to create a [PaymentIntent] isn’t readily available in your app,
  ///   you can create the [PaymentIntent] on your server and use the [retrievePaymentIntent] method
  ///   to retrieve the [PaymentIntent] in your app.
  ///   This cannot be used with the Verifone P400.
  Future<PaymentIntent> createPaymentIntent(PaymentIntentParameters parameters) async =>
      await _platform.createPaymentIntent(parameters);

  /// Retrieves a [PaymentIntent] with a client secret.
  ///
  /// If the information required to create a PaymentIntent isn’t readily available in your app,
  /// you can create the [PaymentIntent] on your server and use this method to retrieve the [PaymentIntent] in your app.
  Future<PaymentIntent> retrievePaymentIntent(String clientSecret) async =>
      await _platform.retrievePaymentIntent(clientSecret);

  /// Collects a payment method for the given [PaymentIntent].
  ///
  /// Note: [collectPaymentMethod] does not apply any changes to the [PaymentIntent] API object.
  ///   Updates to the [PaymentIntent] are local to the SDK, and persisted in-memory.
  ///
  /// After resolving the error, you may call collectPaymentMethod again to either try the same card again, or try a different card.
  ///
  /// If collecting a payment method succeeds, the method complete with a [PaymentIntent] with status
  /// [PaymentIntentStatus.requiresConfirmation], indicating that you should call [processPayment] to finish the payment.
  ///
  /// Note that if [collectPaymentMethod] is canceled, the future will be complete with a Canceled error.
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

  /// Processes a payment after collecting a payment method succeeds.
  ///
  /// **Synchronous capture**
  /// Stripe Terminal uses two-step card payments to prevent unintended and duplicate payments. When
  /// processPayment completes successfully, a charge has been authorized on the customer’s card,
  /// but not yet been “captured”. Your app must synchronously notify your backend to capture
  /// the [PaymentIntent] in order to settle the funds to your account.
  ///
  /// **Handling failures**
  /// ??? When processPayment fails, the SDK returns an error that includes the updated [PaymentIntent].
  /// Your app should inspect the updated [PaymentIntent] to decide how to retry the payment.
  ///
  /// If the updated PaymentIntent is nil, the request to Stripe’s servers timed out and
  /// the [PaymentIntent]’s status is unknown. We recommend that you retry [processPayment] with
  /// the original [PaymentIntent]. If you instead choose to abandon the original [PaymentIntent]
  /// and create a new one, do not capture the original [PaymentIntent]. If you do, you might
  /// charge your customer twice.
  ///
  /// If the updated [PaymentIntent]’s status is still [PaymentIntentStatus.requiresConfirmation]
  ///   (e.g., the request failed because your app is not connected to the internet), you can call
  ///   [processPayment] again with the updated [PaymentIntent] to retry the request.
  ///
  /// If the updated [PaymentIntent]’s status changes to [PaymentIntentStatus.requiresPaymentMethod]
  ///   (e.g., the request failed because the card was declined), call [collectPaymentMethod]
  ///   with the updated [PaymentIntent] to try charging another card.
  Future<PaymentIntent> processPayment(PaymentIntent paymentIntent) async =>
      await _platform.processPayment(paymentIntent.id);

  /// Cancels an [PaymentIntent].
  ///
  /// If the cancel request succeeds, the future complete with the updated [PaymentIntent] object
  /// with status [PaymentIntentStatus.canceled].
  ///
  /// Note: This cannot be used with the Verifone P400 reader.
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

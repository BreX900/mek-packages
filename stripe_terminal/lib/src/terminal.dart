library stripe_terminal;

import 'dart:async';

import 'package:mek_stripe_terminal/src/cancellable_future.dart';
import 'package:mek_stripe_terminal/src/models/cart.dart';
import 'package:mek_stripe_terminal/src/models/connection_configuration.dart';
import 'package:mek_stripe_terminal/src/models/discovery_configuration.dart';
import 'package:mek_stripe_terminal/src/models/location.dart';
import 'package:mek_stripe_terminal/src/models/payment.dart';
import 'package:mek_stripe_terminal/src/models/payment_intent.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/refund.dart';
import 'package:mek_stripe_terminal/src/models/setup_intent.dart';
import 'package:mek_stripe_terminal/src/models/simultator_configuration.dart';
import 'package:mek_stripe_terminal/src/models/tip.dart';
import 'package:mek_stripe_terminal/src/platform/terminal_platform.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';

/// Parts documented with "???" are not yet validated
class Terminal {
  static Terminal? _instance;
  static Terminal get instance {
    assert(_instance != null,
        'Please before use a Terminal instance init it with [Terminal.initTerminal] static method');
    return _instance!;
  }

  static final TerminalPlatform _platform = TerminalPlatform();
  static final TerminalHandlers _handlers = TerminalHandlers(_platform);

  Terminal._();

  static bool get isInitialized => _instance != null;

  /// Initializes the terminal SDK
  static Future<void> initTerminal({
    bool shouldPrintLogs = false,

    /// A callback function that returns a Future which resolves to a connection token from your backend
    /// Check out more at https://stripe.com/docs/terminal/payments/setup-integration#connection-token
    required Future<String> Function() fetchToken,
  }) async {
    if (_instance != null) {
      throw StateError('Already initialized!\n'
          'Retrieve it with [Terminal.instance] static getter or use [Terminal.clearCachedCredentials] method to re-fetch the token.');
    }
    if (_handlers.fetchToken != null) {
      throw StateError('Already initializing!\nWait a initialization!');
    }

    _handlers.fetchToken = fetchToken;
    try {
      await _platform.init(shouldPrintLogs: shouldPrintLogs);
      _instance = Terminal._();
    } catch (_) {
      _handlers.fetchToken = null;
      rethrow;
    }
  }

  /// Clears the current connection token, saved reader sessions, and any other cached credentials.
  /// You can use this method to switch accounts in your app, e.g. to switch between live and test
  /// Stripe API keys on your backend.
  ///
  /// In order to switch accounts in your app:
  /// - if a reader is connected, call [disconnectReader]
  /// - call [clearCachedCredentials]
  /// - call [discoverReaders] and [connectReader] to connect to a reader. The [connectReader] call
  ///   will request a new connection token from your backend server.
  ///
  /// An overview of the lifecycle of a connection token under the hood:
  /// - When a [Terminal] is initialized, the SDK attempts to proactively request a connection token
  ///   from your backend server.
  /// - When [connectReader] is called, the SDK uses the connection token and reader information to
  ///   create a reader session.
  /// - Subsequent calls to [connectReader] require a new connection token. If you disconnect from a
  ///   reader, and then call [connectReader] again, the SDK will fetch another connection token.
  Future<void> clearCachedCredentials() async {
    await _platform.clearCachedCredentials();
    _handlers.handleReaderDisconnection();
    _controller = null;
  }

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
    DeviceType? deviceType,
    required DiscoveryConfiguration discoveryConfiguration,
  }) async {
    return await _platform.supportsReadersOfType(
      deviceType: deviceType,
      discoveryConfiguration: discoveryConfiguration,
    );
  }

  // ignore: close_sinks
  StreamController<List<Reader>>? _controller;

  /// Begins discovering readers matching the given DiscoveryConfiguration.
  ///
  /// When discoverReaders is called, the terminal begins scanning for readers using the settings in
  /// the given [DiscoveryConfiguration]. You must listen the stream to handle displaying discovery
  /// results to your user and connecting to a selected reader.
  ///
  /// The discovery process will stop on its own when the terminal successfully connects to a reader,
  /// if the command is canceled, or if an error occurs. If the discovery process completes successfully,
  /// or if an error occurs, the stream will be emit that the operation is complete.
  ///
  /// To end discovery after a specified time interval, set the timeout property on your [DiscoveryConfiguration].
  ///
  /// Be sure to either set a timeout, or make it possible to cancel discover in your app's UI.
  ///
  /// When discovering readers in our handoff integration mode, discoverReaders will only return a
  /// reader if it has been registered. If the current reader has not been registered, discoverReaders
  /// will return an empty list of readers.
  ///
  /// See https://stripe.com/docs/terminal/readers/connecting.
  Stream<List<Reader>> discoverReaders(DiscoveryConfiguration discoveryConfiguration) {
    _controller = _handleStream(_controller, () {
      return _platform.discoverReaders(discoveryConfiguration);
    });
    return _controller!.stream;
  }

  /// Attempts to connect to the given reader, with the connection type dependent on config.
  ///
  /// If the connect succeeds, the future will be complete with the connected reader, and the
  /// terminal's [ConnectionStatus] will change to [ConnectionStatus.connected].
  ///
  /// If the connect fails, the future will throw an error.
  ///
  /// Under the hood, the SDK uses the `fetchToken` method you defined to fetch a connection token
  /// if it does not already have one. It then uses the connection token and reader information to
  /// create a reader session.
  ///
  /// See https://stripe.com/docs/terminal/readers/connecting.
  Future<Reader> connectReader(
    Reader reader, {
    required ConnectionConfiguration configuration,
  }) async {
    return _handlers.handleReaderConnection(configuration.readerDelegate, () async {
      return await _platform.connectReader(reader.serialNumber, configuration);
    });
  }

  /// Information about the connected [Reader], or `null` if no reader is connected.
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

  /// Reboots the connected reader.
  ///
  /// Note: This method is only available for Bluetooth and USB readers.
  Future<void> rebootReader() async => await _platform.rebootReader();

  /// Attempts to disconnect from the currently connected reader.
  Future<void> disconnectReader() async {
    await _platform.disconnectReader();
    _handlers.handleReaderDisconnection();
  }

  /// The simulator configuration settings that will be used when connecting to and creating payments
  /// with a simulated reader.
  Future<void> setSimulatorConfiguration(SimulatorConfiguration configuration) async =>
      await _platform.setSimulatorConfiguration(configuration);
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
  /// Note: [collectPaymentMethod] does not apply any changes to the [PaymentIntent] API object. Updates
  ///   to the [PaymentIntent] are local to the SDK, and persisted in-memory.
  ///
  /// After resolving the error, you may call [collectPaymentMethod] again to either try the same
  /// card again, or try a different card.
  ///
  /// If collecting a payment method succeeds, the method complete with a [PaymentIntent] with status
  /// [PaymentIntentStatus.requiresConfirmation], indicating that you should call [confirmPaymentIntent] to finish the payment.
  ///
  /// Note that if [collectPaymentMethod] is canceled, the future will be complete with a [TerminalExceptionCode.canceled] error.
  ///
  /// - [skipTipping] Bypass tipping selection if it would have otherwise been shown.
  /// - [tippingConfiguration] The tipping configuration for this payment collection.
  /// - [shouldUpdatePaymentIntent] Whether or not to update the [PaymentIntent] server side during
  ///   [collectPaymentMethod]. Attempting to collect with [shouldUpdatePaymentIntent] enabled and
  ///   a [PaymentIntent] created while offline will error with SCPErrorUpdatePaymentIntentUnavailableWhileOffline.
  /// - [customerCancellationEnabled] Whether to show a cancel button in transaction UI on Stripe smart readers.
  CancelableFuture<PaymentIntent> collectPaymentMethod(
    PaymentIntent paymentIntent, {
    bool requestDynamicCurrencyConversion = false,
    String? surchargeNotice,
    bool skipTipping = false,
    TippingConfiguration? tippingConfiguration,
    bool shouldUpdatePaymentIntent = false,
    bool customerCancellationEnabled = false,
  }) {
    return CancelableFuture(_platform.stopCollectPaymentMethod, (id) async {
      return await _platform.startCollectPaymentMethod(
        operationId: id,
        paymentIntentId: paymentIntent.id,
        requestDynamicCurrencyConversion: requestDynamicCurrencyConversion,
        surchargeNotice: surchargeNotice,
        skipTipping: skipTipping,
        tippingConfiguration: tippingConfiguration,
        shouldUpdatePaymentIntent: shouldUpdatePaymentIntent,
        customerCancellationEnabled: customerCancellationEnabled,
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
  /// the [PaymentIntent]’s status is unknown. We recommend that you retry [confirmPaymentIntent] with
  /// the original [PaymentIntent]. If you instead choose to abandon the original [PaymentIntent]
  /// and create a new one, do not capture the original [PaymentIntent]. If you do, you might
  /// charge your customer twice.
  ///
  /// If the updated [PaymentIntent]’s status is still [PaymentIntentStatus.requiresConfirmation]
  ///   (e.g., the request failed because your app is not connected to the internet), you can call
  ///   [confirmPaymentIntent] again with the updated [PaymentIntent] to retry the request.
  ///
  /// If the updated [PaymentIntent]’s status changes to [PaymentIntentStatus.requiresPaymentMethod]
  ///   (e.g., the request failed because the card was declined), call [collectPaymentMethod]
  ///   with the updated [PaymentIntent] to try charging another card.
  CancelableFuture<PaymentIntent> confirmPaymentIntent(PaymentIntent paymentIntent) {
    return CancelableFuture(_platform.stopConfirmPaymentIntent, (id) async {
      return await _platform.startConfirmPaymentIntent(id, paymentIntent.id);
    });
  }

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

  /// Creates a new [SetupIntent] with the given parameters.
  ///
  /// - [customerId] If present, the SetupIntent’s payment method will be attached to the Customer on
  ///   successful setup. Payment methods attached to other Customers cannot be used with this SetupIntent.
  /// - [metadata] Set of key-value pairs that you can attach to an object. This can be useful for
  ///   storing additional information about the object in a structured format.
  /// - [onBehalfOf] Connect Only:** The Stripe account ID for which this SetupIntent is created.
  /// - [description] An arbitrary string attached to the object. Often useful for displaying to users.
  /// - [usage] Indicates how the payment method is intended to be used in the future-
  Future<SetupIntent> createSetupIntent({
    String? customerId,
    Map<String, String>? metadata,
    String? onBehalfOf,
    String? description,
    SetupIntentUsage usage = SetupIntentUsage.offSession,
  }) async {
    return await _platform.createSetupIntent(
      customerId: customerId,
      metadata: metadata,
      onBehalfOf: onBehalfOf,
      description: description,
      usage: usage,
    );
  }

  /// Retrieves an [SetupIntent] with a client secret.
  ///
  /// If you’ve created a SetupIntent on your backend, you must retrieve it in the Stripe Terminal
  /// SDK before calling [collectSetupIntentPaymentMethod].
  Future<SetupIntent> retrieveSetupIntent(String clientSecret) async =>
      await _platform.retrieveSetupIntent(clientSecret);

  /// Collects a payment method for the given [SetupIntent].
  ///
  /// This method does not update the [SetupIntent] API object. All updates are local to the SDK
  /// and only persisted in memory. You must confirm the [SetupIntent] to create a PaymentMethod
  /// API object and (optionally) attach that PaymentMethod to a customer.
  ///
  /// After resolving the error, you may call [collectSetupIntentPaymentMethod] again to either
  /// try the same card again, or try a different card.
  ///
  /// If collecting a payment method succeeds returns with a [SetupIntent] with status
  /// [SetupIntentStatus.requiresConfirmation], indicating that you should call [confirmSetupIntent]
  /// to finish the payment.
  ///
  /// Note that if [collectSetupIntentPaymentMethod] is canceled returns [TerminalExceptionCode.canceled] error.
  ///
  /// Collecting cardholder consent
  ///   Card networks require that you collect consent from the customer before saving and reusing
  ///   their card information. The SetupIntent confirmation API method normally takes a mandate_data hash that lets you specify details about the customer’s consent. The Stripe Terminal SDK will fill in the mandate_data hash with relevant information, but in order for it to do so, you must specify whether you have gathered consent from the cardholder to collect their payment information in this method’s second parameter.
  ///
  ///   The payment method will not be collected without the cardholder’s consent.
  ///
  /// - [customerCancellationEnabled] Whether to show a cancel button in transaction UI on Stripe smart readers.
  CancelableFuture<SetupIntent> collectSetupIntentPaymentMethod(
    SetupIntent setupIntent, {
    required AllowRedisplay allowRedisplay,
    bool customerCancellationEnabled = false,
  }) {
    return CancelableFuture(_platform.stopCollectSetupIntentPaymentMethod, (id) async {
      return await _platform.startCollectSetupIntentPaymentMethod(
        operationId: id,
        setupIntentId: setupIntent.id,
        allowRedisplay: allowRedisplay,
        customerCancellationEnabled: customerCancellationEnabled,
      );
    });
  }

  /// Confirms a [SetupIntent] after the payment method has been successfully collected.
  ///
  /// Handling failures
  ///   When confirmSetupIntent fails, the SDK returns an error that includes the updated [SetupIntent].
  ///   Your app should inspect the updated [SetupIntent] to decide how to proceed.
  ///   1. If the updated [SetupIntent] is null, the request to Stripe’s servers timed out and the
  ///     [SetupIntent]’s status is null. We recommend that you retry [confirmSetupIntent] with
  ///     the original [SetupIntent].
  ///   2. If the updated [SetupIntent]’s status is still [SetupIntentStatus.requiresConfirmation]
  ///     (e.g., the request failed because your app is not connected to the internet), you can call
  ///     [confirmSetupIntent] again with the updated [SetupIntent] to retry the request.
  ///   3. If the updated [SetupIntent]’s status is [SetupIntentStatus.requiresAction], there might
  ///     be authentication the cardholder must perform offline before the saved PaymentMethod can be used.
  CancelableFuture<SetupIntent> confirmSetupIntent(SetupIntent setupIntent) {
    return CancelableFuture(_platform.stopConfirmSetupIntent, (id) async {
      return await _platform.startConfirmSetupIntent(id, setupIntent.id);
    });
  }

  /// Cancels an [SetupIntent].
  ///
  /// If the cancel request succeeds returns the updated [SetupIntent] object with status
  /// [SetupIntentStatus.cancelled].
  Future<SetupIntent> cancelSetupIntent(SetupIntent setupIntent) async =>
      await _platform.cancelSetupIntent(setupIntent.id);

//endregion

//region Card-present refunds

  /// Initiates an in-person refund by collecting the payment method that is to be refunded.
  ///
  /// Some payment methods, like Interac Debit payments, require that in-person payments
  /// also be refunded while the cardholder is present. The cardholder must present
  /// the Interac card to the card reader; these payments cannot be refunded via the dashboard or the API.
  ///
  /// For payment methods that don’t require the cardholder be present,
  /// see https://stripe.com/docs/terminal/payments/refunds
  ///
  /// This method, along with confirmRefund, allow you to design an in-person refund flow into your app.
  ///
  /// After resolving with the error, you may call [collectRefundPaymentMethod] again to either
  /// try the same card again, or try a different card.
  ///
  /// If collecting a payment method collected, you can call [confirmRefund] to finish refunding
  /// the payment method.
  ///
  /// Calling any other SDK methods between [collectRefundPaymentMethod] and [confirmRefund]
  /// will result in undefined behavior.
  ///
  /// Note that if [collectRefundPaymentMethod] is canceled, this method throw a [TerminalExceptionCode.canceled] error.
  ///
  /// - [chargeId] The ID of the charge to be refunded.
  /// - [amount] The amount of the refund, provided in the currency’s smallest unit.
  /// - [currency] Three-letter ISO currency code. Must be a supported currency.
  /// - [metadata] Set of key-value pairs that you can attach to an object. This can be useful
  ///   for storing additional information about the object in a structured format.
  /// - [reverseTransfer] Connect only: Nullable boolean indicating whether the transfer should
  ///   be reversed when refunding this charge. The transfer will be reversed proportionally to
  ///   the amount being refunded (either the entire or partial amount).
  /// - [refundApplicationFee] Connect only: Nullable boolean indicating whether the application
  ///   fee should be refunded when refunding this charge. If a full charge refund is given,
  ///   the full application fee will be refunded. Otherwise, the application fee will be refunded
  ///   in an amount proportional to the amount of the charge refunded.
  /// - [customerCancellationEnabled] Whether to show a cancel button in transaction UI on Stripe smart readers.
  CancelableFuture<void> collectRefundPaymentMethod({
    required String chargeId,
    required int amount,
    required String currency,
    Map<String, String>? metadata,
    bool? reverseTransfer,
    bool? refundApplicationFee,
    bool customerCancellationEnabled = false,
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
        customerCancellationEnabled: customerCancellationEnabled,
      );
    });
  }

  /// Confirms an in-person refund after the refund payment method has been collected.
  ///
  /// When [confirmRefund] fails, the SDK returns an error that either includes the failed [Refund].
  ///
  /// 1. If the refund property is null, the request to Stripe’s servers timed out and the refund’s
  ///   status is null. We recommend that you retry [confirmRefund] with the original parameters.
  /// 2. If the ConfirmRefundError has a failure_reason, the refund was declined. We recommend
  ///   that you take action based on the decline code you received.
  ///
  /// Note: collectRefundPaymentMethod:completion and confirmRefund are only available for payment
  ///   methods that require in-person refunds. For all other refunds, use the Stripe Dashboard or the Stripe API.
  CancelableFuture<Refund> confirmRefund() {
    return CancelableFuture(_platform.stopConfirmRefund, (id) async {
      return await _platform.startConfirmRefund(id);
    });
  }
//endregion

//region Display information to customers
  /// Updates the reader display with transaction information. This method is for display purposes
  /// only and has no correlation with what the customer is actually charged. Tax and total
  /// are also not automatically calculated and must be set in [Cart].
  ///
  /// Note: Only available for the Verifone P400 and BBPOS WisePOS E.
  Future<void> setReaderDisplay(Cart cart) async => await _platform.setReaderDisplay(cart);

  /// Clears the reader display and resets it to the splash screen.
  ///
  /// Note: Only available for the Verifone P400 and BBPOS WisePOS E.
  Future<void> clearReaderDisplay() async => await _platform.clearReaderDisplay();
//endregion

  StreamController<T> _handleStream<T>(
    StreamController<T>? oldController,
    Stream<T> Function() onListen,
  ) {
    unawaited(oldController?.close());
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

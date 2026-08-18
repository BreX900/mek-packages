import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mek_stripe_terminal/src/cancellable_future.dart';
import 'package:mek_stripe_terminal/src/models/cart.dart';
import 'package:mek_stripe_terminal/src/models/clear_cached_credentials.dart';
import 'package:mek_stripe_terminal/src/models/connection_configuration.dart';
import 'package:mek_stripe_terminal/src/models/discovery_configuration.dart';
import 'package:mek_stripe_terminal/src/models/easy_connect_configuration.dart';
import 'package:mek_stripe_terminal/src/models/location.dart';
import 'package:mek_stripe_terminal/src/models/payment_intent.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/refund.dart';
import 'package:mek_stripe_terminal/src/models/setup_intent.dart';
import 'package:mek_stripe_terminal/src/models/simulator_configuration.dart';
import 'package:mek_stripe_terminal/src/models/tap_to_pay_ux_configuration.dart';
import 'package:mek_stripe_terminal/src/models/tip.dart';
import 'package:mek_stripe_terminal/src/terminal_api.g.dart' as api;
import 'package:mek_stripe_terminal/src/terminal_api.g.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';
import 'package:mek_stripe_terminal/src/terminal_handlers.dart';

typedef PaymentStatus = PaymentStatusApi;

/// Parts documented with "???" are not yet validated
class Terminal {
  static Terminal? _instance;
  static Terminal get instance {
    assert(
      _instance != null,
      'Please before use a Terminal instance init it with [Terminal.initTerminal] static method',
    );
    return _instance!;
  }

  static final TerminalPlatformApi _platform = TerminalPlatformApi();
  static final TerminalHandlers _handlers = TerminalHandlers(_platform);

  Terminal._();

  static bool get isInitialized => _instance != null;

  /// Initializes the terminal SDK
  static Future<void> init({
    bool shouldPrintLogs = false,

    /// A callback function that returns a Future which resolves to a connection token from your backend
    /// Check out more at https://stripe.com/docs/terminal/payments/setup-integration#connection-token
    required Future<String> Function() fetchToken,
  }) async {
    if (_instance != null) {
      throw StateError(
        'Already initialized!\n'
        'Retrieve it with [Terminal.instance] static getter or use [Terminal.clearCachedCredentials] method to re-fetch the token.',
      );
    }
    if (_handlers.fetchToken != null) {
      throw StateError('Already initializing!\nWait a initialization!');
    }

    _handlers.fetchToken = fetchToken;
    try {
      await _platform.initialize(shouldPrintLogs: shouldPrintLogs);
      _instance = Terminal._();
    } catch (exception) {
      _handlers.fetchToken = null;
      if (exception is PlatformException) _throwIfIsHostException(exception);
      rethrow;
    }
  }

  /// Clears the current connection token, saved reader sessions, and any other cached credentials.
  /// You can use this method to switch accounts in your app, e.g. to switch between live and test
  /// Stripe API keys on your backend.
  ///
  /// A reader must not be connected when this method is called. If a reader is connected, the
  /// operation will fail with an [TerminalExceptionCode.unexpectedOperation] error.
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
  Future<ClearCachedCredentialsResult> clearCachedCredentials() => _run(() async {
    final result = await _platform.clearCachedCredentials();
    if (result.isSuccessful) {
      _handlers.handleReaderDisconnection();
      _controller = null;
    }
    return result;
  });

  //region Reader discovery, connection and updates
  /// The currently connected reader’s connectionStatus changed.
  ///
  /// You should not use this stream to detect when a reader unexpectedly disconnects from your app,
  /// as it cannot be used to accurately distinguish between expected and unexpected disconnect events.
  /// To detect unexpect disconnects (e.g. to automatically notify your user), you should instead use
  /// the [onUnexpectedReaderDisconnect] stream.
  Stream<ConnectionStatus> get onConnectionStatusChange => _handlers.connectionStatusChangeStream;

  /// Get the current [ConnectionStatus]
  Future<ConnectionStatus> getConnectionStatus() => _run(() async {
    return await _platform.getConnectionStatus();
  });

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
  }) => _run(() async {
    return await _platform.supportsReadersOfType(
      deviceType: deviceType,
      discoveryConfiguration: discoveryConfiguration,
    );
  });

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
    _controller = _handleStream(
      _controller,
      () =>
          _run(() async => await _platform.applyDiscoverReadersParameters(discoveryConfiguration)),
      () => api.discoverReaders().map((data) => data.cast<Reader>()),
    );
    return _controller!.stream;
  }

  /// Discovers and connects to a reader in a single call.
  CancelableFuture<Reader> easyConnect(EasyConnectConfiguration configuration) {
    return _CancelableFuture(_platform.stopEasyConnect, (id) async {
      return await _platform.startEasyConnect(operationId: id, configuration: configuration);
    });
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
  Future<Reader> connectReader(Reader reader, {required ConnectionConfiguration configuration}) =>
      _run(() async {
        return await _handlers.handleReaderConnection(configuration.readerDelegate, () async {
          return await _platform.connectReader(
            reader.serialNumber,
            configuration as ConnectionConfigurationApi,
          );
        });
      });

  /// Information about the connected [Reader], or `null` if no reader is connected.
  Future<Reader?> getConnectedReader() => _run(() async {
    return await _platform.getConnectedReader();
  });

  /// Retrieves a list of [Location] objects belonging to your merchant.
  ///
  /// You must specify the ID of one of these locations to register the reader to while connecting
  /// to a Bluetooth/Mobile/Usb readers.
  Future<List<Location>> listLocations({String? endingBefore, int? limit, String? startingAfter}) =>
      _run(() async {
        return await _platform.listLocations(
          endingBefore: endingBefore,
          limit: limit,
          startingAfter: startingAfter,
        );
      });

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
  Future<void> installAvailableUpdate() => _run(() async {
    await _platform.installAvailableUpdate();
  });

  /// Reboots the connected reader.
  ///
  /// Note: This method is only available for Bluetooth and USB readers.
  Future<void> rebootReader() => _run(() async {
    await _platform.rebootReader();
  });

  /// Attempts to disconnect from the currently connected reader.
  Future<void> disconnectReader() => _run(() async {
    await _platform.disconnectReader();
    _handlers.handleReaderDisconnection();
  });

  /// The simulator configuration settings that will be used when connecting to and creating payments
  /// with a simulated reader.
  Future<void> setSimulatorConfiguration(SimulatorConfiguration configuration) => _run(() async {
    await _platform.setSimulatorConfiguration(configuration);
  });
  //endregion

  //region Taking payments
  /// The currently connected reader’s [PaymentStatus] changed.
  Stream<PaymentStatus> get onPaymentStatusChange => _handlers.paymentStatusChangeStream;

  /// The Terminal instance’s current payment status.
  Future<PaymentStatus> getPaymentStatus() => _run(() async {
    return await _platform.getPaymentStatus();
  });

  /// Creates a new [PaymentIntent] with the given parameters.
  ///
  /// Note: If the information required to create a [PaymentIntent] isn’t readily available in your app,
  ///   you can create the [PaymentIntent] on your server and use the [retrievePaymentIntent] method
  ///   to retrieve the [PaymentIntent] in your app.
  ///   This cannot be used with the Verifone P400.
  Future<PaymentIntent> createPaymentIntent(PaymentIntentParameters parameters) => _run(() async {
    return await _platform.createPaymentIntent(parameters);
  });

  /// Retrieves a [PaymentIntent] with a client secret.
  ///
  /// If the information required to create a PaymentIntent isn’t readily available in your app,
  /// you can create the [PaymentIntent] on your server and use this method to retrieve the [PaymentIntent] in your app.
  Future<PaymentIntent> retrievePaymentIntent(String clientSecret) => _run(() async {
    return await _platform.retrievePaymentIntent(clientSecret);
  });

  /// Processes a PaymentIntent by collecting a payment method and confirming it.
  ///
  /// This method collects a payment method and confirms it in one call.
  // TODO: Move all parameters inside CollectPaymentIntentConfiguration
  // TODO: Remove null on [confirmConfiguration] parameter
  CancelableFuture<PaymentIntent> processPaymentIntent(
    PaymentIntent paymentIntent, {
    bool requestDynamicCurrencyConversion = false,
    String? surchargeNotice,
    bool skipTipping = false,
    TippingConfiguration? tippingConfiguration,
    bool shouldUpdatePaymentIntent = false,
    bool customerCancellationEnabled = true,
    AllowRedisplay allowRedisplay = AllowRedisplay.unspecified,
    ConfirmPaymentIntentConfiguration? confirmConfiguration,
  }) {
    return _CancelableFuture(_platform.stopProcessPaymentIntent, (id) async {
      return await _platform.startProcessPaymentIntent(
        operationId: id,
        paymentIntentId: paymentIntent.id,
        requestDynamicCurrencyConversion: requestDynamicCurrencyConversion,
        surchargeNotice: surchargeNotice,
        skipTipping: skipTipping,
        tippingConfiguration: tippingConfiguration,
        shouldUpdatePaymentIntent: shouldUpdatePaymentIntent,
        customerCancellationEnabled: customerCancellationEnabled,
        allowRedisplay: allowRedisplay,
        confirmConfiguration: confirmConfiguration ?? ConfirmPaymentIntentConfiguration(),
      );
    });
  }

  /// Cancels an [PaymentIntent].
  ///
  /// If the cancel request succeeds, the future complete with the updated [PaymentIntent] object
  /// with status [PaymentIntentStatus.canceled].
  ///
  /// Note: This cannot be used with the Verifone P400 reader.
  Future<PaymentIntent> cancelPaymentIntent(PaymentIntent paymentIntent) => _run(() async {
    return await _platform.cancelPaymentIntent(paymentIntent.id);
  });
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
  }) => _run(() async {
    return await _platform.createSetupIntent(
      customerId: customerId,
      metadata: metadata,
      onBehalfOf: onBehalfOf,
      description: description,
      usage: usage,
    );
  });

  /// Retrieves an [SetupIntent] with a client secret.
  ///
  /// If you’ve created a SetupIntent on your backend, you must retrieve it in the Stripe Terminal
  /// SDK before calling [processSetupIntent].
  Future<SetupIntent> retrieveSetupIntent(String clientSecret) => _run(() async {
    return await _platform.retrieveSetupIntent(clientSecret);
  });

  /// Processes a SetupIntent by collecting a payment method and confirming it.
  CancelableFuture<SetupIntent> processSetupIntent(
    SetupIntent setupIntent, {
    required AllowRedisplay allowRedisplay,
    bool customerCancellationEnabled = true,
  }) {
    return _CancelableFuture(_platform.stopProcessSetupIntent, (id) async {
      return await _platform.startProcessSetupIntent(
        operationId: id,
        setupIntentId: setupIntent.id,
        allowRedisplay: allowRedisplay,
        customerCancellationEnabled: customerCancellationEnabled,
      );
    });
  }

  /// Cancels an [SetupIntent].
  ///
  /// If the cancel request succeeds returns the updated [SetupIntent] object with status
  /// [SetupIntentStatus.cancelled].
  Future<SetupIntent> cancelSetupIntent(SetupIntent setupIntent) => _run(() async {
    return await _platform.cancelSetupIntent(setupIntent.id);
  });

  //endregion

  //region Card-present refunds

  /// Processes an in-person refund by collecting the payment method and confirming it.
  ///
  /// Some payment methods, like Interac Debit payments, require that in-person payments
  /// also be refunded while the cardholder is present. The cardholder must present
  /// the Interac card to the card reader; these payments cannot be refunded via the dashboard or the API.
  ///
  /// For payment methods that don't require the cardholder be present,
  /// see https://stripe.com/docs/terminal/payments/refunds
  ///
  /// - [chargeId] The ID of the charge to be refunded.
  /// - [amount] The amount of the refund, provided in the currency's smallest unit.
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
  CancelableFuture<Refund> processRefund({
    String? chargeId,
    String? paymentIntentId,
    String? paymentIntentClientSecret,
    required int amount,
    required String currency,
    Map<String, String>? metadata,
    bool? reverseTransfer,
    bool? refundApplicationFee,
    bool customerCancellationEnabled = true,
  }) {
    if (chargeId != null || (paymentIntentId != null && paymentIntentClientSecret != null)) {
      throw ArgumentError(
        'Either chargeId or (paymentIntentId and paymentIntentClientSecret) params must be provided to refund.',
      );
    }
    assert(!(chargeId != null && (paymentIntentId != null || paymentIntentClientSecret != null)));

    return _CancelableFuture(_platform.stopProcessRefund, (id) async {
      return await _platform.startProcessRefund(
        operationId: id,
        chargeId: chargeId,
        paymentIntentId: paymentIntentId,
        paymentIntentClientSecret: paymentIntentClientSecret,
        amount: amount,
        currency: currency,
        metadata: metadata,
        reverseTransfer: reverseTransfer,
        refundApplicationFee: refundApplicationFee,
        customerCancellationEnabled: customerCancellationEnabled,
      );
    });
  }
  //endregion

  //region Display information to customers
  /// Updates the reader display with transaction information. This method is for display purposes
  /// only and has no correlation with what the customer is actually charged. Tax and total
  /// are also not automatically calculated and must be set in [Cart].
  ///
  /// Note: Only available for the Verifone P400 and BBPOS WisePOS E.
  Future<void> setReaderDisplay(Cart cart) => _run(() async {
    await _platform.setReaderDisplay(cart);
  });

  /// Clears the reader display and resets it to the splash screen.
  ///
  /// Note: Only available for the Verifone P400 and BBPOS WisePOS E.
  Future<void> clearReaderDisplay() => _run(() async {
    await _platform.clearReaderDisplay();
  });

  /// Configure Tap to Pay UX
  Future<void> setTapToPayUXConfiguration(TapToPayUxConfiguration configuration) => _run(() async {
    await _platform.setTapToPayUXConfiguration(configuration);
  });

  /// Checks if the current Stripe account has a linked Tap to Pay on iPhone account (iOS only).
  Future<bool> isTapToPayAccountLinked({String? onBehalfOf}) => _run(() async {
    return await _platform.isTapToPayAccountLinked(onBehalfOf: onBehalfOf);
  });
  //endregion

  StreamController<T> _handleStream<T>(
    StreamController<T>? oldController,
    Future<void> Function() onSetup,
    Stream<T> Function() onListen,
  ) {
    unawaited(oldController?.close());

    final newController = StreamController<T>(sync: true);
    newController.onListen = () async {
      try {
        await onSetup();

        await newController.addStream(
          onListen().handleError((error, stackTrace) {
            if (error is PlatformException) _throwIfIsHostException(error);
            Error.throwWithStackTrace(error, stackTrace);
          }),
        );
      } catch (error, stackTrace) {
        newController.addError(error, stackTrace);
      }
    };
    return newController;
  }

  static Future<R> _run<R>(Future<R> Function() body) async {
    try {
      return await body();
    } on PlatformException catch (exception) {
      _throwIfIsHostException(exception);
      rethrow;
    }
  }
}

class _CancelableFuture<T> extends CancelableFuture<T> {
  final Future<T> Function(int id) _onStart;
  final Future<void> Function(int id) _onStop;

  _CancelableFuture(this._onStop, this._onStart);

  @override
  Future<T> onStart(int id) async {
    try {
      return await _onStart(id);
    } on PlatformException catch (exception) {
      _throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> onStop(int id) async {
    try {
      await _onStop(id);
    } on PlatformException catch (exception) {
      _throwIfIsHostException(exception);
      rethrow;
    }
  }
}

void _throwIfIsHostException(PlatformException exception) {
  if (exception.code != 'mek_stripe_terminal') return;
  final data = TerminalExceptionApi.decode(exception.details);
  throw TerminalException.fromApi(data);
}

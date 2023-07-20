library stripe_terminal;

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:mek_stripe_terminal/src/models/cart.dart';
import 'package:mek_stripe_terminal/src/models/collect_configuration.dart';
import 'package:mek_stripe_terminal/src/models/discover_config.dart';
import 'package:mek_stripe_terminal/src/models/location.dart';
import 'package:mek_stripe_terminal/src/models/payment.dart';
import 'package:mek_stripe_terminal/src/models/payment_intent.dart';
import 'package:mek_stripe_terminal/src/models/payment_method.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/stripe_terminal_exception.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:recase/recase.dart';

part 'stripe_terminal.api.dart';

class StripeTerminalException {
  final StripeTerminalExceptionCode code;
  final String? message;
  final String? details;

  const StripeTerminalException._(this.code, this.message, this.details);

  @override
  String toString() =>
      ['$runtimeType: ${code.name}', code.message, message, details].nonNulls.join('\n');
}

@HostApi(
  hostExceptionHandler: StripeTerminal._throwIfIsHostException,
)
class StripeTerminal extends _$StripeTerminalApi {
  static StripeTerminal? _instance;
  final _StripeTerminalHandlers _handlers;
  Stream<StripeReader>? _onUnexpectedReaderDisconnectStream;
  Stream<ConnectionStatus>? _onConnectionStatusChangeStream;
  Stream<PaymentStatus>? _onPaymentStatusChangeStream;

  /// Creates an internal `StripeTerminal` instance
  StripeTerminal._({
    required Future<String> Function() fetchToken,
  }) : _handlers = _StripeTerminalHandlers(fetchToken: fetchToken) {
    _$setupStripeTerminalHandlersApi(_handlers);
  }

  /// Initializes the terminal SDK
  static Future<StripeTerminal> getInstance({
    /// A callback function that returns a Future which resolves to a connection token from your backend
    /// Check out more at https://stripe.com/docs/terminal/payments/setup-integration#connection-token
    required Future<String> Function() fetchToken,
  }) async {
    if (_instance != null) return _instance!;
    final stripeTerminal = StripeTerminal._(fetchToken: fetchToken);
    await stripeTerminal._init();
    return stripeTerminal;
  }

  /// Attempts to connect to the given bluetooth reader.
  ///
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  @override
  Future<StripeReader> connectBluetoothReader(
    /// Serial number of the bluetooth reader to connect with
    String readerSerialNumber, {
    /// The id of the location on which you want to conenct this bluetooth reader with.
    ///
    /// Either you have to provide a location here or the device should already be registered to a location
    required String locationId,
  });

  /// Attempts to connect to the given internet reader.
  ///
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  @override
  Future<StripeReader> connectInternetReader(
    /// Serial number of the internet reader to connect with
    String readerSerialNumber, {
    /// Weather the connection process should fail if the device is already in use
    bool failIfInUse = false,
  });

  /// Setup: https://stripe.com/docs/terminal/payments/setup-reader/tap-to-pay
  /// Only works if you have scanned devices within this session.
  /// Always run `discoverReaders` before calling this function
  @override
  Future<StripeReader> connectMobileReader(
    String readerSerialNumber, {
    /// The id of the location on which you want to conenct this bluetooth reader with.
    ///
    /// Either you have to provide a location here or the device should already be registered to a location
    required String locationId,
  });

  /// Attempts to disconnect from the currently connected reader.
  @override
  Future<void> disconnectReader();

  Stream<StripeReader> get onUnexpectedReaderDisconnect =>
      _onUnexpectedReaderDisconnectStream ??= super._onUnexpectedReaderDisconnect();

  /// Updates the reader display with transaction information. This method is for display purposes
  /// only and has no correlation with what the customer is actually charged. Tax and total
  /// are also not automatically calculated and must be set in [Cart].
  @override
  Future<void> setReaderDisplay(Cart cart);

  /// Clears the reader display and resets it to the splash screen
  @override
  Future<void> clearReaderDisplay();

  /// Get the current [ConnectionStatus]
  @override
  Future<ConnectionStatus> connectionStatus();

  Stream<ConnectionStatus> get onConnectionStatusChange =>
      _onConnectionStatusChangeStream ??= super._onConnectionStatusChange();

  /// Fetches the connected reader from the SDK. `null` if not connected
  @override
  Future<StripeReader?> connectedReader();

  /// Extracts payment method from the reader
  ///
  /// Only support `insert` operation on the reader
  @override
  Future<StripePaymentMethod> readReusableCardDetail();

  /// Begins discovering readers matching the given DiscoveryConfiguration.
  ///
  /// Can contain an empty array if no readers are found.
  @override
  Stream<List<StripeReader>> discoverReaders(DiscoverConfig config);

  /// Starts reading payment method based on payment intent.
  ///
  /// Payment intent is supposed to be generated on your backend and the `clientSecret` of the payment intent
  /// should be passed to this function.
  @override
  Future<StripePaymentIntent> retrievePaymentIntent(
    // Client secret of the payment intent which you want to collect payment mwthod for
    String clientSecret,
  );

  Stream<PaymentStatus> get onPaymentStatusChange =>
      _onPaymentStatusChangeStream ??= super._onPaymentStatusChange();

  ///
  /// With the payment intent retrieved capture the payment method. A sucessful function call
  /// should return an instance of `StripePaymentIntent` with status `requiresPaymentMethod`;
  ///
  /// Only supports `swipe`, `tap` and `insert` method
  @override
  Future<StripePaymentIntent> collectPaymentMethod(
    // Client secret of the payment intent which you want to collect payment mwthod for
    String clientSecret, {
    /// Configruation for the collection process
    CollectConfiguration collectConfiguration = const CollectConfiguration(
      skipTipping: true,
    ),
  });

  @override
  Future<StripePaymentIntent> processPayment(
    // Client secret of the payment intent which you want to collect payment mwthod for
    String clientSecret,
  );

  // /// Confirm that your customer intends to set up the current or provided payment method.
  // Future<void> confirmSetupIntent(String clientSecret);
  //
  // /// Cancel an existing SetupIntent.
  // Future<void> cancelSetupIntent();

  /// Returns a list of Location objects.
  // TODO: Add parameters
  @override
  Future<List<Location>> listLocations();

  @override
  Future<void> _init();

  @override
  Stream<ConnectionStatus> _onConnectionStatusChange();

  @override
  Stream<StripeReader> _onUnexpectedReaderDisconnect();

  @override
  Stream<PaymentStatus> _onPaymentStatusChange();

  static void _throwIfIsHostException(PlatformException exception) {
    final snakeCaseCode = exception.code.camelCase;
    final code =
        StripeTerminalExceptionCode.values.firstWhereOrNull((e) => e.name == snakeCaseCode);
    if (code == null) return;
    throw StripeTerminalException._(code, exception.message, exception.details);
  }
}

@FlutterApi()
class _StripeTerminalHandlers {
  final Future<String> Function() _fetchToken;

  _StripeTerminalHandlers({
    required Future<String> Function() fetchToken,
  }) : _fetchToken = fetchToken;

  Future<String> _onRequestConnectionToken() async => await _fetchToken();
}

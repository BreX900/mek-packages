library stripe_terminal;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mek_stripe_terminal/src/models/cart.dart';
import 'package:mek_stripe_terminal/src/models/collect_configuration.dart';
import 'package:mek_stripe_terminal/src/models/discover_config.dart';
import 'package:mek_stripe_terminal/src/models/payment_intent.dart';
import 'package:mek_stripe_terminal/src/models/payment_method.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:one_for_all/one_for_all.dart';

part 'stripe_terminal.api.dart';

@ApiScheme()
abstract class StripeTerminal {
  Future<String> Function()? _fetchToken;
  StreamController<List<StripeReader>>? _readersController;

  /// Creates an internal `StripeTerminal` instance
  StripeTerminal._();

  /// Initializes the terminal SDK
  static Future<StripeTerminal> getInstance({
    /// A callback function that returns a Future which resolves to a connection token from your backend
    /// Check out more at https://stripe.com/docs/terminal/payments/setup-integration#connection-token
    required Future<String> Function() fetchToken,
  }) async {
    final StripeTerminal stripeTerminal = _$StripeTerminal();
    stripeTerminal._fetchToken = fetchToken;
    await stripeTerminal._init();
    return stripeTerminal;
  }

  /// Connects to a bluetooth reader, only works if you have scanned devices within this session.
  ///
  /// Always run `discoverReaders` before calling this function
  Future<StripeReader> connectBluetoothReader(
    /// Serial number of the bluetooth reader to connect with
    String readerSerialNumber, {
    /// The id of the location on which you want to conenct this bluetooth reader with.
    ///
    /// Either you have to provide a location here or the device should already be registered to a location
    String? locationId,
  });

  /// Connects to a internet reader, only works if you have scanned devices within this session.
  ///
  /// Always run `discoverReaders` before calling this function
  Future<StripeReader> connectInternetReader(
    /// Serial number of the internet reader to connect with
    String readerSerialNumber, {
    /// Weather the connection process should fail if the device is already in use
    bool failIfInUse = false,
  });

  @protected
  Future<void> listLocations();

  Future<StripeReader> connectMobileReader(String readerSerialNumber);

  /// Disconnects from a reader, only works if you are connected to a device
  ///
  /// Always run `connectToReader` before calling this function
  Future<void> disconnectReader();

  /// Displays the content to the connected reader's display
  Future<void> setReaderDisplay(
    /// Display information for the reader to be shown on the screen
    ///
    /// Supports on the devices which has a display
    Cart cart,
  );

  /// Clears connected reader's displays
  Future<void> clearReaderDisplay();

  /// Checks the connection status of the SDK
  Future<ConnectionStatus> connectionStatus();

  /// Fetches the connected reader from the SDK. `null` if not connected
  Future<StripeReader?> fetchConnectedReader();

  /// Extracts payment method from the reader
  ///
  /// Only support `insert` operation on the reader
  Future<StripePaymentMethod> readReusableCardDetail();

  /// Starts scanning readers in the vicinity. This will return a list of readers.
  ///
  /// Can contain an empty array if no readers are found.
  ///
  /// [simulated] se to `true` will simulate readers which can be connected and tested.
  Stream<List<StripeReader>> discoverReaders(
    /// Configuration for the discovry process
    DiscoverConfig config,
  ) {
    _readersController ??= StreamController(
      onListen: () => _startDiscoverReaders(config),
      onCancel: () {
        _stopDiscoverReaders();
        _readersController = null;
      },
    );

    return _readersController!.stream;
  }

  /// Starts reading payment method based on payment intent.
  ///
  /// Payment intent is supposed to be generated on your backend and the `clientSecret` of the payment intent
  /// should be passed to this function.
  Future<StripePaymentIntent> retrievePaymentIntent(
    // Client secret of the payment intent which you want to collect payment mwthod for
    String clientSecret,
  );

  ///
  /// With the payment intent retrieved capture the payment method. A sucessful function call
  /// should return an instance of `StripePaymentIntent` with status `requiresPaymentMethod`;
  ///
  /// Only supports `swipe`, `tap` and `insert` method
  Future<StripePaymentIntent> collectPaymentMethod({
    /// Configruation for the collection process
    CollectConfiguration collectConfiguration = const CollectConfiguration(
      skipTipping: true,
    ),
  });

  Future<StripePaymentIntent> processPayment();

  Future<void> _init();

  Future<void> _startDiscoverReaders(DiscoverConfig config);

  Future<void> _stopDiscoverReaders();

  Future<String> _onRequestConnectionToken() async => await _fetchToken!();

  Future<void> _onReadersFound(List<StripeReader> readers) async {
    _readersController!.add(readers);
  }
}

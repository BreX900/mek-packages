library stripe_terminal;

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:mek_stripe_terminal/src/models/cart.dart';
import 'package:mek_stripe_terminal/src/models/collect_configuration.dart';
import 'package:mek_stripe_terminal/src/models/discover_config.dart';
import 'package:mek_stripe_terminal/src/models/location.dart';
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

@HostApiScheme(
  hostExceptionHandler: StripeTerminal._throwIfIsHostException,
)
abstract class StripeTerminal {
  final _StripeTerminalHandlers _handlers;

  /// Creates an internal `StripeTerminal` instance
  StripeTerminal._({
    required Future<String> Function() fetchToken,
  }) : _handlers = _StripeTerminalHandlers(fetchToken: fetchToken) {
    _$setupStripeTerminalHandlers(_handlers);
  }

  /// Initializes the terminal SDK
  static Future<StripeTerminal> getInstance({
    /// A callback function that returns a Future which resolves to a connection token from your backend
    /// Check out more at https://stripe.com/docs/terminal/payments/setup-integration#connection-token
    required Future<String> Function() fetchToken,
  }) async {
    final StripeTerminal stripeTerminal = _$StripeTerminal(fetchToken: fetchToken);
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
    required String locationId,
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

  Future<StripeReader> connectMobileReader(
    String readerSerialNumber, {
    /// The id of the location on which you want to conenct this bluetooth reader with.
    ///
    /// Either you have to provide a location here or the device should already be registered to a location
    required String locationId,
  });

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
    _handlers._readersController ??= StreamController(
      onListen: () async => await _startDiscoverReaders(config),
      onCancel: () async {
        await _stopDiscoverReaders();
        _handlers._readersController = null;
      },
    );

    return _handlers._readersController!.stream;
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
  Future<StripePaymentIntent> collectPaymentMethod(
    // Client secret of the payment intent which you want to collect payment mwthod for
    String clientSecret, {
    /// Configruation for the collection process
    CollectConfiguration collectConfiguration = const CollectConfiguration(
      skipTipping: true,
    ),
  });

  Future<StripePaymentIntent> processPayment(
    // Client secret of the payment intent which you want to collect payment mwthod for
    String clientSecret,
  );

  Future<List<Location>> listLocations();

  Future<void> _init();

  Future<void> _startDiscoverReaders(DiscoverConfig config);

  Future<void> _stopDiscoverReaders();

  static void _throwIfIsHostException(PlatformException exception) {
    final snakeCaseCode = exception.code.camelCase;
    final code =
        StripeTerminalExceptionCode.values.firstWhereOrNull((e) => e.name == snakeCaseCode);
    if (code == null) return;
    throw StripeTerminalException._(code, exception.message, exception.details);
  }
}

@FlutterApiScheme()
class _StripeTerminalHandlers {
  final Future<String> Function() _fetchToken;
  StreamController<List<StripeReader>>? _readersController;

  _StripeTerminalHandlers({
    required Future<String> Function() fetchToken,
  }) : _fetchToken = fetchToken;

  Future<String> _onRequestConnectionToken() async => await _fetchToken();

  Future<void> _onReadersFound(List<StripeReader> readers) async {
    _readersController!.add(readers);
  }
}

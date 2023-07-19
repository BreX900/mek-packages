part of 'stripe_terminal.dart';

class _$StripeTerminal extends StripeTerminal {
  _$StripeTerminal({required super.fetchToken}) : super._();

  static const _channel = MethodChannel('stripe_terminal');

  @override
  Future<StripeReader> connectBluetoothReader(
    String readerSerialNumber, {
    required String locationId,
  }) async {
    try {
      final result = await _channel.invokeMethod('connectBluetoothReader', [
        readerSerialNumber,
        locationId,
      ]);
      return _$deserializeStripeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<StripeReader> connectInternetReader(
    String readerSerialNumber, {
    bool failIfInUse = false,
  }) async {
    try {
      final result = await _channel.invokeMethod('connectInternetReader', [
        readerSerialNumber,
        failIfInUse,
      ]);
      return _$deserializeStripeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<StripeReader> connectMobileReader(
    String readerSerialNumber, {
    required String locationId,
  }) async {
    try {
      final result = await _channel.invokeMethod('connectMobileReader', [
        readerSerialNumber,
        locationId,
      ]);
      return _$deserializeStripeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> disconnectReader() async {
    try {
      await _channel.invokeMethod('disconnectReader', []);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> setReaderDisplay(Cart cart) async {
    try {
      await _channel.invokeMethod('setReaderDisplay', [
        _$serializeCart(cart),
      ]);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> clearReaderDisplay() async {
    try {
      await _channel.invokeMethod('clearReaderDisplay', []);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<ConnectionStatus> connectionStatus() async {
    try {
      final result = await _channel.invokeMethod('connectionStatus', []);
      return ConnectionStatus.values[result as int];
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<StripeReader?> fetchConnectedReader() async {
    try {
      final result = await _channel.invokeMethod('fetchConnectedReader', []);
      return result != null ? _$deserializeStripeReader(result as List) : null;
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<StripePaymentMethod> readReusableCardDetail() async {
    try {
      final result = await _channel.invokeMethod('readReusableCardDetail', []);
      return _$deserializeStripePaymentMethod(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<StripePaymentIntent> retrievePaymentIntent(String clientSecret) async {
    try {
      final result = await _channel.invokeMethod('retrievePaymentIntent', [
        clientSecret,
      ]);
      return _$deserializeStripePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<StripePaymentIntent> collectPaymentMethod(
    String clientSecret, {
    CollectConfiguration collectConfiguration =
        const CollectConfiguration(skipTipping: true),
  }) async {
    try {
      final result = await _channel.invokeMethod('collectPaymentMethod', [
        clientSecret,
        _$serializeCollectConfiguration(collectConfiguration),
      ]);
      return _$deserializeStripePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<StripePaymentIntent> processPayment(String clientSecret) async {
    try {
      final result = await _channel.invokeMethod('processPayment', [
        clientSecret,
      ]);
      return _$deserializeStripePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<List<Location>> listLocations() async {
    try {
      final result = await _channel.invokeMethod('listLocations', []);
      return (result as List)
          .map((e) => _$deserializeLocation(e as List))
          .toList();
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> _init() async {
    try {
      await _channel.invokeMethod('_init', []);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> _startDiscoverReaders(DiscoverConfig config) async {
    try {
      await _channel.invokeMethod('_startDiscoverReaders', [
        _$serializeDiscoverConfig(config),
      ]);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> _stopDiscoverReaders() async {
    try {
      await _channel.invokeMethod('_stopDiscoverReaders', []);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }
}

void _$setupStripeTerminalHandlers(_StripeTerminalHandlers hostApi) {
  const channel = MethodChannel('stripe_terminal_handlers');
  channel.setMethodCallHandler((call) async {
    final args = call.arguments as List<Object?>;
    return switch (call.method) {
      '_onRequestConnectionToken' => await hostApi._onRequestConnectionToken(),
      '_onReadersFound' => await hostApi._onReadersFound((args[0] as List)
          .map((e) => _$deserializeStripeReader(e as List))
          .toList()),
      _ => throw UnsupportedError(
          '_StripeTerminalHandlers#Flutter.${call.method} method'),
    };
  });
}

StripeReader _$deserializeStripeReader(List<Object?> serialized) =>
    StripeReader(
        locationStatus: LocationStatus.values[serialized[0] as int],
        batteryLevel: serialized[1] as double,
        deviceType: DeviceType.values[serialized[2] as int],
        simulated: serialized[3] as bool,
        availableUpdate: serialized[4] as bool,
        locationId: serialized[5] as String?,
        serialNumber: serialized[6] as String,
        label: serialized[7] as String?);
List<Object?> _$serializeCart(Cart deserialized) => [
      deserialized.currency,
      deserialized.tax,
      deserialized.total,
      deserialized.lineItems.map((e) => _$serializeCartLineItem(e)).toList()
    ];
List<Object?> _$serializeCartLineItem(CartLineItem deserialized) =>
    [deserialized.description, deserialized.quantity, deserialized.amount];
StripePaymentMethod _$deserializeStripePaymentMethod(
        List<Object?> serialized) =>
    StripePaymentMethod(
        id: serialized[0] as String,
        cardDetails: serialized[1] != null
            ? _$deserializeCardDetails(serialized[1] as List)
            : null,
        customer: serialized[2] as String?,
        livemode: serialized[3] as bool,
        metadata: (serialized[4] as Map?)
            ?.map((k, v) => MapEntry(k as String, v as String)));
CardDetails _$deserializeCardDetails(List<Object?> serialized) => CardDetails(
    brand: serialized[0] as String?,
    country: serialized[1] as String?,
    expMonth: serialized[2] as int,
    expYear: serialized[3] as int,
    fingerprint: serialized[4] as String?,
    funding: serialized[5] as String?,
    last4: serialized[6] as String?);
StripePaymentIntent _$deserializeStripePaymentIntent(
        List<Object?> serialized) =>
    StripePaymentIntent(
        id: serialized[0] as String,
        amount: serialized[1] as double,
        amountCapturable: serialized[2] as double,
        amountReceived: serialized[3] as double,
        application: serialized[4] as String?,
        applicationFeeAmount: serialized[5] as double?,
        captureMethod: serialized[6] as String?,
        cancellationReason: serialized[7] as String?,
        canceledAt: serialized[8] as int?,
        clientSecret: serialized[9] as String?,
        confirmationMethod: serialized[10] as String?,
        created: serialized[11] as int,
        currency: serialized[12] as String?,
        customer: serialized[13] as String?,
        description: serialized[14] as String?,
        invoice: serialized[15] as String?,
        livemode: serialized[16] as bool,
        metadata: (serialized[17] as Map?)
            ?.map((k, v) => MapEntry(k as String, v as String)),
        onBehalfOf: serialized[18] as String?,
        paymentMethodId: serialized[19] as String?,
        status: serialized[20] != null
            ? PaymentIntentStatus.values[serialized[20] as int]
            : null,
        review: serialized[21] as String?,
        receiptEmail: serialized[22] as String?,
        setupFutureUsage: serialized[23] as String?,
        transferGroup: serialized[24] as String?);
List<Object?> _$serializeCollectConfiguration(
        CollectConfiguration deserialized) =>
    [deserialized.skipTipping];
Location _$deserializeLocation(List<Object?> serialized) => Location(
    address: serialized[0] != null
        ? _$deserializeAddress(serialized[0] as List)
        : null,
    displayName: serialized[1] as String?,
    id: serialized[2] as String?,
    livemode: serialized[3] as bool?,
    metadata: (serialized[4] as Map?)
        ?.map((k, v) => MapEntry(k as String, v as String)));
Address _$deserializeAddress(List<Object?> serialized) => Address(
    city: serialized[0] as String?,
    country: serialized[1] as String?,
    line1: serialized[2] as String?,
    line2: serialized[3] as String?,
    postalCode: serialized[4] as String?,
    state: serialized[5] as String?);
List<Object?> _$serializeDiscoverConfig(DiscoverConfig deserialized) => [
      deserialized.discoveryMethod.index,
      deserialized.simulated,
      deserialized.locationId
    ];

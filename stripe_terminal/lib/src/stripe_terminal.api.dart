// ignore_for_file: unused_element

part of 'stripe_terminal.dart';

class _$StripeTerminalApi {
  static const _$channel = MethodChannel('StripeTerminal');

  static const _$discoverReaders =
      EventChannel('StripeTerminal#discoverReaders');

  static const _$onConnectionStatusChange =
      EventChannel('StripeTerminal#_onConnectionStatusChange');

  static const _$onUnexpectedReaderDisconnect =
      EventChannel('StripeTerminal#_onUnexpectedReaderDisconnect');

  static const _$onPaymentStatusChange =
      EventChannel('StripeTerminal#_onPaymentStatusChange');

  Stream<List<StripeReader>> discoverReaders(DiscoverConfig config) {
    return _$discoverReaders
        .receiveBroadcastStream([_$serializeDiscoverConfig(config)]).map((e) =>
            (e as List)
                .map((e) => _$deserializeStripeReader(e as List))
                .toList());
  }

  Stream<ConnectionStatus> _onConnectionStatusChange() {
    return _$onConnectionStatusChange.receiveBroadcastStream([]).map(
        (e) => ConnectionStatus.values[e as int]);
  }

  Stream<StripeReader> _onUnexpectedReaderDisconnect() {
    return _$onUnexpectedReaderDisconnect.receiveBroadcastStream([]).map(
        (e) => _$deserializeStripeReader(e as List));
  }

  Stream<PaymentStatus> _onPaymentStatusChange() {
    return _$onPaymentStatusChange
        .receiveBroadcastStream([]).map((e) => PaymentStatus.values[e as int]);
  }

  Future<StripeReader> connectBluetoothReader(
    String readerSerialNumber, {
    required String locationId,
  }) async {
    try {
      final result = await _$channel.invokeMethod(
          'connectBluetoothReader', [readerSerialNumber, locationId]);
      return _$deserializeStripeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<StripeReader> connectInternetReader(
    String readerSerialNumber, {
    bool failIfInUse = false,
  }) async {
    try {
      final result = await _$channel.invokeMethod(
          'connectInternetReader', [readerSerialNumber, failIfInUse]);
      return _$deserializeStripeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<StripeReader> connectMobileReader(
    String readerSerialNumber, {
    required String locationId,
  }) async {
    try {
      final result = await _$channel.invokeMethod(
          'connectMobileReader', [readerSerialNumber, locationId]);
      return _$deserializeStripeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> disconnectReader() async {
    try {
      await _$channel.invokeMethod('disconnectReader', []);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> setReaderDisplay(Cart cart) async {
    try {
      await _$channel.invokeMethod('setReaderDisplay', [_$serializeCart(cart)]);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> clearReaderDisplay() async {
    try {
      await _$channel.invokeMethod('clearReaderDisplay', []);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<ConnectionStatus> connectionStatus() async {
    try {
      final result = await _$channel.invokeMethod('connectionStatus', []);
      return ConnectionStatus.values[result as int];
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<StripeReader?> fetchConnectedReader() async {
    try {
      final result = await _$channel.invokeMethod('fetchConnectedReader', []);
      return result != null ? _$deserializeStripeReader(result as List) : null;
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<StripePaymentMethod> readReusableCardDetail() async {
    try {
      final result = await _$channel.invokeMethod('readReusableCardDetail', []);
      return _$deserializeStripePaymentMethod(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<StripePaymentIntent> retrievePaymentIntent(String clientSecret) async {
    try {
      final result =
          await _$channel.invokeMethod('retrievePaymentIntent', [clientSecret]);
      return _$deserializeStripePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<StripePaymentIntent> collectPaymentMethod(
    String clientSecret, {
    CollectConfiguration collectConfiguration =
        const CollectConfiguration(skipTipping: true),
  }) async {
    try {
      final result = await _$channel.invokeMethod('collectPaymentMethod', [
        clientSecret,
        _$serializeCollectConfiguration(collectConfiguration)
      ]);
      return _$deserializeStripePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<StripePaymentIntent> processPayment(String clientSecret) async {
    try {
      final result =
          await _$channel.invokeMethod('processPayment', [clientSecret]);
      return _$deserializeStripePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<List<Location>> listLocations() async {
    try {
      final result = await _$channel.invokeMethod('listLocations', []);
      return (result as List)
          .map((e) => _$deserializeLocation(e as List))
          .toList();
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> _init() async {
    try {
      await _$channel.invokeMethod('_init', []);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }
}

void _$setupStripeTerminalHandlersApi(_StripeTerminalHandlers hostApi) {
  const channel = MethodChannel('_StripeTerminalHandlers');
  channel.setMethodCallHandler((call) async {
    final args = call.arguments as List<Object?>;
    return switch (call.method) {
      '_onRequestConnectionToken' => await hostApi._onRequestConnectionToken(),
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
List<Object?> _$serializeDiscoverConfig(DiscoverConfig deserialized) => [
      deserialized.discoveryMethod.index,
      deserialized.simulated,
      deserialized.locationId
    ];
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

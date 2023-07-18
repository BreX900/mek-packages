part of 'stripe_terminal.dart';

class StripeTerminalException {
  StripeTerminalException._(
    this.code,
    this.message,
    this.details,
  );

  final StripeTerminalExceptionCode code;

  final String? message;

  final String? details;

  @override
  String toString() => ['$runtimeType: $code', code.message, message, details]
      .nonNulls
      .join('\n');
}

class _$StripeTerminal extends StripeTerminal {
  _$StripeTerminal() : super._() {
    _channel.setMethodCallHandler((call) async {
      final args = call.arguments as List<Object?>;
      return switch (call.method) {
        '_onRequestConnectionToken' => await _onRequestConnectionToken(),
        '_onReadersFound' => await _onReadersFound((args[0] as List)
            .map((e) => _$deserializeStripeReader(e as List))
            .toList()),
        _ => throw StateError('Not supported: ${call.method}'),
      };
    });
  }

  static const _channel = MethodChannel('stripe_terminal');

  void throwIfIsHostException(PlatformException exception) {
    final snakeCaseCode = exception.code.camelCase;
    final code = StripeTerminalExceptionCode.values
        .firstWhereOrNull((e) => e.name == snakeCaseCode);
    if (code == null) return;
    throw StripeTerminalException._(code, exception.message, exception.details);
  }

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
      throwIfIsHostException(exception);
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
      throwIfIsHostException(exception);
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
      throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> disconnectReader() async {
    try {
      await _channel.invokeMethod('disconnectReader', []);
    } on PlatformException catch (exception) {
      throwIfIsHostException(exception);
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
      throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> clearReaderDisplay() async {
    try {
      await _channel.invokeMethod('clearReaderDisplay', []);
    } on PlatformException catch (exception) {
      throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<ConnectionStatus> connectionStatus() async {
    try {
      final result = await _channel.invokeMethod('connectionStatus', []);
      return ConnectionStatus.values[result as int];
    } on PlatformException catch (exception) {
      throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<StripeReader?> fetchConnectedReader() async {
    try {
      final result = await _channel.invokeMethod('fetchConnectedReader', []);
      return result != null ? _$deserializeStripeReader(result as List) : null;
    } on PlatformException catch (exception) {
      throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<StripePaymentMethod> readReusableCardDetail() async {
    try {
      final result = await _channel.invokeMethod('readReusableCardDetail', []);
      return _$deserializeStripePaymentMethod(result as List);
    } on PlatformException catch (exception) {
      throwIfIsHostException(exception);
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
      throwIfIsHostException(exception);
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
      throwIfIsHostException(exception);
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
      throwIfIsHostException(exception);
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
      throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> _init() async {
    try {
      await _channel.invokeMethod('_init', []);
    } on PlatformException catch (exception) {
      throwIfIsHostException(exception);
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
      throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> _stopDiscoverReaders() async {
    try {
      await _channel.invokeMethod('_stopDiscoverReaders', []);
    } on PlatformException catch (exception) {
      throwIfIsHostException(exception);
      rethrow;
    }
  }
}

List<Object?> _$serializeStripeReader(StripeReader deserialized) => [
      deserialized.locationStatus.index,
      deserialized.batteryLevel,
      deserialized.deviceType.index,
      deserialized.simulated,
      deserialized.availableUpdate,
      deserialized.locationId,
      deserialized.serialNumber,
      deserialized.label
    ];
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
Cart _$deserializeCart(List<Object?> serialized) => Cart(
    currency: serialized[0] as String,
    tax: serialized[1] as int,
    total: serialized[2] as int,
    lineItems: (serialized[3] as List)
        .map((e) => _$deserializeCartLineItem(e as List))
        .toList());
List<Object?> _$serializeCartLineItem(CartLineItem deserialized) =>
    [deserialized.description, deserialized.quantity, deserialized.amount];
CartLineItem _$deserializeCartLineItem(List<Object?> serialized) =>
    CartLineItem(
        description: serialized[0] as String,
        quantity: serialized[1] as int,
        amount: serialized[2] as int);
List<Object?> _$serializeStripePaymentMethod(
        StripePaymentMethod deserialized) =>
    [
      deserialized.id,
      deserialized.cardDetails != null
          ? _$serializeCardDetails(deserialized.cardDetails!)
          : null,
      deserialized.customer,
      deserialized.livemode,
      deserialized.metadata?.map((k, v) => MapEntry(k, v))
    ];
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
List<Object?> _$serializeCardDetails(CardDetails deserialized) => [
      deserialized.brand,
      deserialized.country,
      deserialized.expMonth,
      deserialized.expYear,
      deserialized.fingerprint,
      deserialized.funding,
      deserialized.last4
    ];
CardDetails _$deserializeCardDetails(List<Object?> serialized) => CardDetails(
    brand: serialized[0] as String?,
    country: serialized[1] as String?,
    expMonth: serialized[2] as int,
    expYear: serialized[3] as int,
    fingerprint: serialized[4] as String?,
    funding: serialized[5] as String?,
    last4: serialized[6] as String?);
List<Object?> _$serializeStripePaymentIntent(
        StripePaymentIntent deserialized) =>
    [
      deserialized.id,
      deserialized.amount,
      deserialized.amountCapturable,
      deserialized.amountReceived,
      deserialized.application,
      deserialized.applicationFeeAmount,
      deserialized.captureMethod,
      deserialized.cancellationReason,
      deserialized.canceledAt,
      deserialized.clientSecret,
      deserialized.confirmationMethod,
      deserialized.created,
      deserialized.currency,
      deserialized.customer,
      deserialized.description,
      deserialized.invoice,
      deserialized.livemode,
      deserialized.metadata?.map((k, v) => MapEntry(k, v)),
      deserialized.onBehalfOf,
      deserialized.paymentMethodId,
      deserialized.status?.index,
      deserialized.review,
      deserialized.receiptEmail,
      deserialized.setupFutureUsage,
      deserialized.transferGroup
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
CollectConfiguration _$deserializeCollectConfiguration(
        List<Object?> serialized) =>
    CollectConfiguration(skipTipping: serialized[0] as bool);
List<Object?> _$serializeLocation(Location deserialized) => [
      deserialized.address != null
          ? _$serializeAddress(deserialized.address!)
          : null,
      deserialized.displayName,
      deserialized.id,
      deserialized.livemode,
      deserialized.metadata?.map((k, v) => MapEntry(k, v))
    ];
Location _$deserializeLocation(List<Object?> serialized) => Location(
    address: serialized[0] != null
        ? _$deserializeAddress(serialized[0] as List)
        : null,
    displayName: serialized[1] as String?,
    id: serialized[2] as String?,
    livemode: serialized[3] as bool?,
    metadata: (serialized[4] as Map?)
        ?.map((k, v) => MapEntry(k as String, v as String)));
List<Object?> _$serializeAddress(Address deserialized) => [
      deserialized.city,
      deserialized.country,
      deserialized.line1,
      deserialized.line2,
      deserialized.postalCode,
      deserialized.state
    ];
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
DiscoverConfig _$deserializeDiscoverConfig(List<Object?> serialized) =>
    DiscoverConfig(
        discoveryMethod: DiscoveryMethod.values[serialized[0] as int],
        simulated: serialized[1] as bool,
        locationId: serialized[2] as String?);

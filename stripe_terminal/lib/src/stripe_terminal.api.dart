// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'stripe_terminal.dart';

class _$StripeTerminal {
  static const _$channel = MethodChannel('StripeTerminal');

  static const _$discoverReaders =
      EventChannel('StripeTerminal#_discoverReaders');

  Stream<List<Reader>> _discoverReaders({
    DiscoveryMethod discoveryMethod = DiscoveryMethod.bluetoothScan,
    bool simulated = false,
    String? locationId,
  }) {
    return _$discoverReaders.receiveBroadcastStream([
      discoveryMethod.index,
      simulated,
      locationId
    ]).map(
        (e) => (e as List).map((e) => _$deserializeReader(e as List)).toList());
  }

  Future<List<Location>> listLocations({
    String? endingBefore,
    int? limit,
    String? startingAfter,
  }) async {
    try {
      final result = await _$channel
          .invokeMethod('listLocations', [endingBefore, limit, startingAfter]);
      return (result as List)
          .map((e) => _$deserializeLocation(e as List))
          .toList();
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

  Future<Reader> connectBluetoothReader(
    String serialNumber, {
    required String locationId,
    bool autoReconnectOnUnexpectedDisconnect = false,
  }) async {
    try {
      final result = await _$channel.invokeMethod('connectBluetoothReader',
          [serialNumber, locationId, autoReconnectOnUnexpectedDisconnect]);
      return _$deserializeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<Reader> connectInternetReader(
    String serialNumber, {
    bool failIfInUse = false,
  }) async {
    try {
      final result = await _$channel
          .invokeMethod('connectInternetReader', [serialNumber, failIfInUse]);
      return _$deserializeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<Reader> connectMobileReader(
    String serialNumber, {
    required String locationId,
  }) async {
    try {
      final result = await _$channel
          .invokeMethod('connectMobileReader', [serialNumber, locationId]);
      return _$deserializeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<Reader?> connectedReader() async {
    try {
      final result = await _$channel.invokeMethod('connectedReader', []);
      return result != null ? _$deserializeReader(result as List) : null;
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

  Future<void> installAvailableUpdate(String serialNumber) async {
    try {
      await _$channel.invokeMethod('installAvailableUpdate', [serialNumber]);
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

  Future<PaymentIntent> retrievePaymentIntent(String clientSecret) async {
    try {
      final result =
          await _$channel.invokeMethod('retrievePaymentIntent', [clientSecret]);
      return _$deserializePaymentIntent(result as List);
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

  Future<PaymentMethod> _startReadReusableCard({
    required int operationId,
    required String? customer,
    required Map<String, String>? metadata,
  }) async {
    try {
      final result = await _$channel.invokeMethod('_startReadReusableCard',
          [operationId, customer, metadata?.map((k, v) => MapEntry(k, v))]);
      return _$deserializePaymentMethod(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> _stopReadReusableCard(int operationId) async {
    try {
      await _$channel.invokeMethod('_stopReadReusableCard', [operationId]);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<PaymentIntent> _startCollectPaymentMethod({
    required int operationId,
    required String paymentIntentId,
    required bool moto,
    required bool skipTipping,
  }) async {
    try {
      final result = await _$channel.invokeMethod('_startCollectPaymentMethod',
          [operationId, paymentIntentId, moto, skipTipping]);
      return _$deserializePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> _stopCollectPaymentMethod(int operationId) async {
    try {
      await _$channel.invokeMethod('_stopCollectPaymentMethod', [operationId]);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<PaymentIntent> _processPayment(String paymentIntentId) async {
    try {
      final result =
          await _$channel.invokeMethod('_processPayment', [paymentIntentId]);
      return _$deserializePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminal._throwIfIsHostException(exception);
      rethrow;
    }
  }
}

void _$setupStripeTerminalHandlers(_StripeTerminalHandlers hostApi) {
  const channel = MethodChannel('_StripeTerminalHandlers');
  channel.setMethodCallHandler((call) async {
    final args = call.arguments as List<Object?>;
    return switch (call.method) {
      '_onRequestConnectionToken' => await hostApi._onRequestConnectionToken(),
      '_onUnexpectedReaderDisconnect' => await hostApi
          ._onUnexpectedReaderDisconnect(_$deserializeReader(args[0] as List)),
      '_onConnectionStatusChange' => await hostApi
          ._onConnectionStatusChange(ConnectionStatus.values[args[0] as int]),
      '_onPaymentStatusChange' => await hostApi
          ._onPaymentStatusChange(PaymentStatus.values[args[0] as int]),
      '_onAvailableUpdate' => await hostApi._onAvailableUpdate(args[0] as bool),
      '_onReportReaderSoftwareUpdateProgress' =>
        await hostApi._onReportReaderSoftwareUpdateProgress(args[0] as double),
      _ => throw UnsupportedError(
          '_StripeTerminalHandlers#Flutter.${call.method} method'),
    };
  });
}

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
Reader _$deserializeReader(List<Object?> serialized) => Reader(
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
PaymentIntent
    _$deserializePaymentIntent(List<Object?> serialized) =>
        PaymentIntent(
            id: serialized[0] as String,
            amount: serialized[1] as double,
            amountCapturable: serialized[2] as double,
            amountReceived: serialized[3] as double,
            application: serialized[4] as String?,
            applicationFeeAmount: serialized[5] as double?,
            captureMethod: serialized[6] as String?,
            cancellationReason: serialized[7] as String?,
            canceledAt: serialized[8] != null
                ? DateTime.fromMillisecondsSinceEpoch(serialized[8] as int)
                : null,
            clientSecret: serialized[9] as String?,
            confirmationMethod: serialized[10] as String?,
            created: DateTime.fromMillisecondsSinceEpoch(serialized[11] as int),
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
PaymentMethod
    _$deserializePaymentMethod(List<Object?> serialized) =>
        PaymentMethod(
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

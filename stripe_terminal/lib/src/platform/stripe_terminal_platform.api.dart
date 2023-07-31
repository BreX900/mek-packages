// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'stripe_terminal_platform.dart';

class _$StripeTerminalPlatform {
  static const _$channel = MethodChannel('StripeTerminalPlatform');

  static const _$discoverReaders =
      EventChannel('StripeTerminalPlatform#discoverReaders');

  Stream<List<Reader>> discoverReaders({
    required DiscoveryMethod discoveryMethod,
    required bool simulated,
    required String? locationId,
  }) {
    return _$discoverReaders.receiveBroadcastStream([
      discoveryMethod.index,
      simulated,
      locationId
    ]).map(
        (e) => (e as List).map((e) => _$deserializeReader(e as List)).toList());
  }

  Future<void> init() async {
    try {
      await _$channel.invokeMethod('init', []);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<ConnectionStatus> connectionStatus() async {
    try {
      final result = await _$channel.invokeMethod('connectionStatus', []);
      return ConnectionStatus.values[result as int];
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<bool> supportsReadersOfType({
    required DeviceType deviceType,
    required DiscoveryMethod discoveryMethod,
    required bool simulated,
  }) async {
    try {
      final result = await _$channel.invokeMethod('supportsReadersOfType',
          [deviceType.index, discoveryMethod.index, simulated]);
      return result as bool;
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<Reader> connectBluetoothReader(
    String serialNumber, {
    required String locationId,
    required bool autoReconnectOnUnexpectedDisconnect,
  }) async {
    try {
      final result = await _$channel.invokeMethod('connectBluetoothReader',
          [serialNumber, locationId, autoReconnectOnUnexpectedDisconnect]);
      return _$deserializeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<Reader> connectHandoffReader(String serialNumber) async {
    try {
      final result =
          await _$channel.invokeMethod('connectHandoffReader', [serialNumber]);
      return _$deserializeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<Reader> connectInternetReader(
    String serialNumber, {
    required bool failIfInUse,
  }) async {
    try {
      final result = await _$channel
          .invokeMethod('connectInternetReader', [serialNumber, failIfInUse]);
      return _$deserializeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
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
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<Reader> connectUsbReader(
    String serialNumber, {
    required String locationId,
    required bool autoReconnectOnUnexpectedDisconnect,
  }) async {
    try {
      final result = await _$channel.invokeMethod('connectUsbReader',
          [serialNumber, locationId, autoReconnectOnUnexpectedDisconnect]);
      return _$deserializeReader(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<Reader?> connectedReader() async {
    try {
      final result = await _$channel.invokeMethod('connectedReader', []);
      return result != null ? _$deserializeReader(result as List) : null;
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> cancelReaderReconnection() async {
    try {
      await _$channel.invokeMethod('cancelReaderReconnection', []);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<List<Location>> listLocations({
    required String? endingBefore,
    required int? limit,
    required String? startingAfter,
  }) async {
    try {
      final result = await _$channel
          .invokeMethod('listLocations', [endingBefore, limit, startingAfter]);
      return (result as List)
          .map((e) => _$deserializeLocation(e as List))
          .toList();
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> installAvailableUpdate() async {
    try {
      await _$channel.invokeMethod('installAvailableUpdate', []);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> cancelReaderUpdate() async {
    try {
      await _$channel.invokeMethod('cancelReaderUpdate', []);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> disconnectReader() async {
    try {
      await _$channel.invokeMethod('disconnectReader', []);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<PaymentIntent> retrievePaymentIntent(String clientSecret) async {
    try {
      final result =
          await _$channel.invokeMethod('retrievePaymentIntent', [clientSecret]);
      return _$deserializePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<PaymentIntent> startCollectPaymentMethod({
    required int operationId,
    required String paymentIntentId,
    required bool moto,
    required bool skipTipping,
  }) async {
    try {
      final result = await _$channel.invokeMethod('startCollectPaymentMethod',
          [operationId, paymentIntentId, moto, skipTipping]);
      return _$deserializePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> stopCollectPaymentMethod(int operationId) async {
    try {
      await _$channel.invokeMethod('stopCollectPaymentMethod', [operationId]);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<PaymentIntent> processPayment(String paymentIntentId) async {
    try {
      final result =
          await _$channel.invokeMethod('processPayment', [paymentIntentId]);
      return _$deserializePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<PaymentMethod> startReadReusableCard({
    required int operationId,
    required String? customer,
    required Map<String, String>? metadata,
  }) async {
    try {
      final result = await _$channel.invokeMethod('startReadReusableCard',
          [operationId, customer, metadata?.map((k, v) => MapEntry(k, v))]);
      return _$deserializePaymentMethod(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> stopReadReusableCard(int operationId) async {
    try {
      await _$channel.invokeMethod('stopReadReusableCard', [operationId]);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> setReaderDisplay(Cart cart) async {
    try {
      await _$channel.invokeMethod('setReaderDisplay', [_$serializeCart(cart)]);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> clearReaderDisplay() async {
    try {
      await _$channel.invokeMethod('clearReaderDisplay', []);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }
}

void _$setupStripeTerminalHandlers(StripeTerminalHandlers hostApi) {
  const channel = MethodChannel('StripeTerminalHandlers');
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
      '_onReaderReportEvent' =>
        hostApi._onReaderReportEvent(ReaderEvent.values[args[0] as int]),
      '_onReaderRequestDisplayMessage' =>
        hostApi._onReaderRequestDisplayMessage(
            ReaderDisplayMessage.values[args[0] as int]),
      '_onReaderRequestInput' => hostApi._onReaderRequestInput((args[0] as List)
          .map((e) => ReaderInputOption.values[e as int])
          .toList()),
      '_onReaderBatteryLevelUpdate' => hostApi._onReaderBatteryLevelUpdate(
          args[0] as double,
          args[1] != null ? BatteryStatus.values[args[1] as int] : null,
          args[2] as bool),
      '_onReaderReportLowBatteryWarning' =>
        hostApi._onReaderReportLowBatteryWarning(),
      '_onReaderReportAvailableUpdate' =>
        hostApi._onReaderReportAvailableUpdate(
            _$deserializeReaderSoftwareUpdate(args[0] as List)),
      '_onReaderStartInstallingUpdate' =>
        hostApi._onReaderStartInstallingUpdate(
            _$deserializeReaderSoftwareUpdate(args[0] as List)),
      '_onReaderReportSoftwareUpdateProgress' =>
        hostApi._onReaderReportSoftwareUpdateProgress(args[0] as double),
      '_onReaderFinishInstallingUpdate' =>
        hostApi._onReaderFinishInstallingUpdate(
            args[0] != null
                ? _$deserializeReaderSoftwareUpdate(args[0] as List)
                : null,
            args[1] != null
                ? _$deserializeTerminalException(args[1] as List)
                : null),
      '_onReaderReconnectFailed' => hostApi._onReaderReconnectFailed(),
      '_onReaderReconnectStarted' => hostApi._onReaderReconnectStarted(),
      '_onReaderReconnectSucceeded' => hostApi._onReaderReconnectSucceeded(),
      _ => throw UnsupportedError(
          'StripeTerminalHandlers#Flutter.${call.method} method'),
    };
  });
}

Address _$deserializeAddress(List<Object?> serialized) => Address(
    city: serialized[0] as String?,
    country: serialized[1] as String?,
    line1: serialized[2] as String?,
    line2: serialized[3] as String?,
    postalCode: serialized[4] as String?,
    state: serialized[5] as String?);
CardDetails _$deserializeCardDetails(List<Object?> serialized) => CardDetails(
    brand:
        serialized[0] != null ? CardBrand.values[serialized[0] as int] : null,
    country: serialized[1] as String?,
    expMonth: serialized[2] as int,
    expYear: serialized[3] as int,
    fingerprint: serialized[4] as String?,
    funding: serialized[5] != null
        ? CardFundingType.values[serialized[5] as int]
        : null,
    last4: serialized[6] as String?);
List<Object?> _$serializeCart(Cart deserialized) => [
      deserialized.currency,
      deserialized.tax,
      deserialized.total,
      deserialized.lineItems.map((e) => _$serializeCartLineItem(e)).toList()
    ];
List<Object?> _$serializeCartLineItem(CartLineItem deserialized) =>
    [deserialized.description, deserialized.quantity, deserialized.amount];
Location _$deserializeLocation(List<Object?> serialized) => Location(
    address: serialized[0] != null
        ? _$deserializeAddress(serialized[0] as List)
        : null,
    displayName: serialized[1] as String?,
    id: serialized[2] as String?,
    livemode: serialized[3] as bool?,
    metadata: (serialized[4] as Map)
        .map((k, v) => MapEntry(k as String, v as String)));
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
            metadata: (serialized[17] as Map)
                .map((k, v) => MapEntry(k as String, v as String)),
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
            metadata: (serialized[4] as Map)
                .map((k, v) => MapEntry(k as String, v as String)));
Reader _$deserializeReader(List<Object?> serialized) => Reader(
    locationStatus: serialized[0] != null
        ? LocationStatus.values[serialized[0] as int]
        : null,
    batteryLevel: serialized[1] as double,
    deviceType:
        serialized[2] != null ? DeviceType.values[serialized[2] as int] : null,
    simulated: serialized[3] as bool,
    availableUpdate: serialized[4] as bool,
    locationId: serialized[5] as String?,
    serialNumber: serialized[6] as String,
    label: serialized[7] as String?);
ReaderSoftwareUpdate _$deserializeReaderSoftwareUpdate(
        List<Object?> serialized) =>
    ReaderSoftwareUpdate(
        components: (serialized[0] as List)
            .map((e) => UpdateComponent.values[e as int])
            .toList(),
        keyProfileName: serialized[1] as String?,
        onlyInstallRequiredUpdates: serialized[2] as bool,
        requiredAt: DateTime.fromMillisecondsSinceEpoch(serialized[3] as int),
        settingsVersion: serialized[4] as String?,
        timeEstimate: UpdateTimeEstimate.values[serialized[5] as int],
        version: serialized[6] as String);
TerminalException _$deserializeTerminalException(List<Object?> serialized) =>
    TerminalException(
        rawCode: serialized[0] as String,
        message: serialized[1] as String?,
        details: serialized[2] as String?);

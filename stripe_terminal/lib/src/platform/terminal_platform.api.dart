// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: prefer_if_elements_to_conditional_expressions
// ignore_for_file: unnecessary_lambdas, unused_element

part of 'terminal_platform.dart';

class _$TerminalPlatform implements TerminalPlatform {
  static const _$channel = MethodChannel('mek_stripe_terminal#TerminalPlatform');

  static const _$discoverReaders =
      EventChannel('mek_stripe_terminal#TerminalPlatform#discoverReaders');

  @override
  Stream<List<Reader>> discoverReaders(DiscoveryConfiguration configuration) {
    return _$discoverReaders
        .receiveBroadcastStream([_$serializeDiscoveryConfiguration(configuration)])
        .map((e) => (e as List).map((e) => _$deserializeReader(e as List)).toList())
        .handleError((error, _) {
          if (error is PlatformException) TerminalPlatform._throwIfIsHostException(error);
          throw error;
        });
  }

  @override
  Future<void> init({required bool shouldPrintLogs}) async {
    try {
      await _$channel.invokeMethod('init', [shouldPrintLogs]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> clearCachedCredentials() async {
    try {
      await _$channel.invokeMethod('clearCachedCredentials', []);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<ConnectionStatus> getConnectionStatus() async {
    try {
      final result = await _$channel.invokeMethod('getConnectionStatus', []);
      return ConnectionStatus.values[result as int];
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<bool> supportsReadersOfType({
    required DeviceType? deviceType,
    required DiscoveryConfiguration discoveryConfiguration,
  }) async {
    try {
      final result = await _$channel.invokeMethod('supportsReadersOfType',
          [deviceType?.index, _$serializeDiscoveryConfiguration(discoveryConfiguration)]);
      return result as bool;
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<Reader> connectReader(
    String serialNumber,
    ConnectionConfiguration configuration,
  ) async {
    try {
      final result = await _$channel.invokeMethod(
          'connectReader', [serialNumber, _$serializeConnectionConfiguration(configuration)]);
      return _$deserializeReader(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<Reader?> getConnectedReader() async {
    try {
      final result = await _$channel.invokeMethod('getConnectedReader', []);
      return result != null ? _$deserializeReader(result as List) : null;
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> cancelReaderReconnection() async {
    try {
      await _$channel.invokeMethod('cancelReaderReconnection', []);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<List<Location>> listLocations({
    required String? endingBefore,
    required int? limit,
    required String? startingAfter,
  }) async {
    try {
      final result =
          await _$channel.invokeMethod('listLocations', [endingBefore, limit, startingAfter]);
      return (result as List).map((e) => _$deserializeLocation(e as List)).toList();
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> installAvailableUpdate() async {
    try {
      await _$channel.invokeMethod('installAvailableUpdate', []);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> cancelReaderUpdate() async {
    try {
      await _$channel.invokeMethod('cancelReaderUpdate', []);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> rebootReader() async {
    try {
      await _$channel.invokeMethod('rebootReader', []);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> disconnectReader() async {
    try {
      await _$channel.invokeMethod('disconnectReader', []);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> setSimulatorConfiguration(SimulatorConfiguration configuration) async {
    try {
      await _$channel.invokeMethod(
          'setSimulatorConfiguration', [_$serializeSimulatorConfiguration(configuration)]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<PaymentStatus> getPaymentStatus() async {
    try {
      final result = await _$channel.invokeMethod('getPaymentStatus', []);
      return PaymentStatus.values[result as int];
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<PaymentIntent> createPaymentIntent(PaymentIntentParameters parameters) async {
    try {
      final result = await _$channel
          .invokeMethod('createPaymentIntent', [_$serializePaymentIntentParameters(parameters)]);
      return _$deserializePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<PaymentIntent> retrievePaymentIntent(String clientSecret) async {
    try {
      final result = await _$channel.invokeMethod('retrievePaymentIntent', [clientSecret]);
      return _$deserializePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<PaymentIntent> startCollectPaymentMethod({
    required int operationId,
    required String paymentIntentId,
    required bool requestDynamicCurrencyConversion,
    required String? surchargeNotice,
    required bool skipTipping,
    required TippingConfiguration? tippingConfiguration,
    required bool shouldUpdatePaymentIntent,
    required bool customerCancellationEnabled,
    required AllowRedisplay allowRedisplay,
  }) async {
    try {
      final result = await _$channel.invokeMethod('startCollectPaymentMethod', [
        operationId,
        paymentIntentId,
        requestDynamicCurrencyConversion,
        surchargeNotice,
        skipTipping,
        tippingConfiguration != null ? _$serializeTippingConfiguration(tippingConfiguration) : null,
        shouldUpdatePaymentIntent,
        customerCancellationEnabled,
        allowRedisplay.index
      ]);
      return _$deserializePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> stopCollectPaymentMethod(int operationId) async {
    try {
      await _$channel.invokeMethod('stopCollectPaymentMethod', [operationId]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<PaymentIntent> startConfirmPaymentIntent(
    int operationId,
    String paymentIntentId,
  ) async {
    try {
      final result =
          await _$channel.invokeMethod('startConfirmPaymentIntent', [operationId, paymentIntentId]);
      return _$deserializePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> stopConfirmPaymentIntent(int operationId) async {
    try {
      await _$channel.invokeMethod('stopConfirmPaymentIntent', [operationId]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<PaymentIntent> cancelPaymentIntent(String paymentIntentId) async {
    try {
      final result = await _$channel.invokeMethod('cancelPaymentIntent', [paymentIntentId]);
      return _$deserializePaymentIntent(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<SetupIntent> createSetupIntent({
    required String? customerId,
    required Map<String, String>? metadata,
    required String? onBehalfOf,
    required String? description,
    required SetupIntentUsage? usage,
  }) async {
    try {
      final result = await _$channel.invokeMethod('createSetupIntent', [
        customerId,
        metadata?.map((k, v) => MapEntry(k, v)),
        onBehalfOf,
        description,
        usage?.index
      ]);
      return _$deserializeSetupIntent(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<SetupIntent> retrieveSetupIntent(String clientSecret) async {
    try {
      final result = await _$channel.invokeMethod('retrieveSetupIntent', [clientSecret]);
      return _$deserializeSetupIntent(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<SetupIntent> startCollectSetupIntentPaymentMethod({
    required int operationId,
    required String setupIntentId,
    required AllowRedisplay allowRedisplay,
    required bool customerCancellationEnabled,
  }) async {
    try {
      final result = await _$channel.invokeMethod('startCollectSetupIntentPaymentMethod',
          [operationId, setupIntentId, allowRedisplay.index, customerCancellationEnabled]);
      return _$deserializeSetupIntent(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> stopCollectSetupIntentPaymentMethod(int operationId) async {
    try {
      await _$channel.invokeMethod('stopCollectSetupIntentPaymentMethod', [operationId]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<SetupIntent> startConfirmSetupIntent(
    int operationId,
    String setupIntentId,
  ) async {
    try {
      final result =
          await _$channel.invokeMethod('startConfirmSetupIntent', [operationId, setupIntentId]);
      return _$deserializeSetupIntent(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> stopConfirmSetupIntent(int operationId) async {
    try {
      await _$channel.invokeMethod('stopConfirmSetupIntent', [operationId]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<SetupIntent> cancelSetupIntent(String setupIntentId) async {
    try {
      final result = await _$channel.invokeMethod('cancelSetupIntent', [setupIntentId]);
      return _$deserializeSetupIntent(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> startCollectRefundPaymentMethod({
    required int operationId,
    required String chargeId,
    required int amount,
    required String currency,
    required Map<String, String>? metadata,
    required bool? reverseTransfer,
    required bool? refundApplicationFee,
    required bool customerCancellationEnabled,
  }) async {
    try {
      await _$channel.invokeMethod('startCollectRefundPaymentMethod', [
        operationId,
        chargeId,
        amount,
        currency,
        metadata?.map((k, v) => MapEntry(k, v)),
        reverseTransfer,
        refundApplicationFee,
        customerCancellationEnabled
      ]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> stopCollectRefundPaymentMethod(int operationId) async {
    try {
      await _$channel.invokeMethod('stopCollectRefundPaymentMethod', [operationId]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<Refund> startConfirmRefund(int operationId) async {
    try {
      final result = await _$channel.invokeMethod('startConfirmRefund', [operationId]);
      return _$deserializeRefund(result as List);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> stopConfirmRefund(int operationId) async {
    try {
      await _$channel.invokeMethod('stopConfirmRefund', [operationId]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> setReaderDisplay(Cart cart) async {
    try {
      await _$channel.invokeMethod('setReaderDisplay', [_$serializeCart(cart)]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> clearReaderDisplay() async {
    try {
      await _$channel.invokeMethod('clearReaderDisplay', []);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  @override
  Future<void> setTapToPayUXConfiguration(TapToPayUxConfiguration configuration) async {
    try {
      await _$channel.invokeMethod(
          'setTapToPayUXConfiguration', [_$serializeTapToPayUxConfiguration(configuration)]);
    } on PlatformException catch (exception) {
      TerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }
}

void _$setupTerminalHandlers(TerminalHandlers hostApi) {
  const channel = MethodChannel('mek_stripe_terminal#TerminalHandlers');
  channel.setMethodCallHandler((call) async {
    final args = call.arguments as List<Object?>;
    return switch (call.method) {
      '_onRequestConnectionToken' => await hostApi._onRequestConnectionToken(),
      '_onConnectionStatusChange' =>
        hostApi._onConnectionStatusChange(ConnectionStatus.values[args[0] as int]),
      '_onPaymentStatusChange' =>
        hostApi._onPaymentStatusChange(PaymentStatus.values[args[0] as int]),
      '_onReaderReportEvent' => hostApi._onReaderReportEvent(ReaderEvent.values[args[0] as int]),
      '_onReaderReconnectFailed' =>
        hostApi._onReaderReconnectFailed(_$deserializeReader(args[0] as List)),
      '_onReaderReconnectStarted' => hostApi._onReaderReconnectStarted(
          _$deserializeReader(args[0] as List), DisconnectReason.values[args[1] as int]),
      '_onReaderReconnectSucceeded' =>
        hostApi._onReaderReconnectSucceeded(_$deserializeReader(args[0] as List)),
      '_onDisconnect' => hostApi._onDisconnect(DisconnectReason.values[args[0] as int]),
      '_onReaderStartInstallingUpdate' =>
        hostApi._onReaderStartInstallingUpdate(_$deserializeReaderSoftwareUpdate(args[0] as List)),
      '_onReaderReportSoftwareUpdateProgress' =>
        hostApi._onReaderReportSoftwareUpdateProgress(args[0] as double),
      '_onReaderFinishInstallingUpdate' => hostApi._onReaderFinishInstallingUpdate(
          args[0] != null ? _$deserializeReaderSoftwareUpdate(args[0] as List) : null,
          args[1] != null ? _$deserializeTerminalException(args[1] as List) : null),
      '_onReaderRequestDisplayMessage' =>
        hostApi._onReaderRequestDisplayMessage(ReaderDisplayMessage.values[args[0] as int]),
      '_onReaderRequestInput' => hostApi._onReaderRequestInput(
          (args[0] as List).map((e) => ReaderInputOption.values[e as int]).toList()),
      '_onReaderBatteryLevelUpdate' => hostApi._onReaderBatteryLevelUpdate(args[0] as double,
          args[1] != null ? BatteryStatus.values[args[1] as int] : null, args[2] as bool),
      '_onReaderReportLowBatteryWarning' => hostApi._onReaderReportLowBatteryWarning(),
      '_onReaderReportAvailableUpdate' =>
        hostApi._onReaderReportAvailableUpdate(_$deserializeReaderSoftwareUpdate(args[0] as List)),
      '_onReaderAcceptTermsOfService' => hostApi._onReaderAcceptTermsOfService(),
      _ => throw UnsupportedError('TerminalHandlers#Flutter.${call.method} method'),
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
AmountDetails _$deserializeAmountDetails(List<Object?> serialized) =>
    AmountDetails(tip: serialized[0] != null ? _$deserializeTip(serialized[0] as List) : null);
CardDetails _$deserializeCardDetails(List<Object?> serialized) => CardDetails(
    brand: serialized[0] != null ? CardBrand.values[serialized[0] as int] : null,
    country: serialized[1] as String?,
    expMonth: serialized[2] as int,
    expYear: serialized[3] as int,
    funding: serialized[4] != null ? CardFundingType.values[serialized[4] as int] : null,
    last4: serialized[5] as String?);
CardNetworks _$deserializeCardNetworks(List<Object?> serialized) => CardNetworks(
    available: (serialized[0] as List).map((e) => CardBrand.values[e as int]).toList(),
    preferred: serialized[1] as String?);
CardPresentDetails _$deserializeCardPresentDetails(List<Object?> serialized) => CardPresentDetails(
    brand: serialized[0] != null ? CardBrand.values[serialized[0] as int] : null,
    cardholderName: serialized[1] as String?,
    country: serialized[2] as String?,
    emvAuthData: serialized[3] as String?,
    expMonth: serialized[4] as int,
    expYear: serialized[5] as int,
    funding: serialized[6] != null ? CardFundingType.values[serialized[6] as int] : null,
    generatedCard: serialized[7] as String?,
    incrementalAuthorizationStatus:
        serialized[8] != null ? IncrementalAuthorizationStatus.values[serialized[8] as int] : null,
    last4: serialized[9] as String?,
    networks: serialized[10] != null ? _$deserializeCardNetworks(serialized[10] as List) : null,
    receipt: serialized[11] != null ? _$deserializeReceiptDetails(serialized[11] as List) : null);
List<Object?> _$serializeCardPresentParameters(CardPresentParameters deserialized) => [
      deserialized.captureMethod?.index,
      deserialized.requestExtendedAuthorization,
      deserialized.requestIncrementalAuthorizationSupport,
      deserialized.requestedPriority?.index
    ];
List<Object?> _$serializeCart(Cart deserialized) => [
      deserialized.currency,
      deserialized.lineItems.map((e) => _$serializeCartLineItem(e)).toList(),
      deserialized.tax,
      deserialized.total
    ];
List<Object?> _$serializeCartLineItem(CartLineItem deserialized) =>
    [deserialized.amount, deserialized.description, deserialized.quantity];
Charge _$deserializeCharge(List<Object?> serialized) => Charge(
    amount: serialized[0] as int,
    authorizationCode: serialized[1] as String?,
    calculatedStatementDescriptor: serialized[2] as String?,
    currency: serialized[3] as String,
    description: serialized[4] as String?,
    id: serialized[5] as String,
    metadata: (serialized[6] as Map).map((k, v) => MapEntry(k as String, v as String)),
    paymentMethodDetails:
        serialized[7] != null ? _$deserializePaymentMethodDetails(serialized[7] as List) : null,
    statementDescriptorSuffix: serialized[8] as String?,
    status: ChargeStatus.values[serialized[9] as int]);
List<Object?> _$serializeConnectionConfiguration(ConnectionConfiguration deserialized) =>
    switch (deserialized) {
      BluetoothConnectionConfiguration() =>
        _$serializeBluetoothConnectionConfiguration(deserialized),
      HandoffConnectionConfiguration() => _$serializeHandoffConnectionConfiguration(deserialized),
      InternetConnectionConfiguration() => _$serializeInternetConnectionConfiguration(deserialized),
      TapToPayConnectionConfiguration() => _$serializeTapToPayConnectionConfiguration(deserialized),
      UsbConnectionConfiguration() => _$serializeUsbConnectionConfiguration(deserialized),
    };
List<Object?> _$serializeBluetoothConnectionConfiguration(
        BluetoothConnectionConfiguration deserialized) =>
    [
      'BluetoothConnectionConfiguration',
      deserialized.autoReconnectOnUnexpectedDisconnect,
      deserialized.locationId
    ];
List<Object?> _$serializeHandoffConnectionConfiguration(
        HandoffConnectionConfiguration deserialized) =>
    ['HandoffConnectionConfiguration'];
List<Object?> _$serializeInternetConnectionConfiguration(
        InternetConnectionConfiguration deserialized) =>
    ['InternetConnectionConfiguration', deserialized.failIfInUse];
List<Object?> _$serializeTapToPayConnectionConfiguration(
        TapToPayConnectionConfiguration deserialized) =>
    [
      'TapToPayConnectionConfiguration',
      deserialized.autoReconnectOnUnexpectedDisconnect,
      deserialized.locationId,
      deserialized.tosAcceptancePermitted
    ];
List<Object?> _$serializeUsbConnectionConfiguration(UsbConnectionConfiguration deserialized) => [
      'UsbConnectionConfiguration',
      deserialized.autoReconnectOnUnexpectedDisconnect,
      deserialized.locationId
    ];
List<Object?> _$serializeDiscoveryConfiguration(DiscoveryConfiguration deserialized) =>
    switch (deserialized) {
      BluetoothDiscoveryConfiguration() => _$serializeBluetoothDiscoveryConfiguration(deserialized),
      BluetoothProximityDiscoveryConfiguration() =>
        _$serializeBluetoothProximityDiscoveryConfiguration(deserialized),
      HandoffDiscoveryConfiguration() => _$serializeHandoffDiscoveryConfiguration(deserialized),
      InternetDiscoveryConfiguration() => _$serializeInternetDiscoveryConfiguration(deserialized),
      TapToPayDiscoveryConfiguration() => _$serializeTapToPayDiscoveryConfiguration(deserialized),
      UsbDiscoveryConfiguration() => _$serializeUsbDiscoveryConfiguration(deserialized),
    };
List<Object?> _$serializeBluetoothDiscoveryConfiguration(
        BluetoothDiscoveryConfiguration deserialized) =>
    [
      'BluetoothDiscoveryConfiguration',
      deserialized.isSimulated,
      deserialized.timeout?.inMicroseconds
    ];
List<Object?> _$serializeBluetoothProximityDiscoveryConfiguration(
        BluetoothProximityDiscoveryConfiguration deserialized) =>
    ['BluetoothProximityDiscoveryConfiguration', deserialized.isSimulated];
List<Object?> _$serializeHandoffDiscoveryConfiguration(
        HandoffDiscoveryConfiguration deserialized) =>
    ['HandoffDiscoveryConfiguration'];
List<Object?> _$serializeInternetDiscoveryConfiguration(
        InternetDiscoveryConfiguration deserialized) =>
    [
      'InternetDiscoveryConfiguration',
      deserialized.isSimulated,
      deserialized.locationId,
      deserialized.timeout?.inMicroseconds
    ];
List<Object?> _$serializeTapToPayDiscoveryConfiguration(
        TapToPayDiscoveryConfiguration deserialized) =>
    ['TapToPayDiscoveryConfiguration', deserialized.isSimulated];
List<Object?> _$serializeUsbDiscoveryConfiguration(UsbDiscoveryConfiguration deserialized) =>
    ['UsbDiscoveryConfiguration', deserialized.isSimulated, deserialized.timeout?.inMicroseconds];
Location _$deserializeLocation(List<Object?> serialized) => Location(
    address: serialized[0] != null ? _$deserializeAddress(serialized[0] as List) : null,
    displayName: serialized[1] as String?,
    id: serialized[2] as String?,
    livemode: serialized[3] as bool?,
    metadata: (serialized[4] as Map).map((k, v) => MapEntry(k as String, v as String)));
PaymentIntent _$deserializePaymentIntent(List<Object?> serialized) => PaymentIntent(
    amount: serialized[0] as double,
    amountCapturable: serialized[1] as double?,
    amountDetails: serialized[2] != null ? _$deserializeAmountDetails(serialized[2] as List) : null,
    amountReceived: serialized[3] as double?,
    amountTip: serialized[4] as double?,
    applicationFeeAmount: serialized[5] as double?,
    applicationId: serialized[6] as String?,
    canceledAt:
        serialized[7] != null ? DateTime.fromMillisecondsSinceEpoch(serialized[7] as int) : null,
    cancellationReason: serialized[8] as String?,
    captureMethod: CaptureMethod.values[serialized[9] as int],
    charges: (serialized[10] as List).map((e) => _$deserializeCharge(e as List)).toList(),
    clientSecret: serialized[11] as String?,
    confirmationMethod:
        serialized[12] != null ? ConfirmationMethod.values[serialized[12] as int] : null,
    created: DateTime.fromMillisecondsSinceEpoch(serialized[13] as int),
    currency: serialized[14] as String,
    customerId: serialized[15] as String?,
    description: serialized[16] as String?,
    id: serialized[17] as String,
    invoiceId: serialized[18] as String?,
    metadata: (serialized[19] as Map).map((k, v) => MapEntry(k as String, v as String)),
    onBehalfOf: serialized[20] as String?,
    paymentMethod:
        serialized[21] != null ? _$deserializePaymentMethod(serialized[21] as List) : null,
    paymentMethodId: serialized[22] as String?,
    receiptEmail: serialized[23] as String?,
    reviewId: serialized[24] as String?,
    setupFutureUsage:
        serialized[25] != null ? PaymentIntentUsage.values[serialized[25] as int] : null,
    statementDescriptor: serialized[26] as String?,
    statementDescriptorSuffix: serialized[27] as String?,
    status: PaymentIntentStatus.values[serialized[28] as int],
    transferGroup: serialized[29] as String?);
List<Object?> _$serializePaymentIntentParameters(PaymentIntentParameters deserialized) => [
      deserialized.amount,
      deserialized.applicationFeeAmount,
      deserialized.captureMethod.index,
      deserialized.currency,
      deserialized.customerId,
      deserialized.description,
      deserialized.metadata.map((k, v) => MapEntry(k, v)),
      deserialized.onBehalfOf,
      deserialized.paymentMethodOptionsParameters != null
          ? _$serializePaymentMethodOptionsParameters(deserialized.paymentMethodOptionsParameters!)
          : null,
      deserialized.paymentMethodTypes.map((e) => e.index).toList(),
      deserialized.receiptEmail,
      deserialized.setupFutureUsage?.index,
      deserialized.statementDescriptor,
      deserialized.statementDescriptorSuffix,
      deserialized.transferDataDestination,
      deserialized.transferGroup
    ];
PaymentMethod _$deserializePaymentMethod(List<Object?> serialized) => PaymentMethod(
    card: serialized[0] != null ? _$deserializeCardDetails(serialized[0] as List) : null,
    cardPresent:
        serialized[1] != null ? _$deserializeCardPresentDetails(serialized[1] as List) : null,
    customerId: serialized[2] as String?,
    id: serialized[3] as String,
    interacPresent:
        serialized[4] != null ? _$deserializeCardPresentDetails(serialized[4] as List) : null,
    metadata: (serialized[5] as Map).map((k, v) => MapEntry(k as String, v as String)));
PaymentMethodDetails _$deserializePaymentMethodDetails(List<Object?> serialized) =>
    PaymentMethodDetails(
        cardPresent:
            serialized[0] != null ? _$deserializeCardPresentDetails(serialized[0] as List) : null,
        interacPresent:
            serialized[1] != null ? _$deserializeCardPresentDetails(serialized[1] as List) : null);
List<Object?> _$serializePaymentMethodOptionsParameters(
        PaymentMethodOptionsParameters deserialized) =>
    [_$serializeCardPresentParameters(deserialized.cardPresentParameters)];
Reader _$deserializeReader(List<Object?> serialized) => Reader(
    availableUpdate: serialized[0] as bool,
    batteryLevel: serialized[1] as double,
    deviceType: serialized[2] != null ? DeviceType.values[serialized[2] as int] : null,
    label: serialized[3] as String?,
    location: serialized[4] != null ? _$deserializeLocation(serialized[4] as List) : null,
    locationId: serialized[5] as String?,
    locationStatus: serialized[6] != null ? LocationStatus.values[serialized[6] as int] : null,
    serialNumber: serialized[7] as String,
    simulated: serialized[8] as bool);
List<Object?> _$serializeReaderDelegateAbstract(ReaderDelegateAbstract deserialized) =>
    switch (deserialized) {
      MobileReaderDelegate() => _$serializeMobileReaderDelegate(deserialized),
      HandoffReaderDelegate() => _$serializeHandoffReaderDelegate(deserialized),
      InternetReaderDelegate() => _$serializeInternetReaderDelegate(deserialized),
      TapToPayReaderDelegate() => _$serializeTapToPayReaderDelegate(deserialized),
    };
List<Object?> _$serializeMobileReaderDelegate(MobileReaderDelegate deserialized) =>
    ['MobileReaderDelegate'];
List<Object?> _$serializeHandoffReaderDelegate(HandoffReaderDelegate deserialized) =>
    ['HandoffReaderDelegate'];
List<Object?> _$serializeInternetReaderDelegate(InternetReaderDelegate deserialized) =>
    ['InternetReaderDelegate'];
List<Object?> _$serializeTapToPayReaderDelegate(TapToPayReaderDelegate deserialized) =>
    ['TapToPayReaderDelegate'];
ReaderSoftwareUpdate _$deserializeReaderSoftwareUpdate(List<Object?> serialized) =>
    ReaderSoftwareUpdate(
        components: (serialized[0] as List).map((e) => UpdateComponent.values[e as int]).toList(),
        keyProfileName: serialized[1] as String?,
        onlyInstallRequiredUpdates: serialized[2] as bool,
        requiredAt: DateTime.fromMillisecondsSinceEpoch(serialized[3] as int),
        settingsVersion: serialized[4] as String?,
        timeEstimate: UpdateTimeEstimate.values[serialized[5] as int],
        version: serialized[6] as String);
ReceiptDetails _$deserializeReceiptDetails(List<Object?> serialized) => ReceiptDetails(
    accountType: serialized[0] as String?,
    applicationCryptogram: serialized[1] as String?,
    applicationPreferredName: serialized[2] as String?,
    authorizationCode: serialized[3] as String?,
    authorizationResponseCode: serialized[4] as String,
    dedicatedFileName: serialized[5] as String?,
    terminalVerificationResults: serialized[6] as String?,
    transactionStatusInformation: serialized[7] as String?);
Refund _$deserializeRefund(List<Object?> serialized) => Refund(
    amount: serialized[0] as int,
    chargeId: serialized[1] as String,
    created: DateTime.fromMillisecondsSinceEpoch(serialized[2] as int),
    currency: serialized[3] as String,
    failureReason: serialized[4] as String?,
    id: serialized[5] as String,
    metadata: (serialized[6] as Map).map((k, v) => MapEntry(k as String, v as String)),
    paymentMethodDetails:
        serialized[7] != null ? _$deserializePaymentMethodDetails(serialized[7] as List) : null,
    reason: serialized[8] as String?,
    status: serialized[9] != null ? RefundStatus.values[serialized[9] as int] : null);
SetupAttempt _$deserializeSetupAttempt(List<Object?> serialized) => SetupAttempt(
    applicationId: serialized[0] as String?,
    created: DateTime.fromMillisecondsSinceEpoch(serialized[1] as int),
    customerId: serialized[2] as String?,
    id: serialized[3] as String,
    onBehalfOf: serialized[4] as String?,
    paymentMethodDetails: serialized[5] != null
        ? _$deserializeSetupAttemptPaymentMethodDetails(serialized[5] as List)
        : null,
    paymentMethodId: serialized[6] as String?,
    setupIntentId: serialized[7] as String,
    status: SetupAttemptStatus.values[serialized[8] as int]);
SetupAttemptCardPresentDetails _$deserializeSetupAttemptCardPresentDetails(
        List<Object?> serialized) =>
    SetupAttemptCardPresentDetails(
        emvAuthData: serialized[0] as String, generatedCard: serialized[1] as String);
SetupAttemptPaymentMethodDetails _$deserializeSetupAttemptPaymentMethodDetails(
        List<Object?> serialized) =>
    SetupAttemptPaymentMethodDetails(
        cardPresent: serialized[0] != null
            ? _$deserializeSetupAttemptCardPresentDetails(serialized[0] as List)
            : null,
        interacPresent: serialized[1] != null
            ? _$deserializeSetupAttemptCardPresentDetails(serialized[1] as List)
            : null);
SetupIntent _$deserializeSetupIntent(List<Object?> serialized) => SetupIntent(
    created: DateTime.fromMillisecondsSinceEpoch(serialized[0] as int),
    customerId: serialized[1] as String?,
    id: serialized[2] as String,
    latestAttempt: serialized[3] != null ? _$deserializeSetupAttempt(serialized[3] as List) : null,
    metadata: (serialized[4] as Map).map((k, v) => MapEntry(k as String, v as String)),
    status: SetupIntentStatus.values[serialized[5] as int],
    usage: SetupIntentUsage.values[serialized[6] as int]);
List<Object?> _$serializeSimulatedCard(SimulatedCard deserialized) =>
    [deserialized.testCardNumber, deserialized.type?.index];
List<Object?> _$serializeSimulatorConfiguration(SimulatorConfiguration deserialized) => [
      _$serializeSimulatedCard(deserialized.simulatedCard),
      deserialized.simulatedTipAmount,
      deserialized.update.index
    ];
List<Object?> _$serializeTapToPayUxConfiguration(TapToPayUxConfiguration deserialized) => [
      deserialized.colors != null
          ? _$serializeTapToPayUxConfigurationColorScheme(deserialized.colors!)
          : null,
      deserialized.darkMode?.index,
      deserialized.tapZone != null
          ? _$serializeTapToPayUxConfigurationTapZone(deserialized.tapZone!)
          : null
    ];
List<Object?> _$serializeTapToPayUxConfigurationColorScheme(
        TapToPayUxConfigurationColorScheme deserialized) =>
    [deserialized.error, deserialized.primary, deserialized.success];
List<Object?> _$serializeTapToPayUxConfigurationTapZone(
        TapToPayUxConfigurationTapZone deserialized) =>
    [
      deserialized.indicator?.index,
      deserialized.position != null
          ? _$serializeTapToPayUxConfigurationTapZonePosition(deserialized.position!)
          : null
    ];
List<Object?> _$serializeTapToPayUxConfigurationTapZonePosition(
        TapToPayUxConfigurationTapZonePosition deserialized) =>
    [deserialized.xBias, deserialized.yBias];
TerminalException _$deserializeTerminalException(List<Object?> serialized) => TerminalException(
    apiError: serialized[0],
    code: TerminalExceptionCode.values[serialized[1] as int],
    message: serialized[2] as String,
    paymentIntent: serialized[3] != null ? _$deserializePaymentIntent(serialized[3] as List) : null,
    stackTrace: serialized[4] as String?);
Tip _$deserializeTip(List<Object?> serialized) => Tip(amount: serialized[0] as int?);
List<Object?> _$serializeTippingConfiguration(TippingConfiguration deserialized) =>
    [deserialized.eligibleAmount];

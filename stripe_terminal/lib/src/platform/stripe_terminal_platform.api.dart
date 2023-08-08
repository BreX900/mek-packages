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

  Future<void> init({required bool shouldPrintLogs}) async {
    try {
      await _$channel.invokeMethod('init', [shouldPrintLogs]);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> clearCachedCredentials() async {
    try {
      await _$channel.invokeMethod('clearCachedCredentials', []);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<ConnectionStatus> getConnectionStatus() async {
    try {
      final result = await _$channel.invokeMethod('getConnectionStatus', []);
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

  Future<Reader?> getConnectedReader() async {
    try {
      final result = await _$channel.invokeMethod('getConnectedReader', []);
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

  Future<PaymentStatus> getPaymentStatus() async {
    try {
      final result = await _$channel.invokeMethod('getPaymentStatus', []);
      return PaymentStatus.values[result as int];
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<PaymentIntent> createPaymentIntent(
      PaymentIntentParameters parameters) async {
    try {
      final result = await _$channel.invokeMethod('createPaymentIntent',
          [_$serializePaymentIntentParameters(parameters)]);
      return _$deserializePaymentIntent(result as List);
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

  Future<PaymentIntent> cancelPaymentIntent(String paymentIntentId) async {
    try {
      final result = await _$channel
          .invokeMethod('cancelPaymentIntent', [paymentIntentId]);
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
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<SetupIntent> retrieveSetupIntent(String clientSecret) async {
    try {
      final result =
          await _$channel.invokeMethod('retrieveSetupIntent', [clientSecret]);
      return _$deserializeSetupIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<SetupIntent> startCollectSetupIntentPaymentMethod({
    required int operationId,
    required String setupIntentId,
    required bool customerConsentCollected,
  }) async {
    try {
      final result = await _$channel.invokeMethod(
          'startCollectSetupIntentPaymentMethod',
          [operationId, setupIntentId, customerConsentCollected]);
      return _$deserializeSetupIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> stopCollectSetupIntentPaymentMethod(int operationId) async {
    try {
      await _$channel
          .invokeMethod('stopCollectSetupIntentPaymentMethod', [operationId]);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<SetupIntent> confirmSetupIntent(String setupIntentId) async {
    try {
      final result =
          await _$channel.invokeMethod('confirmSetupIntent', [setupIntentId]);
      return _$deserializeSetupIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<SetupIntent> cancelSetupIntent(String setupIntentId) async {
    try {
      final result =
          await _$channel.invokeMethod('cancelSetupIntent', [setupIntentId]);
      return _$deserializeSetupIntent(result as List);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> startCollectRefundPaymentMethod({
    required int operationId,
    required String chargeId,
    required int amount,
    required String currency,
    required Map<String, String>? metadata,
    required bool? reverseTransfer,
    required bool? refundApplicationFee,
  }) async {
    try {
      await _$channel.invokeMethod('startCollectRefundPaymentMethod', [
        operationId,
        chargeId,
        amount,
        currency,
        metadata?.map((k, v) => MapEntry(k, v)),
        reverseTransfer,
        refundApplicationFee
      ]);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<void> stopCollectRefundPaymentMethod(int operationId) async {
    try {
      await _$channel
          .invokeMethod('stopCollectRefundPaymentMethod', [operationId]);
    } on PlatformException catch (exception) {
      StripeTerminalPlatform._throwIfIsHostException(exception);
      rethrow;
    }
  }

  Future<Refund> processRefund() async {
    try {
      final result = await _$channel.invokeMethod('processRefund', []);
      return _$deserializeRefund(result as List);
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
CardNetworks _$deserializeCardNetworks(List<Object?> serialized) =>
    CardNetworks(
        available: (serialized[0] as List)
            .map((e) => CardBrand.values[e as int])
            .toList(),
        preferred: serialized[1] as String?);
CardPresentDetails _$deserializeCardPresentDetails(List<Object?> serialized) =>
    CardPresentDetails(
        brand: serialized[0] != null
            ? CardBrand.values[serialized[0] as int]
            : null,
        country: serialized[1] as String?,
        expMonth: serialized[2] as int,
        expYear: serialized[3] as int,
        fingerprint: serialized[4] as String?,
        funding: serialized[5] != null
            ? CardFundingType.values[serialized[5] as int]
            : null,
        last4: serialized[6] as String?,
        cardholderName: serialized[7] as String?,
        emvAuthData: serialized[8] as String?,
        generatedCard: serialized[9] as String?,
        incrementalAuthorizationStatus: serialized[10] != null
            ? IncrementalAuthorizationStatus.values[serialized[10] as int]
            : null,
        networks: serialized[11] != null
            ? _$deserializeCardNetworks(serialized[11] as List)
            : null,
        receipt: serialized[12] != null
            ? _$deserializeReceiptDetails(serialized[12] as List)
            : null);
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
            created: DateTime.fromMillisecondsSinceEpoch(serialized[1] as int),
            status: PaymentIntentStatus.values[serialized[2] as int],
            amount: serialized[3] as double,
            captureMethod: serialized[4] as String,
            currency: serialized[5] as String,
            metadata: (serialized[6] as Map)
                .map((k, v) => MapEntry(k as String, v as String)),
            paymentMethodId: serialized[7] as String?,
            amountTip: serialized[8] as double?,
            statementDescriptor: serialized[9] as String?,
            statementDescriptorSuffix: serialized[10] as String?,
            amountCapturable: serialized[11] as double?,
            amountReceived: serialized[12] as double?,
            application: serialized[13] as String?,
            applicationFeeAmount: serialized[14] as double?,
            cancellationReason: serialized[15] as String?,
            canceledAt: serialized[16] != null
                ? DateTime.fromMillisecondsSinceEpoch(serialized[16] as int)
                : null,
            clientSecret: serialized[17] as String?,
            confirmationMethod: serialized[18] as String?,
            customer: serialized[19] as String?,
            description: serialized[20] as String?,
            invoice: serialized[21] as String?,
            onBehalfOf: serialized[22] as String?,
            review: serialized[23] as String?,
            receiptEmail: serialized[24] as String?,
            setupFutureUsage: serialized[25] as String?,
            transferGroup: serialized[26] as String?);
List<Object?> _$serializePaymentIntentParameters(
        PaymentIntentParameters deserialized) =>
    [
      deserialized.amount,
      deserialized.currency,
      deserialized.captureMethod.index,
      deserialized.paymentMethodTypes.map((e) => e.index).toList()
    ];
PaymentMethod
    _$deserializePaymentMethod(List<Object?> serialized) =>
        PaymentMethod(
            id: serialized[0] as String,
            card: serialized[1] != null
                ? _$deserializeCardDetails(serialized[1] as List)
                : null,
            cardPresent: serialized[2] != null
                ? _$deserializeCardPresentDetails(serialized[2] as List)
                : null,
            interacPresent: serialized[3] != null
                ? _$deserializeCardPresentDetails(serialized[3] as List)
                : null,
            customer: serialized[4] as String?,
            metadata: (serialized[5] as Map)
                .map((k, v) => MapEntry(k as String, v as String)));
PaymentMethodDetails _$deserializePaymentMethodDetails(
        List<Object?> serialized) =>
    PaymentMethodDetails(
        cardPresent: serialized[0] != null
            ? _$deserializeCardPresentDetails(serialized[0] as List)
            : null,
        interacPresent: serialized[1] != null
            ? _$deserializeCardPresentDetails(serialized[1] as List)
            : null);
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
ReceiptDetails _$deserializeReceiptDetails(List<Object?> serialized) =>
    ReceiptDetails(
        accountType: serialized[0] as String?,
        applicationPreferredName: serialized[1] as String,
        authorizationCode: serialized[2] as String?,
        authorizationResponseCode: serialized[3] as String,
        applicationCryptogram: serialized[4] as String,
        dedicatedFileName: serialized[5] as String,
        transactionStatusInformation: serialized[6] as String,
        terminalVerificationResults: serialized[7] as String);
Refund _$deserializeRefund(List<Object?> serialized) => Refund(
    id: serialized[0] as String,
    amount: serialized[1] as int,
    chargeId: serialized[2] as String,
    created: DateTime.fromMillisecondsSinceEpoch(serialized[3] as int),
    currency: serialized[4] as String,
    metadata: (serialized[5] as Map)
        .map((k, v) => MapEntry(k as String, v as String)),
    reason: serialized[6] as String?,
    status: serialized[7] != null
        ? RefundStatus.values[serialized[7] as int]
        : null,
    paymentMethodDetails: serialized[8] != null
        ? _$deserializePaymentMethodDetails(serialized[8] as List)
        : null,
    failureReason: serialized[9] as String?);
SetupAttempt _$deserializeSetupAttempt(List<Object?> serialized) =>
    SetupAttempt(
        id: serialized[0] as String,
        applicationId: serialized[1] as String?,
        created: DateTime.fromMillisecondsSinceEpoch(serialized[2] as int),
        customerId: serialized[3] as String?,
        onBehalfOfId: serialized[4] as String?,
        paymentMethodId: serialized[5] as String?,
        paymentMethodDetails: serialized[6] != null
            ? _$deserializeSetupAttemptPaymentMethodDetails(
                serialized[6] as List)
            : null,
        setupIntentId: serialized[7] as String,
        status: SetupAttemptStatus.values[serialized[8] as int]);
SetupAttemptCardPresentDetails _$deserializeSetupAttemptCardPresentDetails(
        List<Object?> serialized) =>
    SetupAttemptCardPresentDetails(
        emvAuthData: serialized[0] as String,
        generatedCard: serialized[1] as String);
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
    id: serialized[0] as String,
    created: DateTime.fromMillisecondsSinceEpoch(serialized[1] as int),
    customerId: serialized[2] as String?,
    metadata: (serialized[3] as Map)
        .map((k, v) => MapEntry(k as String, v as String)),
    usage: SetupIntentUsage.values[serialized[4] as int],
    status: SetupIntentStatus.values[serialized[5] as int],
    latestAttempt: serialized[6] != null
        ? _$deserializeSetupAttempt(serialized[6] as List)
        : null);
TerminalException _$deserializeTerminalException(List<Object?> serialized) =>
    TerminalException(
        rawCode: serialized[0] as String,
        message: serialized[1] as String?,
        details: serialized[2] as String?);

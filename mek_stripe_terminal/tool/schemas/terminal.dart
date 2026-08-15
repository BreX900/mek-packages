import 'package:pigeon/pigeon.dart';

import 'models/cart.dart';
import 'models/clear_cached_credentials_result.dart';
import 'models/connection_configuration.dart';
import 'models/disconnect_reason.dart';
import 'models/discovery_configuration.dart';
import 'models/easy_connect_configuration.dart';
import 'models/location.dart';
import 'models/payment_intent.dart';
import 'models/reader.dart';
import 'models/reader_software_update.dart';
import 'models/refund.dart';
import 'models/setup_intent.dart';
import 'models/simulator_configuration.dart';
import 'models/tap_to_pay_ux_configuration.dart';
import 'models/tip.dart';
import 'terminal_exception.dart';

@HostApi()
abstract class TerminalPlatformApi {
  void initialize({required bool shouldPrintLogs});

  ClearCachedCredentialsResultApi clearCachedCredentials();

  //region Reader discovery, connection and updates

  ConnectionStatusApi getConnectionStatus();

  bool supportsReadersOfType({
    required DeviceTypeApi? deviceType,
    required DiscoveryConfigurationApi discoveryConfiguration,
  });

  void applyDiscoverReadersParameters(DiscoveryConfigurationApi configuration);

  @async
  ReaderApi connectReader(String serialNumber, ConnectionConfigurationApi configuration);

  @async
  ReaderApi startEasyConnect({
    required int operationId,
    required EasyConnectConfigurationApi configuration,
  });

  @async
  void stopEasyConnect(int operationId);

  ReaderApi? getConnectedReader();

  @async
  void cancelReaderReconnection();

  @async
  List<LocationApi> listLocations({
    required String? endingBefore,
    required int? limit,
    required String? startingAfter,
  });

  void installAvailableUpdate();

  @async
  void cancelReaderUpdate();

  @async
  void rebootReader();

  @async
  void disconnectReader();

  void setSimulatorConfiguration(SimulatorConfigurationApi configuration);
  //endregion

  //region Taking payments
  PaymentStatusApi getPaymentStatus();

  @async
  PaymentIntentApi createPaymentIntent(PaymentIntentParametersApi parameters);

  @async
  PaymentIntentApi retrievePaymentIntent(String clientSecret);

  @async
  PaymentIntentApi startProcessPaymentIntent({
    required int operationId,
    required String paymentIntentId,
    required bool requestDynamicCurrencyConversion,
    required String? surchargeNotice,
    required bool skipTipping,
    required TippingConfigurationApi? tippingConfiguration,
    required bool shouldUpdatePaymentIntent,
    required bool customerCancellationEnabled,
    required AllowRedisplayApi allowRedisplay,
    required ConfirmPaymentIntentConfigurationApi? confirmConfiguration,
  });

  @async
  void stopProcessPaymentIntent(int operationId);

  @async
  PaymentIntentApi cancelPaymentIntent(String paymentIntentId);
  //endregion

  //region Saving payment details for later use
  @async
  SetupIntentApi createSetupIntent({
    required String? customerId,
    required Map<String, String>? metadata,
    required String? onBehalfOf,
    required String? description,
    required SetupIntentUsageApi? usage,
  });

  @async
  SetupIntentApi retrieveSetupIntent(String clientSecret);

  @async
  SetupIntentApi startProcessSetupIntent({
    required int operationId,
    required String setupIntentId,
    required AllowRedisplayApi allowRedisplay,
    required bool customerCancellationEnabled,
  });

  @async
  void stopProcessSetupIntent(int operationId);

  @async
  SetupIntentApi cancelSetupIntent(String setupIntentId);
  //endregion

  //region Card-present refunds
  @async
  RefundApi startProcessRefund({
    required int operationId,
    required String? chargeId,
    required String? paymentIntentId,
    required String? paymentIntentClientSecret,
    required int amount,
    required String currency,
    required Map<String, String>? metadata,
    required bool? reverseTransfer,
    required bool? refundApplicationFee,
    required bool customerCancellationEnabled,
  });

  @async
  void stopProcessRefund(int operationId);
  //endregion

  //region Display information to customers
  @async
  void setReaderDisplay(CartApi cart);

  @async
  void clearReaderDisplay();

  void setTapToPayUXConfiguration(TapToPayUxConfigurationApi configuration);

  @async
  bool isTapToPayAccountLinked({required String? onBehalfOf});
  //endregion
}

@EventChannelApi()
abstract class TerminalEventsApi {
  List<ReaderApi> discoverReaders();
}

@FlutterApi()
abstract class TerminalHandlersApi {
  @async
  String requestConnectionToken();

  void connectionStatusChange(ConnectionStatusApi status);

  void paymentStatusChange(PaymentStatusApi status);

  void readerReportEvent(ReaderEventApi event);

  void readerReconnectStarted(ReaderApi reader, DisconnectReasonApi reason);

  void readerReconnectFailed(ReaderApi reader);

  void readerReconnectSucceeded(ReaderApi reader);

  void readerRequestDisplayMessage(ReaderDisplayMessageApi message);

  void readerRequestInput(List<ReaderInputOptionApi> options);

  void readerBatteryLevelUpdate(
    double batteryLevel,
    BatteryStatusApi? batteryStatus,
    bool isCharging,
  );

  void readerReportLowBatteryWarning();

  void readerReportAvailableUpdate(ReaderSoftwareUpdateApi update);

  void disconnect(DisconnectReasonApi reason);

  void readerStartInstallingUpdate(ReaderSoftwareUpdateApi update);

  void readerReportSoftwareUpdateProgress(double progress);

  void readerFinishInstallingUpdate(
    ReaderSoftwareUpdateApi? update,
    TerminalExceptionApi? exception,
  );

  void readerAcceptTermsOfService();
}

enum PaymentStatusApi { notReady, ready, waitingForInput, processing }

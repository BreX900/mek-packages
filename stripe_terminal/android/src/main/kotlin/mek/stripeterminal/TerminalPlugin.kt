package mek.stripeterminal

import android.content.Context
import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.TerminalApplicationDelegate
import com.stripe.stripeterminal.external.callable.Callback
import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.LocationListCallback
import com.stripe.stripeterminal.external.callable.PaymentIntentCallback
import com.stripe.stripeterminal.external.callable.ReaderCallback
import com.stripe.stripeterminal.external.callable.RefundCallback
import com.stripe.stripeterminal.external.callable.SetupIntentCallback
import com.stripe.stripeterminal.external.models.CollectPaymentIntentConfiguration
import com.stripe.stripeterminal.external.models.CollectRefundConfiguration
import com.stripe.stripeterminal.external.models.CollectSetupIntentConfiguration
import com.stripe.stripeterminal.external.models.ConfirmPaymentIntentConfiguration
import com.stripe.stripeterminal.external.models.CustomerCancellation
import com.stripe.stripeterminal.external.models.DeviceType
import com.stripe.stripeterminal.external.models.ListLocationsParameters
import com.stripe.stripeterminal.external.models.Location
import com.stripe.stripeterminal.external.models.PaymentIntent
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.Refund
import com.stripe.stripeterminal.external.models.RefundParameters
import com.stripe.stripeterminal.external.models.SetupIntent
import com.stripe.stripeterminal.external.models.SetupIntentCancellationParameters
import com.stripe.stripeterminal.external.models.SetupIntentParameters
import com.stripe.stripeterminal.external.models.TerminalException
import com.stripe.stripeterminal.log.LogLevel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import mek.stripeterminal.api.AllowRedisplayApi
import mek.stripeterminal.api.CartApi
import mek.stripeterminal.api.ClearCachedCredentialsResultApi
import mek.stripeterminal.api.ConfirmPaymentIntentConfigurationApi
import mek.stripeterminal.api.ConnectionConfigurationApi
import mek.stripeterminal.api.ConnectionStatusApi
import mek.stripeterminal.api.DeviceTypeApi
import mek.stripeterminal.api.DiscoverReadersControllerApi
import mek.stripeterminal.api.DiscoveryConfigurationApi
import mek.stripeterminal.api.EasyConnectConfigurationApi
import mek.stripeterminal.api.LocationApi
import mek.stripeterminal.api.PaymentIntentApi
import mek.stripeterminal.api.PaymentIntentParametersApi
import mek.stripeterminal.api.PaymentStatusApi
import mek.stripeterminal.api.ReaderApi
import mek.stripeterminal.api.RefundApi
import mek.stripeterminal.api.Result
import mek.stripeterminal.api.SetupIntentApi
import mek.stripeterminal.api.SetupIntentUsageApi
import mek.stripeterminal.api.SimulatorConfigurationApi
import mek.stripeterminal.api.TapToPayUxConfigurationApi
import mek.stripeterminal.api.TerminalExceptionCodeApi
import mek.stripeterminal.api.TerminalHandlersApi
import mek.stripeterminal.api.TerminalPlatformApi
import mek.stripeterminal.api.TippingConfigurationApi
import mek.stripeterminal.mappings.toApi
import mek.stripeterminal.mappings.toHost
import mek.stripeterminal.mappings.toPlatformError
import mek.stripeterminal.plugin.DiscoverReadersSubject
import mek.stripeterminal.plugin.ReaderDelegatePlugin
import mek.stripeterminal.plugin.TerminalDelegatePlugin
import mek.stripeterminal.plugin.TerminalErrorHandler

class TerminalPlugin : FlutterPlugin, ActivityAware {
    companion object {
        var context: Context? = null
    }

    private lateinit var platform: TerminalPlatformPlugin
    private lateinit var discoverReadersController: DiscoverReadersControllerApi

    companion object {
        private var handlerOwner: TerminalPlugin? = null
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        val discoverReadersSubject = DiscoverReadersSubject()
        discoverReadersController = DiscoverReadersControllerApi(binding.binaryMessenger);
        discoverReadersController.setHandler(
            discoverReadersSubject::onListen,
            discoverReadersSubject::onCancel
        )
        platform = TerminalPlatformPlugin(
            applicationContext = binding.applicationContext,
            handlers = TerminalHandlersApi(binding.binaryMessenger),
            discoverReadersSubject = discoverReadersSubject,
        )
        TerminalPlatformApi.setHandler(binding.binaryMessenger, platform)
        handlerOwner = this
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = null
        if (Terminal.isInitialized()) platform.clean()
        discoverReadersController.removeHandler()
        if (handlerOwner === this) {
            TerminalPlatformApi.removeHandler()
            handlerOwner = null
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        TerminalApplicationDelegate.onCreate(binding.activity.application)
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}
}


class TerminalPlatformPlugin(
    private val applicationContext: Context,
    private val handlers: TerminalHandlersApi,
    private val discoverReadersSubject: DiscoverReadersSubject,
) : TerminalPlatformApi {

    private val terminal: Terminal get() = Terminal.getInstance()

    override fun onInit(shouldPrintLogs: Boolean) {
        // If a hot restart is performed in flutter the terminal is already initialized but we need to
        // clean it up
        if (Terminal.isInitialized()) {
            clean()
            return
        }

        val delegate = TerminalDelegatePlugin(handlers)
        Terminal.init(
            applicationContext,
            if (shouldPrintLogs) LogLevel.VERBOSE else LogLevel.NONE,
            delegate,
            delegate,
            null
        )
    }

    override fun onClearCachedCredentials(): ClearCachedCredentialsResultApi {
        val result = terminal.clearCachedCredentials()
        if (result.isSuccessful) {
            clean()
        }
        return ClearCachedCredentialsResultApi(
            isSuccessful = result.isSuccessful,
            error = result.error?.toApi(),
        )
    }

    // region Reader discovery, connection and updates
    private val discoveredReaders: List<Reader>
        get() = discoverReadersSubject.readers

    private val readerDelegate: ReaderDelegatePlugin = ReaderDelegatePlugin(handlers)

    override fun onGetConnectionStatus(): ConnectionStatusApi = terminal.connectionStatus.toApi()

    override fun onSupportsReadersOfType(
        deviceType: DeviceTypeApi?,
        discoveryConfiguration: DiscoveryConfigurationApi
    ): Boolean {
        val hostDeviceType =
            (if (deviceType != null) deviceType.toHost() else DeviceType.UNKNOWN) ?: return false
        val hostDiscoveryConfiguration = discoveryConfiguration.toHost() ?: return false
        val result =
            terminal.supportsReadersOfType(
                deviceType = hostDeviceType,
                discoveryConfiguration = hostDiscoveryConfiguration
            )
        return result.isSupported
    }

    override fun onConnectReader(result: Result<ReaderApi>, serialNumber: String, configuration: ConnectionConfigurationApi) {
        val reader = findActiveReader(serialNumber)

        terminal.connectReader(
            reader,
            configuration.toHost(readerDelegate),
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            }
        )
    }

    override fun onStartEasyConnect(
        result: Result<ReaderApi>,
        operationId: Long,
        configuration: EasyConnectConfigurationApi
    ) {
        try {
            val hostConfiguration = configuration.toHost(readerDelegate)
            easyConnectCancelables[operationId] = terminal.easyConnect(
                hostConfiguration,
                object : TerminalErrorHandler(result::error), ReaderCallback {
                    override fun onFailure(e: TerminalException) {
                        easyConnectCancelables.remove(operationId)
                        super.onFailure(e)
                    }

                    override fun onSuccess(reader: Reader) {
                        easyConnectCancelables.remove(operationId)
                        result.success(reader.toApi())
                    }
                }
            )
        } catch (e: IllegalArgumentException) {
            result.error(
                createApiError(TerminalExceptionCodeApi.UNKNOWN, e.message ?: "Invalid configuration")
                    .toPlatformError()
            )
        }
    }

    override fun onStopEasyConnect(result: Result<Unit>, operationId: Long) {
        easyConnectCancelables.remove(operationId)?.cancel(
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onGetConnectedReader(): ReaderApi? = terminal.connectedReader?.toApi()

    override fun onCancelReaderReconnection(result: Result<Unit>) {
        readerDelegate.cancelReconnect(
            object : Callback, TerminalErrorHandler(result::error) {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onListLocations(
        result: Result<List<LocationApi>>,
        endingBefore: String?,
        limit: Long?,
        startingAfter: String?
    ) {
        val params = ListLocationsParameters.Builder()
        params.endingBefore = endingBefore
        params.startingAfter = startingAfter
        params.limit = limit?.toInt()
        terminal.listLocations(
            params.build(),
            object : TerminalErrorHandler(result::error), LocationListCallback {
                override fun onSuccess(locations: List<Location>, hasMore: Boolean) =
                    result.success(locations.map { it.toApi() })
            }
        )
    }

    override fun onInstallAvailableUpdate() = terminal.installAvailableUpdate()

    override fun onCancelReaderUpdate(result: Result<Unit>) {
        readerDelegate.cancelUpdate(
            object : Callback, TerminalErrorHandler(result::error) {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onRebootReader(result: Result<Unit>) {
        terminal.rebootReader(
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onDisconnectReader(result: Result<Unit>) {
        terminal.disconnectReader(
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onSetSimulatorConfiguration(configuration: SimulatorConfigurationApi) {
        terminal.simulatorConfiguration = configuration.toHost()
    }
    // endregion

    // region Taking Payment
    private var paymentIntents = HashMap<String, PaymentIntent>()

    override fun onGetPaymentStatus(): PaymentStatusApi = terminal.paymentStatus.toApi()

    override fun onCreatePaymentIntent(
        result: Result<PaymentIntentApi>,
        parameters: PaymentIntentParametersApi
    ) {
        terminal.createPaymentIntent(
            params = parameters.toHost(),
            callback =
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    paymentIntents[paymentIntent.id!!] = paymentIntent
                    result.success(paymentIntent.toApi())
                }
            }
        )
    }

    override fun onRetrievePaymentIntent(result: Result<PaymentIntentApi>, clientSecret: String) {
        terminal.retrievePaymentIntent(
            clientSecret,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    paymentIntents[paymentIntent.id!!] = paymentIntent
                    result.success(paymentIntent.toApi())
                }
            }
        )
    }

    private var processPaymentIntentCancelables = HashMap<Long, Cancelable>()

    private fun buildCollectPaymentIntentConfiguration(
        requestDynamicCurrencyConversion: Boolean,
        surchargeNotice: String?,
        skipTipping: Boolean,
        tippingConfiguration: TippingConfigurationApi?,
        shouldUpdatePaymentIntent: Boolean,
        customerCancellationEnabled: Boolean,
        allowRedisplay: AllowRedisplayApi
    ): CollectPaymentIntentConfiguration {
        val customerCancellation = if (customerCancellationEnabled) {
            CustomerCancellation.ENABLE_IF_AVAILABLE
        } else {
            CustomerCancellation.DISABLE_IF_AVAILABLE
        }
        return CollectPaymentIntentConfiguration.Builder()
            .setSurchargeNotice(surchargeNotice)
            .setRequestDynamicCurrencyConversion(requestDynamicCurrencyConversion)
            .skipTipping(skipTipping)
            .setTippingConfiguration(tippingConfiguration?.toHost())
            .updatePaymentIntent(shouldUpdatePaymentIntent)
            .setCustomerCancellation(customerCancellation)
            .setAllowRedisplay(allowRedisplay.toHost())
            .build()
    }

    override fun onStartProcessPaymentIntent(
        result: Result<PaymentIntentApi>,
        operationId: Long,
        paymentIntentId: String,
        requestDynamicCurrencyConversion: Boolean,
        surchargeNotice: String?,
        skipTipping: Boolean,
        tippingConfiguration: TippingConfigurationApi?,
        shouldUpdatePaymentIntent: Boolean,
        customerCancellationEnabled: Boolean,
        allowRedisplay: AllowRedisplayApi,
        confirmConfiguration: ConfirmPaymentIntentConfigurationApi?
    ) {
        val paymentIntent = findPaymentIntent(paymentIntentId)
        val collectConfig = buildCollectPaymentIntentConfiguration(
            requestDynamicCurrencyConversion = requestDynamicCurrencyConversion,
            surchargeNotice = surchargeNotice,
            skipTipping = skipTipping,
            tippingConfiguration = tippingConfiguration,
            shouldUpdatePaymentIntent = shouldUpdatePaymentIntent,
            customerCancellationEnabled = customerCancellationEnabled,
            allowRedisplay = allowRedisplay
        )
        val confirmConfig = confirmConfiguration?.toHost()
            ?: ConfirmPaymentIntentConfiguration.Builder().build()

        processPaymentIntentCancelables[operationId] = terminal.processPaymentIntent(
            paymentIntent,
            collectConfig,
            confirmConfig,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onFailure(e: TerminalException) {
                    processPaymentIntentCancelables.remove(operationId)
                    val paymentIntentUpdated = e.paymentIntent
                    if (paymentIntentUpdated != null) {
                        paymentIntents[paymentIntentUpdated.id!!] = paymentIntentUpdated
                    }
                    super.onFailure(e)
                }

                override fun onSuccess(paymentIntent: PaymentIntent) {
                    processPaymentIntentCancelables.remove(operationId)
                    paymentIntents.remove(paymentIntent.id)
                    result.success(paymentIntent.toApi())
                }
            }
        )
    }

    override fun onStopProcessPaymentIntent(result: Result<Unit>, operationId: Long) {
        processPaymentIntentCancelables.remove(operationId)?.cancel(
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onCancelPaymentIntent(result: Result<PaymentIntentApi>, paymentIntentId: String) {
        val paymentIntent = findPaymentIntent(paymentIntentId)
        terminal.cancelPaymentIntent(
            paymentIntent,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    paymentIntents.remove(paymentIntentId)
                    result.success(paymentIntent.toApi())
                }
            }
        )
    }
    // endregion

    // region Saving payment details for later use
    private var setupIntents = HashMap<String, SetupIntent>()
    override fun onCreateSetupIntent(
        result: Result<SetupIntentApi>,
        customerId: String?,
        metadata: HashMap<String, String>?,
        onBehalfOf: String?,
        description: String?,
        usage: SetupIntentUsageApi?
    ) {
        terminal.createSetupIntent(
            SetupIntentParameters.Builder()
                .setCustomer(customerId)
                .setMetadata(metadata)
                .setOnBehalfOf(onBehalfOf)
                .setDescription(description)
                .setUsage(usage?.toHost())
                .build(),
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    setupIntents[setupIntent.id!!] = setupIntent
                    result.success(setupIntent.toApi())
                }
            }
        )
    }

    override fun onRetrieveSetupIntent(result: Result<SetupIntentApi>, clientSecret: String) {
        terminal.retrieveSetupIntent(
            clientSecret,
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    setupIntents[setupIntent.id!!] = setupIntent
                    result.success(setupIntent.toApi())
                }
            }
        )
    }

    private var processSetupIntentCancelables = HashMap<Long, Cancelable>()

    override fun onStartProcessSetupIntent(
        result: Result<SetupIntentApi>,
        operationId: Long,
        setupIntentId: String,
        allowRedisplay: AllowRedisplayApi,
        customerCancellationEnabled: Boolean
    ) {
        val setupIntent = findSetupIntent(setupIntentId)
        val customerCancellation = if (customerCancellationEnabled) {
            CustomerCancellation.ENABLE_IF_AVAILABLE
        } else {
            CustomerCancellation.DISABLE_IF_AVAILABLE
        }
        val config =
            CollectSetupIntentConfiguration.Builder()
                .setCustomerCancellation(customerCancellation)

        processSetupIntentCancelables[operationId] = terminal.processSetupIntent(
            setupIntent,
            allowRedisplay.toHost(),
            config.build(),
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onFailure(e: TerminalException) {
                    processSetupIntentCancelables.remove(operationId)
                    super.onFailure(e)
                }

                override fun onSuccess(setupIntent: SetupIntent) {
                    processSetupIntentCancelables.remove(operationId)
                    setupIntents[setupIntent.id!!] = setupIntent
                    result.success(setupIntent.toApi())
                }
            }
        )
    }

    override fun onStopProcessSetupIntent(result: Result<Unit>, operationId: Long) {
        processSetupIntentCancelables.remove(operationId)?.cancel(
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onCancelSetupIntent(result: Result<SetupIntentApi>, setupIntentId: String) {
        val setupIntent = findSetupIntent(setupIntentId)
        terminal.cancelSetupIntent(
            setupIntent,
            SetupIntentCancellationParameters.Builder().build(),
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    setupIntents.remove(setupIntent.id)
                    result.success(setupIntent.toApi())
                }
            }
        )
    }
    // endregion

    // region Saving payment details for later use
    private var processRefundCancelables = HashMap<Long, Cancelable>()

    private var easyConnectCancelables = HashMap<Long, Cancelable>()
    override fun onStartProcessRefund(
        result: Result<RefundApi>,
        operationId: Long,
        chargeId: String?,
        paymentIntentId: String?,
        paymentIntentClientSecret: String?,
        amount: Long,
        currency: String,
        metadata: HashMap<String, String>?,
        reverseTransfer: Boolean?,
        refundApplicationFee: Boolean?,
        customerCancellationEnabled: Boolean
    ) {
        val customerCancellation = if (customerCancellationEnabled) {
            CustomerCancellation.ENABLE_IF_AVAILABLE
        } else {
            CustomerCancellation.DISABLE_IF_AVAILABLE
        }
        val config =
            CollectRefundConfiguration.Builder().setCustomerCancellation(customerCancellation)

        val params = buildRefundParameters(
            chargeId = chargeId,
            paymentIntentId = paymentIntentId,
            paymentIntentClientSecret = paymentIntentClientSecret,
            amount = amount,
            currency = currency,
            metadata = metadata,
            reverseTransfer = reverseTransfer,
            refundApplicationFee = refundApplicationFee
        )

        processRefundCancelables[operationId] = terminal.processRefund(
            params,
            config.build(),
            object : TerminalErrorHandler(result::error), RefundCallback {
                override fun onFailure(e: TerminalException) {
                    processRefundCancelables.remove(operationId)
                    super.onFailure(e)
                }

                override fun onSuccess(refund: Refund) {
                    processRefundCancelables.remove(operationId)
                    result.success(refund.toApi())
                }
            }
        )
    }

    override fun onStopProcessRefund(result: Result<Unit>, operationId: Long) {
        processRefundCancelables.remove(operationId)?.cancel(
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }
    // endregion

    // region Display information to customers
    override fun onSetReaderDisplay(result: Result<Unit>, cart: CartApi) {
        terminal.setReaderDisplay(
            cart.toHost(),
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onClearReaderDisplay(result: Result<Unit>) {
        terminal.clearReaderDisplay(
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onSetTapToPayUXConfiguration(configuration: TapToPayUxConfigurationApi) {
        terminal.setTapToPayUxConfiguration(configuration.toHost());
    }

    override fun onIsTapToPayAccountLinked(onBehalfOf: String?): Boolean {
        return true // Always return true for android
    }
    // endregion

    // ======================== INTERNAL METHODS

    private fun buildRefundParameters(
        chargeId: String?,
        paymentIntentId: String?,
        paymentIntentClientSecret: String?,
        amount: Long,
        currency: String,
        metadata: HashMap<String, String>?,
        reverseTransfer: Boolean?,
        refundApplicationFee: Boolean?
    ): RefundParameters {
        val params = when {
            paymentIntentId != null -> {
                val clientSecret = paymentIntentClientSecret
                    ?: throw IllegalArgumentException("paymentIntentClientSecret is required when paymentIntentId is provided")
                RefundParameters.ByPaymentIntentId(
                    id = paymentIntentId,
                    clientSecret = clientSecret,
                    amount = amount,
                    currency = currency
                )
            }
            chargeId != null -> RefundParameters.ByChargeId(
                id = chargeId,
                amount = amount,
                currency = currency
            )
            else -> throw IllegalArgumentException("Either chargeId or paymentIntentId must be provided")
        }
        metadata?.let(params::setMetadata)
        reverseTransfer?.let(params::setReverseTransfer)
        refundApplicationFee?.let(params::setRefundApplicationFee)
        return params.build()
    }

    private fun findActiveReader(serialNumber: String): Reader {
        val reader = discoveredReaders.firstOrNull { it.serialNumber == serialNumber }
        return reader
            ?: throw createApiError(TerminalExceptionCodeApi.READER_NOT_RECOVERED).toPlatformError()
    }

    private fun findPaymentIntent(paymentIntentId: String): PaymentIntent {
        val paymentIntent = paymentIntents[paymentIntentId]
        return paymentIntent
            ?: throw createApiError(TerminalExceptionCodeApi.PAYMENT_INTENT_NOT_RECOVERED)
                .toPlatformError()
    }

    private fun findSetupIntent(setupIntentId: String): SetupIntent {
        val setupIntent = setupIntents[setupIntentId]
        return setupIntent
            ?: throw createApiError(TerminalExceptionCodeApi.SETUP_INTENT_NOT_RECOVERED)
                .toPlatformError()
    }

    internal fun clean() {
        if (terminal.connectedReader != null) {
            runOnMainThread {
                terminal.disconnectReader(EmptyCallback())
            }
        }

        discoverReadersSubject.clear()

        processPaymentIntentCancelables.values.forEach { it.cancel(EmptyCallback()) }
        processPaymentIntentCancelables = hashMapOf()
        paymentIntents = hashMapOf()

        processSetupIntentCancelables.values.forEach { it.cancel(EmptyCallback()) }
        processSetupIntentCancelables = hashMapOf()
        setupIntents = hashMapOf()

        processRefundCancelables.values.forEach { it.cancel(EmptyCallback()) }
        processRefundCancelables = hashMapOf()
        easyConnectCancelables.values.forEach { it.cancel(EmptyCallback()) }
        easyConnectCancelables = hashMapOf()
    }
}

class EmptyCallback : Callback {
    override fun onFailure(e: TerminalException) {}

    override fun onSuccess() {}
}

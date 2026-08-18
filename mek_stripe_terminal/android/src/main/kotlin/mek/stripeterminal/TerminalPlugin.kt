package mek.stripeterminal

import ClearCachedCredentialsResultApi
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
import AllowRedisplayApi
import CartApi
import ConfirmPaymentIntentConfigurationApi
import ConnectionConfigurationApi
import ConnectionStatusApi
import TerminalHandlersApi
import TerminalPlatformApi
import DeviceTypeApi
import DiscoverReadersStreamHandler
import DiscoveryConfigurationApi
import EasyConnectConfigurationApi
import LocationApi
import PaymentIntentApi
import PaymentIntentParametersApi
import PaymentStatusApi
import ReaderApi
import RefundApi
import SetupIntentApi
import SetupIntentUsageApi
import SimulatorConfigurationApi
import TapToPayUxConfigurationApi
import TerminalExceptionCodeApi
import TippingConfigurationApi
import mek.stripeterminal.mappings.createApiException
import mek.stripeterminal.mappings.createError
import mek.stripeterminal.mappings.mapExceptionToApi
import mek.stripeterminal.mappings.toApi
import mek.stripeterminal.mappings.toHost
import mek.stripeterminal.plugin.DiscoverReadersStreamController
import mek.stripeterminal.plugin.ReaderDelegatePlugin
import mek.stripeterminal.plugin.TerminalDelegatePlugin
import mek.stripeterminal.plugin.TerminalErrorHandler

class TerminalPlugin : FlutterPlugin, ActivityAware {
    companion object {
        private var handlerOwner: TerminalPlugin? = null
    }

    private lateinit var platform: TerminalPlatformPlugin
    private lateinit var discoverReadersStreamController: DiscoverReadersStreamController

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        discoverReadersStreamController = DiscoverReadersStreamController();
        DiscoverReadersStreamHandler.register(binding.binaryMessenger, discoverReadersStreamController)

        platform = TerminalPlatformPlugin(
            applicationContext = binding.applicationContext,
            handlers = TerminalHandlersApi(binding.binaryMessenger),
            discoverReadersStreamController = discoverReadersStreamController,
        )
        TerminalPlatformApi.setUp(binding.binaryMessenger, platform)
        handlerOwner = this
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (Terminal.isInitialized()) platform.clean()
        if (handlerOwner === this) {
            TerminalPlatformApi.setUp(binding.binaryMessenger, null)
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
    private val discoverReadersStreamController: DiscoverReadersStreamController,
) : TerminalPlatformApi {

    private val terminal: Terminal get() = Terminal.getInstance()

    override fun initialize(shouldPrintLogs: Boolean) {
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

    override fun clearCachedCredentials(): ClearCachedCredentialsResultApi {
        val result = terminal.clearCachedCredentials()
        if (result.isSuccessful) {
            clean()
        }
        return ClearCachedCredentialsResultApi(
            isSuccessful = result.isSuccessful,
            error = if (result.error != null) mapExceptionToApi(result.error!!) else null,
        )

    }

    // region Reader discovery, connection and updates
    private val discoveredReaders: List<Reader>
        get() = discoverReadersStreamController.readers

    private val readerDelegate: ReaderDelegatePlugin = ReaderDelegatePlugin(handlers)

    override fun getConnectionStatus(): ConnectionStatusApi = terminal.connectionStatus.toApi()

    override fun supportsReadersOfType(
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

    override fun applyDiscoverReadersParameters(configuration: DiscoveryConfigurationApi) {
        discoverReadersStreamController.configuration = configuration.toHost()
    }

    override fun connectReader(
        serialNumber: String,
        configuration: ConnectionConfigurationApi,
        callback: (Result<ReaderApi>) -> Unit
    ) {
        val reader = findActiveReader(serialNumber)

        terminal.connectReader(
            reader,
            configuration.toHost(readerDelegate),
            object : TerminalErrorHandler<ReaderApi>(callback), ReaderCallback {
                override fun onSuccess(reader: Reader) = callback(Result.success(reader.toApi()))
            }
        )
    }

    private var easyConnectCancelables = HashMap<Long, Cancelable>()

    override fun startEasyConnect(
        operationId: Long,
        configuration: EasyConnectConfigurationApi,
        callback: (Result<ReaderApi>) -> Unit
    ) {
        val hostConfiguration = configuration.toHost(readerDelegate)
        easyConnectCancelables[operationId] = terminal.easyConnect(
            hostConfiguration,
            object : TerminalErrorHandler<ReaderApi>(callback), ReaderCallback {
                override fun onFailure(e: TerminalException) {
                    easyConnectCancelables.remove(operationId)
                    super.onFailure(e)
                }

                override fun onSuccess(reader: Reader) {
                    easyConnectCancelables.remove(operationId)
                    callback(Result.success(reader.toApi()))
                }
            }
        )
    }

    override fun stopEasyConnect(
        operationId: Long,
        callback: (Result<Unit>) -> Unit
    ) {
        easyConnectCancelables.remove(operationId)?.cancel(
            object : TerminalErrorHandler<Unit>(callback), Callback {
                override fun onSuccess() = callback(Result.success(Unit))
            }
        )
    }

    override fun getConnectedReader(): ReaderApi? = terminal.connectedReader?.toApi()

    override fun cancelReaderReconnection(callback: (Result<Unit>) -> Unit) {
        readerDelegate.cancelReconnect(
            object : Callback, TerminalErrorHandler<Unit>(callback) {
                override fun onSuccess() = callback(Result.success(Unit))
            }
        )
    }

    override fun listLocations(
        endingBefore: String?,
        limit: Long?,
        startingAfter: String?,
        callback: (Result<List<LocationApi>>) -> Unit
    ) {
        val params = ListLocationsParameters.Builder()
        params.endingBefore = endingBefore
        params.startingAfter = startingAfter
        params.limit = limit?.toInt()
        terminal.listLocations(
            params.build(),
            object : TerminalErrorHandler<List<LocationApi>>(callback), LocationListCallback {
                override fun onSuccess(locations: List<Location>, hasMore: Boolean) =
                    callback(Result.success(locations.map { it.toApi() }))
            }
        )
    }

    override fun installAvailableUpdate() = terminal.installAvailableUpdate()

    override fun cancelReaderUpdate(callback: (Result<Unit>) -> Unit) {
        readerDelegate.cancelUpdate(
            object : Callback, TerminalErrorHandler<Unit>(callback) {
                override fun onSuccess() = callback(Result.success(Unit))
            }
        )
    }

    override fun rebootReader(callback: (Result<Unit>) -> Unit) {
        terminal.rebootReader(
            object : TerminalErrorHandler<Unit>(callback), Callback {
                override fun onSuccess() = callback(Result.success(Unit))
            }
        )
    }

    override fun disconnectReader(callback: (Result<Unit>) -> Unit) {
        terminal.disconnectReader(
            object : TerminalErrorHandler<Unit>(callback), Callback {
                override fun onSuccess() = callback(Result.success(Unit))
            }
        )
    }

    override fun setSimulatorConfiguration(configuration: SimulatorConfigurationApi) {
        terminal.simulatorConfiguration = configuration.toHost()
    }


    // endregion

    // region Taking Payment
    private var paymentIntents = HashMap<String, PaymentIntent>()

    override fun getPaymentStatus(): PaymentStatusApi  = terminal.paymentStatus.toApi()

    override fun createPaymentIntent(
        parameters: PaymentIntentParametersApi,
        callback: (Result<PaymentIntentApi>) -> Unit
    ) {
        terminal.createPaymentIntent(
            params = parameters.toHost(),
            callback =
                object : TerminalErrorHandler<PaymentIntentApi>(callback), PaymentIntentCallback {
                    override fun onSuccess(paymentIntent: PaymentIntent) {
                        paymentIntents[paymentIntent.id!!] = paymentIntent
                        callback(Result.success(paymentIntent.toApi()))
                    }
                }
        )    }

    override fun retrievePaymentIntent(
        clientSecret: String,
        callback: (Result<PaymentIntentApi>) -> Unit
    ) {
        terminal.retrievePaymentIntent(
            clientSecret,
            object : TerminalErrorHandler<PaymentIntentApi>(callback), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    paymentIntents[paymentIntent.id!!] = paymentIntent
                    callback(Result.success(paymentIntent.toApi()))
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

    override fun startProcessPaymentIntent(
        operationId: Long,
        paymentIntentId: String,
        requestDynamicCurrencyConversion: Boolean,
        surchargeNotice: String?,
        skipTipping: Boolean,
        tippingConfiguration: TippingConfigurationApi?,
        shouldUpdatePaymentIntent: Boolean,
        customerCancellationEnabled: Boolean,
        allowRedisplay: AllowRedisplayApi,
        confirmConfiguration: ConfirmPaymentIntentConfigurationApi,
        callback: (Result<PaymentIntentApi>) -> Unit
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
        val confirmConfig = confirmConfiguration.toHost()

        processPaymentIntentCancelables[operationId] = terminal.processPaymentIntent(
            intent = paymentIntent,
            collectConfig = collectConfig,
            confirmConfig = confirmConfig,
            object : TerminalErrorHandler<PaymentIntentApi>(callback), PaymentIntentCallback {
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
                    callback(Result.success(paymentIntent.toApi()))
                }
            }
        )
    }

    override fun stopProcessPaymentIntent(
        operationId: Long,
        callback: (Result<Unit>) -> Unit
    ) {
        processPaymentIntentCancelables.remove(operationId)?.cancel(
            object : TerminalErrorHandler<Unit>(callback), Callback {
                override fun onSuccess() = callback(Result.success(Unit))
            }
        )
    }

    override fun cancelPaymentIntent(
        paymentIntentId: String,
        callback: (Result<PaymentIntentApi>) -> Unit
    ) {
        val paymentIntent = findPaymentIntent(paymentIntentId)
        terminal.cancelPaymentIntent(
            paymentIntent,
            object : TerminalErrorHandler<PaymentIntentApi>(callback), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    paymentIntents.remove(paymentIntentId)
                    callback(Result.success(paymentIntent.toApi()))
                }
            }
        )
    }
    // endregion

    // region Saving payment details for later use
    private var setupIntents = HashMap<String, SetupIntent>()

    override fun createSetupIntent(
        customerId: String?,
        metadata: Map<String, String>?,
        onBehalfOf: String?,
        description: String?,
        usage: SetupIntentUsageApi?,
        callback: (Result<SetupIntentApi>) -> Unit
    ) {
        terminal.createSetupIntent(
            SetupIntentParameters.Builder()
                .setCustomer(customerId)
                .setMetadata(metadata)
                .setOnBehalfOf(onBehalfOf)
                .setDescription(description)
                .setUsage(usage?.toHost())
                .build(),
            object : TerminalErrorHandler<SetupIntentApi>(callback), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    setupIntents[setupIntent.id!!] = setupIntent
                    callback(Result.success(setupIntent.toApi()))
                }
            }
        )
    }

    override fun retrieveSetupIntent(
        clientSecret: String,
        callback: (Result<SetupIntentApi>) -> Unit
    ) {
        terminal.retrieveSetupIntent(
            clientSecret,
            object : TerminalErrorHandler<SetupIntentApi>(callback), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    setupIntents[setupIntent.id!!] = setupIntent
                    callback(Result.success(setupIntent.toApi()))
                }
            }
        )
    }

    private var processSetupIntentCancelables = HashMap<Long, Cancelable>()

    override fun startProcessSetupIntent(
        operationId: Long,
        setupIntentId: String,
        allowRedisplay: AllowRedisplayApi,
        customerCancellationEnabled: Boolean,
        callback: (Result<SetupIntentApi>) -> Unit
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
            object : TerminalErrorHandler<SetupIntentApi>(callback), SetupIntentCallback {
                override fun onFailure(e: TerminalException) {
                    processSetupIntentCancelables.remove(operationId)
                    super.onFailure(e)
                }

                override fun onSuccess(setupIntent: SetupIntent) {
                    processSetupIntentCancelables.remove(operationId)
                    setupIntents[setupIntent.id!!] = setupIntent
                    callback(Result.success(setupIntent.toApi()))
                }
            }
        )
    }

    override fun stopProcessSetupIntent(
        operationId: Long,
        callback: (Result<Unit>) -> Unit
    ) {
        processSetupIntentCancelables.remove(operationId)?.cancel(
            object : TerminalErrorHandler<Unit>(callback), Callback {
                override fun onSuccess() = callback(Result.success(Unit))
            }
        )
    }

    override fun cancelSetupIntent(
        setupIntentId: String,
        callback: (Result<SetupIntentApi>) -> Unit
    ) {
        val setupIntent = findSetupIntent(setupIntentId)
        terminal.cancelSetupIntent(
            setupIntent,
            SetupIntentCancellationParameters.Builder().build(),
            object : TerminalErrorHandler<SetupIntentApi>(callback), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    setupIntents.remove(setupIntent.id)
                    callback(Result.success(setupIntent.toApi()))
                }
            }
        )
    }
    // endregion

    // region Saving payment details for later use
    private var processRefundCancelables = HashMap<Long, Cancelable>()

    override fun startProcessRefund(
        operationId: Long,
        chargeId: String?,
        paymentIntentId: String?,
        paymentIntentClientSecret: String?,
        amount: Long,
        currency: String,
        metadata: Map<String, String>?,
        reverseTransfer: Boolean?,
        refundApplicationFee: Boolean?,
        customerCancellationEnabled: Boolean,
        callback: (Result<RefundApi>) -> Unit
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
            metadata = metadata?.toHashMap(),
            reverseTransfer = reverseTransfer,
            refundApplicationFee = refundApplicationFee
        )

        processRefundCancelables[operationId] = terminal.processRefund(
            params,
            config.build(),
            object : TerminalErrorHandler<RefundApi>(callback), RefundCallback {
                override fun onFailure(e: TerminalException) {
                    processRefundCancelables.remove(operationId)
                    super.onFailure(e)
                }

                override fun onSuccess(refund: Refund) {
                    processRefundCancelables.remove(operationId)
                    callback(Result.success(refund.toApi()))
                }
            }
        )
    }

    override fun stopProcessRefund(
        operationId: Long,
        callback: (Result<Unit>) -> Unit
    ) {
        processRefundCancelables.remove(operationId)?.cancel(
            object : TerminalErrorHandler<Unit>(callback), Callback {
                override fun onSuccess() = callback(Result.success(Unit))
            }
        )
    }
    // endregion

    // region Display information to customers

    override fun setReaderDisplay(
        cart: CartApi,
        callback: (Result<Unit>) -> Unit
    ) {
        terminal.setReaderDisplay(
            cart.toHost(),
            object : TerminalErrorHandler<Unit>(callback), Callback {
                override fun onSuccess() = callback(Result.success(Unit))
            }
        )
    }

    override fun clearReaderDisplay(callback: (Result<Unit>) -> Unit) {
        terminal.clearReaderDisplay(
            object : TerminalErrorHandler<Unit>(callback), Callback {
                override fun onSuccess() = callback(Result.success(Unit))
            }
        )
    }

    override fun setTapToPayUXConfiguration(configuration: TapToPayUxConfigurationApi) {
        terminal.setTapToPayUxConfiguration(configuration.toHost())
    }

    override fun isTapToPayAccountLinked(
        onBehalfOf: String?,
        callback: (Result<Boolean>) -> Unit
    ) {
        callback(Result.success(true)) // Always return true for android

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
            ?: throw createError(createApiException(TerminalExceptionCodeApi.READER_NOT_RECOVERED))
    }

    private fun findPaymentIntent(paymentIntentId: String): PaymentIntent {
        val paymentIntent = paymentIntents[paymentIntentId]
        return paymentIntent
            ?: throw createError(createApiException(TerminalExceptionCodeApi.PAYMENT_INTENT_NOT_RECOVERED))
    }

    private fun findSetupIntent(setupIntentId: String): SetupIntent {
        val setupIntent = setupIntents[setupIntentId]
        return setupIntent
            ?: throw createError(createApiException(TerminalExceptionCodeApi.SETUP_INTENT_NOT_RECOVERED))
    }

    internal fun clean() {
        if (terminal.connectedReader != null) {
            runOnMainThread {
                terminal.disconnectReader(EmptyCallback())
            }
        }

        discoverReadersStreamController.clear()

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

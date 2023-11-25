// GENERATED CODE - DO NOT MODIFY BY HAND

package mek.stripeterminal.api

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class PlatformError(
    val code: String,
    message: String?,
    val details: Any? = null
) : RuntimeException(message ?: code)

class Result<T>(
    private val result: MethodChannel.Result,
    private val serializer: (data: T) -> Any?
) {
    fun success(data: T) = result.success(serializer(data))

    fun error(error: PlatformError) {
        result.error(error.code, error.message, error.details)
    }
}

class ControllerSink<T>(
    private val sink: EventChannel.EventSink,
    private val serializer: (data: T) -> Any?
) {
    fun success(data: T) = sink.success(serializer(data))

    fun error(error: PlatformError) = sink.error(error.code, error.message, error.details)

    fun endOfStream() = sink.endOfStream()
}

interface TerminalPlatformApi {
    fun onInit(shouldPrintLogs: Boolean)

    fun onClearCachedCredentials()

    fun onGetConnectionStatus(): ConnectionStatusApi

    fun onSupportsReadersOfType(
        deviceType: DeviceTypeApi?,
        discoveryConfiguration: DiscoveryConfigurationApi
    ): Boolean

    fun onConnectBluetoothReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean
    )

    fun onConnectHandoffReader(result: Result<ReaderApi>, serialNumber: String)

    fun onConnectInternetReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        failIfInUse: Boolean
    )

    fun onConnectMobileReader(result: Result<ReaderApi>, serialNumber: String, locationId: String)

    fun onConnectUsbReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean
    )

    fun onGetConnectedReader(): ReaderApi?

    fun onCancelReaderReconnection(result: Result<Unit>)

    fun onListLocations(
        result: Result<List<LocationApi>>,
        endingBefore: String?,
        limit: Long?,
        startingAfter: String?
    )

    fun onInstallAvailableUpdate()

    fun onCancelReaderUpdate(result: Result<Unit>)

    fun onDisconnectReader(result: Result<Unit>)

    fun onSetSimulatorConfiguration(configuration: SimulatorConfigurationApi)

    fun onGetPaymentStatus(): PaymentStatusApi

    fun onCreatePaymentIntent(
        result: Result<PaymentIntentApi>,
        parameters: PaymentIntentParametersApi
    )

    fun onRetrievePaymentIntent(result: Result<PaymentIntentApi>, clientSecret: String)

    fun onStartCollectPaymentMethod(
        result: Result<PaymentIntentApi>,
        operationId: Long,
        paymentIntentId: String,
        skipTipping: Boolean,
        tippingConfiguration: TippingConfigurationApi?,
        shouldUpdatePaymentIntent: Boolean,
        customerCancellationEnabled: Boolean
    )

    fun onStopCollectPaymentMethod(result: Result<Unit>, operationId: Long)

    fun onConfirmPaymentIntent(result: Result<PaymentIntentApi>, paymentIntentId: String)

    fun onCancelPaymentIntent(result: Result<PaymentIntentApi>, paymentIntentId: String)

    fun onCreateSetupIntent(
        result: Result<SetupIntentApi>,
        customerId: String?,
        metadata: HashMap<String, String>?,
        onBehalfOf: String?,
        description: String?,
        usage: SetupIntentUsageApi?
    )

    fun onRetrieveSetupIntent(result: Result<SetupIntentApi>, clientSecret: String)

    fun onStartCollectSetupIntentPaymentMethod(
        result: Result<SetupIntentApi>,
        operationId: Long,
        setupIntentId: String,
        customerConsentCollected: Boolean,
        customerCancellationEnabled: Boolean
    )

    fun onStopCollectSetupIntentPaymentMethod(result: Result<Unit>, operationId: Long)

    fun onConfirmSetupIntent(result: Result<SetupIntentApi>, setupIntentId: String)

    fun onCancelSetupIntent(result: Result<SetupIntentApi>, setupIntentId: String)

    fun onStartCollectRefundPaymentMethod(
        result: Result<Unit>,
        operationId: Long,
        chargeId: String,
        amount: Long,
        currency: String,
        metadata: HashMap<String, String>?,
        reverseTransfer: Boolean?,
        refundApplicationFee: Boolean?,
        customerCancellationEnabled: Boolean
    )

    fun onStopCollectRefundPaymentMethod(result: Result<Unit>, operationId: Long)

    fun onConfirmRefund(result: Result<RefundApi>)

    fun onSetReaderDisplay(result: Result<Unit>, cart: CartApi)

    fun onClearReaderDisplay(result: Result<Unit>)

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            val args = call.arguments<List<Any?>>()!!

            fun runAsync(callback: suspend () -> Any?) {
                coroutineScope.launch {
                    val res = callback()
                    withContext(Dispatchers.Main) { result.success(res) }
                }
            }
            when (call.method) {
                "init" -> {
                    onInit(args[0] as Boolean)
                    result.success(null)
                }
                "clearCachedCredentials" -> {
                    onClearCachedCredentials()
                    result.success(null)
                }
                "getConnectionStatus" -> {
                    val res = onGetConnectionStatus()
                    result.success(res.ordinal)
                }
                "supportsReadersOfType" -> {
                    val res =
                        onSupportsReadersOfType(
                            (args[0] as Int?)?.let {
                                DeviceTypeApi.values()[it]
                            },
                            (args[1] as List<Any?>).let {
                                DiscoveryConfigurationApi.deserialize(
                                    it
                                )
                            }
                        )
                    result.success(res)
                }
                "connectBluetoothReader" -> {
                    val res = Result<ReaderApi>(result) { it.serialize() }
                    onConnectBluetoothReader(
                        res,
                        args[0] as String,
                        args[1] as String,
                        args[2] as Boolean
                    )
                }
                "connectHandoffReader" -> {
                    val res = Result<ReaderApi>(result) { it.serialize() }
                    onConnectHandoffReader(res, args[0] as String)
                }
                "connectInternetReader" -> {
                    val res = Result<ReaderApi>(result) { it.serialize() }
                    onConnectInternetReader(res, args[0] as String, args[1] as Boolean)
                }
                "connectMobileReader" -> {
                    val res = Result<ReaderApi>(result) { it.serialize() }
                    onConnectMobileReader(res, args[0] as String, args[1] as String)
                }
                "connectUsbReader" -> {
                    val res = Result<ReaderApi>(result) { it.serialize() }
                    onConnectUsbReader(
                        res,
                        args[0] as String,
                        args[1] as String,
                        args[2] as Boolean
                    )
                }
                "getConnectedReader" -> {
                    val res = onGetConnectedReader()
                    result.success(res?.serialize())
                }
                "cancelReaderReconnection" -> {
                    val res = Result<Unit>(result) { null }
                    onCancelReaderReconnection(res)
                }
                "listLocations" -> {
                    val res = Result<List<LocationApi>>(result) { it.map { it.serialize() } }
                    onListLocations(
                        res,
                        args[0] as String?,
                        (args[1] as? Number)?.toLong(),
                        args[2] as String?
                    )
                }
                "installAvailableUpdate" -> {
                    onInstallAvailableUpdate()
                    result.success(null)
                }
                "cancelReaderUpdate" -> {
                    val res = Result<Unit>(result) { null }
                    onCancelReaderUpdate(res)
                }
                "disconnectReader" -> {
                    val res = Result<Unit>(result) { null }
                    onDisconnectReader(res)
                }
                "setSimulatorConfiguration" -> {
                    onSetSimulatorConfiguration(
                        (args[0] as List<Any?>).let {
                            SimulatorConfigurationApi.deserialize(it)
                        }
                    )
                    result.success(null)
                }
                "getPaymentStatus" -> {
                    val res = onGetPaymentStatus()
                    result.success(res.ordinal)
                }
                "createPaymentIntent" -> {
                    val res = Result<PaymentIntentApi>(result) { it.serialize() }
                    onCreatePaymentIntent(
                        res,
                        (args[0] as List<Any?>).let {
                            PaymentIntentParametersApi.deserialize(it)
                        }
                    )
                }
                "retrievePaymentIntent" -> {
                    val res = Result<PaymentIntentApi>(result) { it.serialize() }
                    onRetrievePaymentIntent(res, args[0] as String)
                }
                "startCollectPaymentMethod" -> {
                    val res = Result<PaymentIntentApi>(result) { it.serialize() }
                    onStartCollectPaymentMethod(
                        res,
                        (args[0] as Number).toLong(),
                        args[1] as String,
                        args[2] as Boolean,
                        (args[3] as List<Any?>?)?.let {
                            TippingConfigurationApi.deserialize(it)
                        },
                        args[4] as Boolean,
                        args[5] as Boolean
                    )
                }
                "stopCollectPaymentMethod" -> {
                    val res = Result<Unit>(result) { null }
                    onStopCollectPaymentMethod(res, (args[0] as Number).toLong())
                }
                "confirmPaymentIntent" -> {
                    val res = Result<PaymentIntentApi>(result) { it.serialize() }
                    onConfirmPaymentIntent(res, args[0] as String)
                }
                "cancelPaymentIntent" -> {
                    val res = Result<PaymentIntentApi>(result) { it.serialize() }
                    onCancelPaymentIntent(res, args[0] as String)
                }
                "createSetupIntent" -> {
                    val res = Result<SetupIntentApi>(result) { it.serialize() }
                    onCreateSetupIntent(
                        res,
                        args[0] as String?,
                        args[1]?.let {
                            hashMapOf(
                                *(it as HashMap<*, *>).map {
                                        (k, v) ->
                                    k as String to v as String
                                }.toTypedArray()
                            )
                        },
                        args[2] as String?,
                        args[3] as String?,
                        (args[4] as Int?)?.let { SetupIntentUsageApi.values()[it] }
                    )
                }
                "retrieveSetupIntent" -> {
                    val res = Result<SetupIntentApi>(result) { it.serialize() }
                    onRetrieveSetupIntent(res, args[0] as String)
                }
                "startCollectSetupIntentPaymentMethod" -> {
                    val res = Result<SetupIntentApi>(result) { it.serialize() }
                    onStartCollectSetupIntentPaymentMethod(
                        res,
                        (args[0] as Number).toLong(),
                        args[1] as String,
                        args[2] as Boolean,
                        args[3] as Boolean
                    )
                }
                "stopCollectSetupIntentPaymentMethod" -> {
                    val res = Result<Unit>(result) { null }
                    onStopCollectSetupIntentPaymentMethod(res, (args[0] as Number).toLong())
                }
                "confirmSetupIntent" -> {
                    val res = Result<SetupIntentApi>(result) { it.serialize() }
                    onConfirmSetupIntent(res, args[0] as String)
                }
                "cancelSetupIntent" -> {
                    val res = Result<SetupIntentApi>(result) { it.serialize() }
                    onCancelSetupIntent(res, args[0] as String)
                }
                "startCollectRefundPaymentMethod" -> {
                    val res = Result<Unit>(result) { null }
                    onStartCollectRefundPaymentMethod(
                        res, (args[0] as Number).toLong(), args[1] as String, (args[2] as Number).toLong(), args[3] as String,
                        args[4]?.let {
                            hashMapOf(
                                *(it as HashMap<*, *>).map {
                                        (k, v) ->
                                    k as String to v as String
                                }.toTypedArray()
                            )
                        },
                        args[5] as Boolean?, args[6] as Boolean?, args[7] as Boolean
                    )
                }
                "stopCollectRefundPaymentMethod" -> {
                    val res = Result<Unit>(result) { null }
                    onStopCollectRefundPaymentMethod(res, (args[0] as Number).toLong())
                }
                "confirmRefund" -> {
                    val res = Result<RefundApi>(result) { it.serialize() }
                    onConfirmRefund(res)
                }
                "setReaderDisplay" -> {
                    val res = Result<Unit>(result) { null }
                    onSetReaderDisplay(res, (args[0] as List<Any?>).let { CartApi.deserialize(it) })
                }
                "clearReaderDisplay" -> {
                    val res = Result<Unit>(result) { null }
                    onClearReaderDisplay(res)
                }
            }
        } catch (e: PlatformError) {
            result.error(e.code, e.message, e.details)
        }
    }

    companion object {
        private lateinit var channel: MethodChannel
        private lateinit var coroutineScope: CoroutineScope

        fun setHandler(
            binaryMessenger: BinaryMessenger,
            api: TerminalPlatformApi,
            coroutineScope: CoroutineScope? = null
        ) {
            channel = MethodChannel(binaryMessenger, "mek_stripe_terminal#TerminalPlatform")
            this.coroutineScope = coroutineScope ?: MainScope()
            channel.setMethodCallHandler(api::onMethodCall)
        }

        fun removeHandler() {
            channel.setMethodCallHandler(null)
            coroutineScope.cancel()
        }
    }
}

class DiscoverReadersControllerApi(
    binaryMessenger: BinaryMessenger
) {
    private val channel: EventChannel =
        EventChannel(binaryMessenger, "mek_stripe_terminal#TerminalPlatform#discoverReaders")

    fun setHandler(
        onListen: (
            sink: ControllerSink<List<ReaderApi>>,
            configuration: DiscoveryConfigurationApi
        ) -> Unit,
        onCancel: () -> Unit
    ) {
        channel.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    val args = arguments as List<Any?>
                    val sink = ControllerSink<List<ReaderApi>>(events) { it.map { it.serialize() } }
                    onListen(
                        sink,
                        (args[0] as List<Any?>).let { DiscoveryConfigurationApi.deserialize(it) }
                    )
                }

                override fun onCancel(arguments: Any?) = onCancel()
            }
        )
    }

    fun removeHandler() = channel.setStreamHandler(null)
}

class TerminalHandlersApi(
    binaryMessenger: BinaryMessenger
) {
    private val channel: MethodChannel =
        MethodChannel(binaryMessenger, "mek_stripe_terminal#TerminalHandlers")

    fun requestConnectionToken(
        onError: (error: PlatformError) -> Unit,
        onSuccess: (data: String) -> Unit
    ) {
        channel.invokeMethod(
            "_onRequestConnectionToken",
            listOf<Any?>(),
            object : MethodChannel.Result {
                override fun notImplemented() {}

                override fun error(code: String, message: String?, details: Any?) =
                    onError(PlatformError(code, message, details))

                override fun success(result: Any?) = onSuccess(result as String)
            }
        )
    }

    fun unexpectedReaderDisconnect(reader: ReaderApi) {
        channel.invokeMethod("_onUnexpectedReaderDisconnect", listOf<Any?>(reader.serialize()))
    }

    fun connectionStatusChange(connectionStatus: ConnectionStatusApi) {
        channel.invokeMethod("_onConnectionStatusChange", listOf<Any?>(connectionStatus.ordinal))
    }

    fun paymentStatusChange(paymentStatus: PaymentStatusApi) {
        channel.invokeMethod("_onPaymentStatusChange", listOf<Any?>(paymentStatus.ordinal))
    }

    fun readerReportEvent(event: ReaderEventApi) {
        channel.invokeMethod("_onReaderReportEvent", listOf<Any?>(event.ordinal))
    }

    fun readerRequestDisplayMessage(message: ReaderDisplayMessageApi) {
        channel.invokeMethod("_onReaderRequestDisplayMessage", listOf<Any?>(message.ordinal))
    }

    fun readerRequestInput(options: List<ReaderInputOptionApi>) {
        channel.invokeMethod("_onReaderRequestInput", listOf<Any?>(options.map { it.ordinal }))
    }

    fun readerBatteryLevelUpdate(
        batteryLevel: Double,
        batteryStatus: BatteryStatusApi?,
        isCharging: Boolean
    ) {
        channel.invokeMethod(
            "_onReaderBatteryLevelUpdate",
            listOf<Any?>(batteryLevel, batteryStatus?.ordinal, isCharging)
        )
    }

    fun readerReportLowBatteryWarning() {
        channel.invokeMethod("_onReaderReportLowBatteryWarning", listOf<Any?>())
    }

    fun readerReportAvailableUpdate(update: ReaderSoftwareUpdateApi) {
        channel.invokeMethod("_onReaderReportAvailableUpdate", listOf<Any?>(update.serialize()))
    }

    fun readerStartInstallingUpdate(update: ReaderSoftwareUpdateApi) {
        channel.invokeMethod("_onReaderStartInstallingUpdate", listOf<Any?>(update.serialize()))
    }

    fun readerReportSoftwareUpdateProgress(progress: Double) {
        channel.invokeMethod("_onReaderReportSoftwareUpdateProgress", listOf<Any?>(progress))
    }

    fun readerFinishInstallingUpdate(
        update: ReaderSoftwareUpdateApi?,
        exception: TerminalExceptionApi?
    ) {
        channel.invokeMethod(
            "_onReaderFinishInstallingUpdate",
            listOf<Any?>(update?.serialize(), exception?.serialize())
        )
    }

    fun readerReconnectFailed(reader: ReaderApi) {
        channel.invokeMethod("_onReaderReconnectFailed", listOf<Any?>(reader.serialize()))
    }

    fun readerReconnectStarted(reader: ReaderApi) {
        channel.invokeMethod("_onReaderReconnectStarted", listOf<Any?>(reader.serialize()))
    }

    fun readerReconnectSucceeded(reader: ReaderApi) {
        channel.invokeMethod("_onReaderReconnectSucceeded", listOf<Any?>(reader.serialize()))
    }
}

data class AddressApi(
    val city: String?,
    val country: String?,
    val line1: String?,
    val line2: String?,
    val postalCode: String?,
    val state: String?
) {
    fun serialize(): List<Any?> {
        return listOf(
            city,
            country,
            line1,
            line2,
            postalCode,
            state
        )
    }
}

data class AmountDetailsApi(
    val tip: TipApi?
) {
    fun serialize(): List<Any?> {
        return listOf(
            tip?.serialize()
        )
    }
}

enum class BatteryStatusApi {
    CRITICAL,
    LOW,
    NOMINAL
}

enum class CaptureMethodApi {
    AUTOMATIC,
    MANUAL
}

enum class CardBrandApi {
    AMEX,
    DINERS_CLUB,
    DISCOVER,
    JCB,
    MASTER_CARD,
    UNION_PAY,
    VISA,
    INTERAC,
    EFTPOS_AU
}

data class CardDetailsApi(
    val brand: CardBrandApi?,
    val country: String?,
    val expMonth: Long,
    val expYear: Long,
    val funding: CardFundingTypeApi?,
    val last4: String?
) {
    fun serialize(): List<Any?> {
        return listOf(
            brand?.ordinal,
            country,
            expMonth,
            expYear,
            funding?.ordinal,
            last4
        )
    }
}

enum class CardFundingTypeApi {
    CREDIT,
    DEBIT,
    PREPAID
}

data class CardNetworksApi(
    val available: List<CardBrandApi>,
    val preferred: String?
) {
    fun serialize(): List<Any?> {
        return listOf(
            available.map { it.ordinal },
            preferred
        )
    }
}

enum class CardPresentCaptureMethodApi {
    MANUAL_PREFERRED
}

data class CardPresentDetailsApi(
    val brand: CardBrandApi?,
    val cardholderName: String?,
    val country: String?,
    val emvAuthData: String?,
    val expMonth: Long,
    val expYear: Long,
    val funding: CardFundingTypeApi?,
    val generatedCard: String?,
    val incrementalAuthorizationStatus: IncrementalAuthorizationStatusApi?,
    val last4: String?,
    val networks: CardNetworksApi?,
    val receipt: ReceiptDetailsApi?
) {
    fun serialize(): List<Any?> {
        return listOf(
            brand?.ordinal,
            cardholderName,
            country,
            emvAuthData,
            expMonth,
            expYear,
            funding?.ordinal,
            generatedCard,
            incrementalAuthorizationStatus?.ordinal,
            last4,
            networks?.serialize(),
            receipt?.serialize()
        )
    }
}

data class CardPresentParametersApi(
    val captureMethod: CardPresentCaptureMethodApi?,
    val requestExtendedAuthorization: Boolean?,
    val requestIncrementalAuthorizationSupport: Boolean?,
    val requestedPriority: CardPresentRoutingApi?
) {
    companion object {
        fun deserialize(serialized: List<Any?>): CardPresentParametersApi {
            return CardPresentParametersApi(
                captureMethod = (serialized[0] as Int?)?.let { CardPresentCaptureMethodApi.values()[it] },
                requestExtendedAuthorization = serialized[1] as Boolean?,
                requestIncrementalAuthorizationSupport = serialized[2] as Boolean?,
                requestedPriority = (serialized[3] as Int?)?.let { CardPresentRoutingApi.values()[it] }
            )
        }
    }
}

enum class CardPresentRoutingApi {
    DOMESTIC,
    INTERNATIONAL
}

data class CartApi(
    val currency: String,
    val lineItems: List<CartLineItemApi>,
    val tax: Long,
    val total: Long
) {
    companion object {
        fun deserialize(serialized: List<Any?>): CartApi {
            return CartApi(
                currency = serialized[0] as String,
                lineItems = (serialized[1] as List<*>).map {
                    (it as List<Any?>).let { CartLineItemApi.deserialize(it) }
                },
                tax = (serialized[2] as Number).toLong(),
                total = (serialized[3] as Number).toLong()
            )
        }
    }
}

data class CartLineItemApi(
    val amount: Long,
    val description: String,
    val quantity: Long
) {
    companion object {
        fun deserialize(serialized: List<Any?>): CartLineItemApi {
            return CartLineItemApi(
                amount = (serialized[0] as Number).toLong(),
                description = serialized[1] as String,
                quantity = (serialized[2] as Number).toLong()
            )
        }
    }
}

data class ChargeApi(
    val amount: Long,
    val authorizationCode: String?,
    val calculatedStatementDescriptor: String?,
    val currency: String,
    val description: String?,
    val id: String,
    val metadata: HashMap<String, String>,
    val paymentMethodDetails: PaymentMethodDetailsApi?,
    val statementDescriptorSuffix: String?,
    val status: ChargeStatusApi
) {
    fun serialize(): List<Any?> {
        return listOf(
            amount,
            authorizationCode,
            calculatedStatementDescriptor,
            currency,
            description,
            id,
            hashMapOf(*metadata.map { (k, v) -> k to v }.toTypedArray()),
            paymentMethodDetails?.serialize(),
            statementDescriptorSuffix,
            status.ordinal
        )
    }
}

enum class ChargeStatusApi {
    SUCCEEDED,
    PENDING,
    FAILED
}

enum class ConfirmationMethodApi {
    AUTOMATIC,
    MANUAL
}

enum class ConnectionStatusApi {
    NOT_CONNECTED,
    CONNECTED,
    CONNECTING
}

enum class DeviceTypeApi {
    CHIPPER1_X,
    CHIPPER2_X,
    STRIPE_M2,
    COTS_DEVICE,
    VERIFONE_P400,
    WISE_CUBE,
    WISE_PAD3,
    WISE_PAD3S,
    WISE_POS_E,
    WISE_POS_E_DEVKIT,
    ETNA,
    STRIPE_S700,
    STRIPE_S700_DEVKIT,
    APPLE_BUILT_IN
}

sealed class DiscoveryConfigurationApi {
    companion object {
        fun deserialize(serialized: List<Any?>): DiscoveryConfigurationApi {
            return when (serialized[0]) {
                "BluetoothDiscoveryConfiguration" -> BluetoothDiscoveryConfigurationApi.deserialize(
                    serialized.drop(1)
                )
                "BluetoothProximityDiscoveryConfiguration" -> BluetoothProximityDiscoveryConfigurationApi.deserialize(
                    serialized.drop(1)
                )
                "HandoffDiscoveryConfiguration" -> HandoffDiscoveryConfigurationApi.deserialize(
                    serialized.drop(1)
                )
                "InternetDiscoveryConfiguration" -> InternetDiscoveryConfigurationApi.deserialize(
                    serialized.drop(1)
                )
                "LocalMobileDiscoveryConfiguration" -> LocalMobileDiscoveryConfigurationApi.deserialize(
                    serialized.drop(1)
                )
                "UsbDiscoveryConfiguration" -> UsbDiscoveryConfigurationApi.deserialize(
                    serialized.drop(1)
                )
                else -> throw Error()
            }
        }
    }
}

data class BluetoothDiscoveryConfigurationApi(
    val isSimulated: Boolean,
    val timeout: Long?
) : DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(serialized: List<Any?>): BluetoothDiscoveryConfigurationApi {
            return BluetoothDiscoveryConfigurationApi(
                isSimulated = serialized[0] as Boolean,
                timeout = serialized[1] as Long?
            )
        }
    }
}

data class BluetoothProximityDiscoveryConfigurationApi(
    val isSimulated: Boolean
) : DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(serialized: List<Any?>): BluetoothProximityDiscoveryConfigurationApi {
            return BluetoothProximityDiscoveryConfigurationApi(
                isSimulated = serialized[0] as Boolean
            )
        }
    }
}

class HandoffDiscoveryConfigurationApi : DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(serialized: List<Any?>): HandoffDiscoveryConfigurationApi {
            return HandoffDiscoveryConfigurationApi()
        }
    }
}

data class InternetDiscoveryConfigurationApi(
    val isSimulated: Boolean,
    val locationId: String?
) : DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(serialized: List<Any?>): InternetDiscoveryConfigurationApi {
            return InternetDiscoveryConfigurationApi(
                isSimulated = serialized[0] as Boolean,
                locationId = serialized[1] as String?
            )
        }
    }
}

data class LocalMobileDiscoveryConfigurationApi(
    val isSimulated: Boolean
) : DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(serialized: List<Any?>): LocalMobileDiscoveryConfigurationApi {
            return LocalMobileDiscoveryConfigurationApi(
                isSimulated = serialized[0] as Boolean
            )
        }
    }
}

data class UsbDiscoveryConfigurationApi(
    val isSimulated: Boolean,
    val timeout: Long?
) : DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(serialized: List<Any?>): UsbDiscoveryConfigurationApi {
            return UsbDiscoveryConfigurationApi(
                isSimulated = serialized[0] as Boolean,
                timeout = serialized[1] as Long?
            )
        }
    }
}

enum class IncrementalAuthorizationStatusApi {
    NOT_SUPPORTED,
    SUPPORTED
}

data class LocationApi(
    val address: AddressApi?,
    val displayName: String?,
    val id: String?,
    val livemode: Boolean?,
    val metadata: HashMap<String, String>
) {
    fun serialize(): List<Any?> {
        return listOf(
            address?.serialize(),
            displayName,
            id,
            livemode,
            hashMapOf(*metadata.map { (k, v) -> k to v }.toTypedArray())
        )
    }
}

enum class LocationStatusApi {
    SET,
    NOT_SET
}

data class PaymentIntentApi(
    val amount: Double,
    val amountCapturable: Double?,
    val amountDetails: AmountDetailsApi?,
    val amountReceived: Double?,
    val amountTip: Double?,
    val applicationFeeAmount: Double?,
    val applicationId: String?,
    val canceledAt: Long?,
    val cancellationReason: String?,
    val captureMethod: CaptureMethodApi,
    val charges: List<ChargeApi>,
    val clientSecret: String?,
    val confirmationMethod: ConfirmationMethodApi?,
    val created: Long,
    val currency: String,
    val customerId: String?,
    val description: String?,
    val id: String,
    val invoiceId: String?,
    val metadata: HashMap<String, String>,
    val onBehalfOf: String?,
    val paymentMethod: PaymentMethodApi?,
    val paymentMethodId: String?,
    val receiptEmail: String?,
    val reviewId: String?,
    val setupFutureUsage: PaymentIntentUsageApi?,
    val statementDescriptor: String?,
    val statementDescriptorSuffix: String?,
    val status: PaymentIntentStatusApi,
    val transferGroup: String?
) {
    fun serialize(): List<Any?> {
        return listOf(
            amount,
            amountCapturable,
            amountDetails?.serialize(),
            amountReceived,
            amountTip,
            applicationFeeAmount,
            applicationId,
            canceledAt,
            cancellationReason,
            captureMethod.ordinal,
            charges.map { it.serialize() },
            clientSecret,
            confirmationMethod?.ordinal,
            created,
            currency,
            customerId,
            description,
            id,
            invoiceId,
            hashMapOf(*metadata.map { (k, v) -> k to v }.toTypedArray()),
            onBehalfOf,
            paymentMethod?.serialize(),
            paymentMethodId,
            receiptEmail,
            reviewId,
            setupFutureUsage?.ordinal,
            statementDescriptor,
            statementDescriptorSuffix,
            status.ordinal,
            transferGroup
        )
    }
}

data class PaymentIntentParametersApi(
    val amount: Long,
    val applicationFeeAmount: Long?,
    val captureMethod: CaptureMethodApi,
    val currency: String,
    val customerId: String?,
    val description: String?,
    val metadata: HashMap<String, String>,
    val onBehalfOf: String?,
    val paymentMethodOptionsParameters: PaymentMethodOptionsParametersApi?,
    val paymentMethodTypes: List<PaymentMethodTypeApi>,
    val receiptEmail: String?,
    val setupFutureUsage: PaymentIntentUsageApi?,
    val statementDescriptor: String?,
    val statementDescriptorSuffix: String?,
    val transferDataDestination: String?,
    val transferGroup: String?
) {
    companion object {
        fun deserialize(serialized: List<Any?>): PaymentIntentParametersApi {
            return PaymentIntentParametersApi(
                amount = (serialized[0] as Number).toLong(),
                applicationFeeAmount = (serialized[1] as? Number)?.toLong(),
                captureMethod = (serialized[2] as Int).let { CaptureMethodApi.values()[it] },
                currency = serialized[3] as String,
                customerId = serialized[4] as String?,
                description = serialized[5] as String?,
                metadata = hashMapOf(
                    *(serialized[6] as HashMap<*, *>).map { (k, v) -> k as String to v as String }.toTypedArray()
                ),
                onBehalfOf = serialized[7] as String?,
                paymentMethodOptionsParameters = (serialized[8] as List<Any?>?)?.let {
                    PaymentMethodOptionsParametersApi.deserialize(it)
                },
                paymentMethodTypes = (serialized[9] as List<*>).map {
                    (it as Int).let { PaymentMethodTypeApi.values()[it] }
                },
                receiptEmail = serialized[10] as String?,
                setupFutureUsage = (serialized[11] as Int?)?.let { PaymentIntentUsageApi.values()[it] },
                statementDescriptor = serialized[12] as String?,
                statementDescriptorSuffix = serialized[13] as String?,
                transferDataDestination = serialized[14] as String?,
                transferGroup = serialized[15] as String?
            )
        }
    }
}

enum class PaymentIntentStatusApi {
    CANCELED,
    PROCESSING,
    REQUIRES_CAPTURE,
    REQUIRES_CONFIRMATION,
    REQUIRES_PAYMENT_METHOD,
    REQUIRES_ACTION,
    SUCCEEDED
}

enum class PaymentIntentUsageApi {
    ON_SESSION,
    OFF_SESSION
}

data class PaymentMethodApi(
    val card: CardDetailsApi?,
    val cardPresent: CardPresentDetailsApi?,
    val customerId: String?,
    val id: String,
    val interacPresent: CardPresentDetailsApi?,
    val metadata: HashMap<String, String>
) {
    fun serialize(): List<Any?> {
        return listOf(
            card?.serialize(),
            cardPresent?.serialize(),
            customerId,
            id,
            interacPresent?.serialize(),
            hashMapOf(*metadata.map { (k, v) -> k to v }.toTypedArray())
        )
    }
}

data class PaymentMethodDetailsApi(
    val cardPresent: CardPresentDetailsApi?,
    val interacPresent: CardPresentDetailsApi?
) {
    fun serialize(): List<Any?> {
        return listOf(
            cardPresent?.serialize(),
            interacPresent?.serialize()
        )
    }
}

data class PaymentMethodOptionsParametersApi(
    val cardPresentParameters: CardPresentParametersApi
) {
    companion object {
        fun deserialize(serialized: List<Any?>): PaymentMethodOptionsParametersApi {
            return PaymentMethodOptionsParametersApi(
                cardPresentParameters = (serialized[0] as List<Any?>).let {
                    CardPresentParametersApi.deserialize(it)
                }
            )
        }
    }
}

enum class PaymentMethodTypeApi {
    CARD_PRESENT,
    CARD,
    INTERACT_PRESENT
}

enum class PaymentStatusApi {
    NOT_READY,
    READY,
    WAITING_FOR_INPUT,
    PROCESSING
}

data class ReaderApi(
    val availableUpdate: Boolean,
    val batteryLevel: Double,
    val deviceType: DeviceTypeApi?,
    val label: String?,
    val location: LocationApi?,
    val locationId: String?,
    val locationStatus: LocationStatusApi?,
    val serialNumber: String,
    val simulated: Boolean
) {
    fun serialize(): List<Any?> {
        return listOf(
            availableUpdate,
            batteryLevel,
            deviceType?.ordinal,
            label,
            location?.serialize(),
            locationId,
            locationStatus?.ordinal,
            serialNumber,
            simulated
        )
    }
}

enum class ReaderDisplayMessageApi {
    CHECK_MOBILE_DEVICE,
    RETRY_CARD,
    INSERT_CARD,
    INSERT_OR_SWIPE_CARD,
    SWIPE_CARD,
    REMOVE_CARD,
    MULTIPLE_CONTACTLESS_CARDS_DETECTED,
    TRY_ANOTHER_READ_METHOD,
    TRY_ANOTHER_CARD,
    CARD_REMOVED_TOO_EARLY
}

enum class ReaderEventApi {
    CARD_INSERTED,
    CARD_REMOVED
}

enum class ReaderInputOptionApi {
    INSERT_CARD,
    SWIPE_CARD,
    TAP_CARD,
    MANUAL_ENTRY
}

data class ReaderSoftwareUpdateApi(
    val components: List<UpdateComponentApi>,
    val keyProfileName: String?,
    val onlyInstallRequiredUpdates: Boolean,
    val requiredAt: Long,
    val settingsVersion: String?,
    val timeEstimate: UpdateTimeEstimateApi,
    val version: String
) {
    fun serialize(): List<Any?> {
        return listOf(
            components.map { it.ordinal },
            keyProfileName,
            onlyInstallRequiredUpdates,
            requiredAt,
            settingsVersion,
            timeEstimate.ordinal,
            version
        )
    }
}

data class ReceiptDetailsApi(
    val accountType: String?,
    val applicationCryptogram: String?,
    val applicationPreferredName: String?,
    val authorizationCode: String?,
    val authorizationResponseCode: String,
    val dedicatedFileName: String?,
    val terminalVerificationResults: String?,
    val transactionStatusInformation: String?
) {
    fun serialize(): List<Any?> {
        return listOf(
            accountType,
            applicationCryptogram,
            applicationPreferredName,
            authorizationCode,
            authorizationResponseCode,
            dedicatedFileName,
            terminalVerificationResults,
            transactionStatusInformation
        )
    }
}

data class RefundApi(
    val amount: Long,
    val chargeId: String,
    val created: Long,
    val currency: String,
    val failureReason: String?,
    val id: String,
    val metadata: HashMap<String, String>,
    val paymentMethodDetails: PaymentMethodDetailsApi?,
    val reason: String?,
    val status: RefundStatusApi?
) {
    fun serialize(): List<Any?> {
        return listOf(
            amount,
            chargeId,
            created,
            currency,
            failureReason,
            id,
            hashMapOf(*metadata.map { (k, v) -> k to v }.toTypedArray()),
            paymentMethodDetails?.serialize(),
            reason,
            status?.ordinal
        )
    }
}

enum class RefundStatusApi {
    SUCCEEDED,
    PENDING,
    FAILED
}

data class SetupAttemptApi(
    val applicationId: String?,
    val created: Long,
    val customerId: String?,
    val id: String,
    val onBehalfOf: String?,
    val paymentMethodDetails: SetupAttemptPaymentMethodDetailsApi?,
    val paymentMethodId: String?,
    val setupIntentId: String,
    val status: SetupAttemptStatusApi
) {
    fun serialize(): List<Any?> {
        return listOf(
            applicationId,
            created,
            customerId,
            id,
            onBehalfOf,
            paymentMethodDetails?.serialize(),
            paymentMethodId,
            setupIntentId,
            status.ordinal
        )
    }
}

data class SetupAttemptCardPresentDetailsApi(
    val emvAuthData: String,
    val generatedCard: String
) {
    fun serialize(): List<Any?> {
        return listOf(
            emvAuthData,
            generatedCard
        )
    }
}

data class SetupAttemptPaymentMethodDetailsApi(
    val cardPresent: SetupAttemptCardPresentDetailsApi?,
    val interacPresent: SetupAttemptCardPresentDetailsApi?
) {
    fun serialize(): List<Any?> {
        return listOf(
            cardPresent?.serialize(),
            interacPresent?.serialize()
        )
    }
}

enum class SetupAttemptStatusApi {
    REQUIRES_CONFIRMATION,
    REQUIRES_ACTION,
    PROCESSING,
    SUCCEEDED,
    FAILED,
    ABANDONED
}

data class SetupIntentApi(
    val created: Long,
    val customerId: String?,
    val id: String,
    val latestAttempt: SetupAttemptApi?,
    val metadata: HashMap<String, String>,
    val status: SetupIntentStatusApi,
    val usage: SetupIntentUsageApi
) {
    fun serialize(): List<Any?> {
        return listOf(
            created,
            customerId,
            id,
            latestAttempt?.serialize(),
            hashMapOf(*metadata.map { (k, v) -> k to v }.toTypedArray()),
            status.ordinal,
            usage.ordinal
        )
    }
}

enum class SetupIntentStatusApi {
    REQUIRES_PAYMENT_METHOD,
    REQUIRES_CONFIRMATION,
    REQUIRES_ACTION,
    PROCESSING,
    SUCCEEDED,
    CANCELLED
}

enum class SetupIntentUsageApi {
    ON_SESSION,
    OFF_SESSION
}

enum class SimulateReaderUpdateApi {
    AVAILABLE,
    NONE,
    REQUIRED,
    RANDOM
}

data class SimulatedCardApi(
    val testCardNumber: String?,
    val type: SimulatedCardTypeApi?
) {
    companion object {
        fun deserialize(serialized: List<Any?>): SimulatedCardApi {
            return SimulatedCardApi(
                testCardNumber = serialized[0] as String?,
                type = (serialized[1] as Int?)?.let { SimulatedCardTypeApi.values()[it] }
            )
        }
    }
}

enum class SimulatedCardTypeApi {
    VISA,
    VISA_DEBIT,
    VISA_US_COMMON_DEBIT,
    MASTERCARD,
    MASTER_DEBIT,
    MASTERCARD_PREPAID,
    AMEX,
    AMEX2,
    DISCOVER,
    DISCOVER2,
    DINERS,
    DINERS14_DIGIT,
    JBC,
    UNION_PAY,
    INTERAC,
    EFTPOS_AU_DEBIT,
    EFTPOS_AU_VISA_DEBIT,
    EFTPOS_AU_DEBIT_MASTERCARD,
    CHARGE_DECLINED,
    CHARGE_DECLINED_INSUFFICIENT_FUNDS,
    CHARGE_DECLINED_LOST_CARD,
    CHARGE_DECLINED_STOLEN_CARD,
    CHARGE_DECLINED_EXPIRED_CARD,
    CHARGE_DECLINED_PROCESSING_ERROR,
    ONLINE_PIN_CVM,
    ONLINE_PIN_SCA_RETRY,
    OFFLINE_PIN_CVM,
    OFFLINE_PIN_SCA_RETRY
}

data class SimulatorConfigurationApi(
    val simulatedCard: SimulatedCardApi,
    val simulatedTipAmount: Long?,
    val update: SimulateReaderUpdateApi
) {
    companion object {
        fun deserialize(serialized: List<Any?>): SimulatorConfigurationApi {
            return SimulatorConfigurationApi(
                simulatedCard = (serialized[0] as List<Any?>).let {
                    SimulatedCardApi.deserialize(
                        it
                    )
                },
                simulatedTipAmount = (serialized[1] as? Number)?.toLong(),
                update = (serialized[2] as Int).let { SimulateReaderUpdateApi.values()[it] }
            )
        }
    }
}

data class TerminalExceptionApi(
    val apiError: Any?,
    val code: TerminalExceptionCodeApi,
    val message: String,
    val paymentIntent: PaymentIntentApi?,
    val stackTrace: String?
) {
    fun serialize(): List<Any?> {
        return listOf(
            apiError,
            code.ordinal,
            message,
            paymentIntent?.serialize(),
            stackTrace
        )
    }
}

enum class TerminalExceptionCodeApi {
    UNKNOWN,
    READER_NOT_RECOVERED,
    PAYMENT_INTENT_NOT_RECOVERED,
    SETUP_INTENT_NOT_RECOVERED,
    CANCEL_FAILED,
    NOT_CONNECTED_TO_READER,
    ALREADY_CONNECTED_TO_READER,
    BLUETOOTH_DISABLED,
    BLUETOOTH_PERMISSION_DENIED,
    CONFIRM_INVALID_PAYMENT_INTENT,
    INVALID_CLIENT_SECRET,
    INVALID_READER_FOR_UPDATE,
    UNSUPPORTED_OPERATION,
    UNEXPECTED_OPERATION,
    UNSUPPORTED_SDK,
    FEATURE_NOT_AVAILABLE_WITH_CONNECTED_READER,
    USB_PERMISSION_DENIED,
    USB_DISCOVERY_TIMED_OUT,
    INVALID_PARAMETER,
    INVALID_REQUIRED_PARAMETER,
    INVALID_TIP_PARAMETER,
    LOCAL_MOBILE_UNSUPPORTED_DEVICE,
    LOCAL_MOBILE_UNSUPPORTED_OPERATING_SYSTEM_VERSION,
    LOCAL_MOBILE_DEVICE_TAMPERED,
    LOCAL_MOBILE_DEBUG_NOT_SUPPORTED,
    OFFLINE_MODE_UNSUPPORTED_OPERATING_SYSTEM_VERSION,
    CANCELED,
    LOCATION_SERVICES_DISABLED,
    BLUETOOTH_SCAN_TIMED_OUT,
    BLUETOOTH_LOW_ENERGY_UNSUPPORTED,
    READER_SOFTWARE_UPDATE_FAILED_BATTERY_LOW,
    READER_SOFTWARE_UPDATE_FAILED_INTERRUPTED,
    READER_SOFTWARE_UPDATE_FAILED_EXPIRED_UPDATE,
    BLUETOOTH_CONNECTION_FAILED_BATTERY_CRITICALLY_LOW,
    CARD_INSERT_NOT_READ,
    CARD_SWIPE_NOT_READ,
    CARD_READ_TIMED_OUT,
    CARD_REMOVED,
    CUSTOMER_CONSENT_REQUIRED,
    CARD_LEFT_IN_READER,
    FEATURE_NOT_ENABLED_ON_ACCOUNT,
    PASSCODE_NOT_ENABLED,
    COMMAND_NOT_ALLOWED_DURING_CALL,
    INVALID_AMOUNT,
    INVALID_CURRENCY,
    APPLE_BUILT_IN_READER_T_O_S_ACCEPTANCE_REQUIRESI_CLOUD_SIGN_IN,
    APPLE_BUILT_IN_READER_T_O_S_ACCEPTANCE_CANCELED,
    APPLE_BUILT_IN_READER_FAILED_TO_PREPARE,
    APPLE_BUILT_IN_READER_DEVICE_BANNED,
    APPLE_BUILT_IN_READER_T_O_S_NOT_YET_ACCEPTED,
    APPLE_BUILT_IN_READER_T_O_S_ACCEPTANCE_FAILED,
    APPLE_BUILT_IN_READER_MERCHANT_BLOCKED,
    APPLE_BUILT_IN_READER_INVALID_MERCHANT,
    READER_BUSY,
    INCOMPATIBLE_READER,
    READER_COMMUNICATION_ERROR,
    UNKNOWN_READER_IP_ADDRESS,
    INTERNET_CONNECT_TIME_OUT,
    CONNECT_FAILED_READER_IS_IN_USE,
    READER_NOT_ACCESSIBLE_IN_BACKGROUND,
    BLUETOOTH_ERROR,
    BLUETOOTH_CONNECT_TIMED_OUT,
    BLUETOOTH_DISCONNECTED,
    BLUETOOTH_PEER_REMOVED_PAIRING_INFORMATION,
    BLUETOOTH_ALREADY_PAIRED_WITH_ANOTHER_DEVICE,
    BLUETOOTH_RECONNECT_STARTED,
    USB_DISCONNECTED,
    USB_RECONNECT_STARTED,
    READER_CONNECTED_TO_ANOTHER_DEVICE,
    READER_SOFTWARE_UPDATE_FAILED,
    READER_SOFTWARE_UPDATE_FAILED_READER_ERROR,
    READER_SOFTWARE_UPDATE_FAILED_SERVER_ERROR,
    NFC_DISABLED,
    UNSUPPORTED_READER_VERSION,
    UNEXPECTED_SDK_ERROR,
    UNEXPECTED_READER_ERROR,
    ENCRYPTION_KEY_FAILURE,
    ENCRYPTION_KEY_STILL_INITIALIZING,
    DECLINED_BY_STRIPE_API,
    DECLINED_BY_READER,
    NOT_CONNECTED_TO_INTERNET,
    REQUEST_TIMED_OUT,
    STRIPE_API_CONNECTION_ERROR,
    STRIPE_API_ERROR,
    STRIPE_API_RESPONSE_DECODING_ERROR,
    INTERNAL_NETWORK_ERROR,
    CONNECTION_TOKEN_PROVIDER_ERROR,
    SESSION_EXPIRED,
    UNSUPPORTED_MOBILE_DEVICE_CONFIGURATION,
    COMMAND_NOT_ALLOWED,
    AMOUNT_EXCEEDS_MAX_OFFLINE_AMOUNT,
    OFFLINE_PAYMENTS_DATABASE_TOO_LARGE,
    READER_CONNECTION_NOT_AVAILABLE_OFFLINE,
    READER_CONNECTION_OFFLINE_LOCATION_MISMATCH,
    READER_CONNECTION_OFFLINE_NEEDS_UPDATE,
    LOCATION_CONNECTION_NOT_AVAILABLE_OFFLINE,
    NO_LAST_SEEN_ACCOUNT,
    INVALID_OFFLINE_CURRENCY,
    REFUND_FAILED,
    CARD_SWIPE_NOT_AVAILABLE,
    INTERAC_NOT_SUPPORTED_OFFLINE,
    ONLINE_PIN_NOT_SUPPORTED_OFFLINE,
    OFFLINE_AND_CARD_EXPIRED,
    OFFLINE_TRANSACTION_DECLINED,
    OFFLINE_COLLECT_AND_CONFIRM_MISMATCH,
    FORWARDING_TEST_MODE_PAYMENT_IN_LIVE_MODE,
    FORWARDING_LIVE_MODE_PAYMENT_IN_TEST_MODE,
    OFFLINE_PAYMENT_INTENT_NOT_FOUND,
    UPDATE_PAYMENT_INTENT_UNAVAILABLE_WHILE_OFFLINE,
    UPDATE_PAYMENT_INTENT_UNAVAILABLE_WHILE_OFFLINE_MODE_ENABLED,
    MISSING_EMV_DATA,
    CONNECTION_TOKEN_PROVIDER_ERROR_WHILE_FORWARDING,
    CONNECTION_TOKEN_PROVIDER_TIMED_OUT,
    ACCOUNT_ID_MISMATCH_WHILE_FORWARDING,
    OFFLINE_BEHAVIOR_FORCE_OFFLINE_WITH_FEATURE_DISABLED,
    NOT_CONNECTED_TO_INTERNET_AND_OFFLINE_BEHAVIOR_REQUIRE_ONLINE,
    TEST_CARD_IN_LIVE_MODE,
    COLLECT_INPUTS_APPLICATION_ERROR,
    COLLECT_INPUTS_TIMED_OUT,
    COLLECT_INPUTS_UNSUPPORTED
}

data class TipApi(
    val amount: Long?
) {
    fun serialize(): List<Any?> {
        return listOf(
            amount
        )
    }
}

data class TippingConfigurationApi(
    val eligibleAmount: Long
) {
    companion object {
        fun deserialize(serialized: List<Any?>): TippingConfigurationApi {
            return TippingConfigurationApi(
                eligibleAmount = (serialized[0] as Number).toLong()
            )
        }
    }
}

enum class UpdateComponentApi {
    INCREMENTAL,
    FIRMWARE,
    CONFIG,
    KEYS
}

enum class UpdateTimeEstimateApi {
    LESS_THAN_ONE_MINUTE,
    ONE_TO_TWO_MINUTES,
    TWO_TO_FIVE_MINUTES,
    FIVE_TO_FIFTEEN_MINUTES
}

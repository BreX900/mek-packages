// GENERATED CODE - DO NOT MODIFY BY HAND

package mek.stripeterminal.api

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class PlatformException(
    val code: String,
    message: String?,
    val details: Any?,
): RuntimeException(message ?: code)


class Result<T>(
    private val result: MethodChannel.Result,
    private val serializer: (data: T) -> Any?,
) {
    fun success(
        data: T,
    ) = result.success(serializer(data))

    fun error(
        code: String,
        message: String?,
        details: Any? = null,
    ) {
        result.error(code, message, details)
    }
}

class ControllerSink<T>(
    private val sink: EventChannel.EventSink,
    private val serializer: (data: T) -> Any?,
) {
    fun success(
        data: T,
    ) = sink.success(serializer(data))

    fun error(
        code: String,
        message: String?,
        details: Any?,
    ) = sink.error(code, message, details)

    fun endOfStream() = sink.endOfStream()
}

interface StripeTerminalPlatformApi {
    fun onInit(
        shouldPrintLogs: Boolean,
    )

    fun onClearCachedCredentials()

    fun onGetConnectionStatus(): ConnectionStatusApi

    fun onSupportsReadersOfType(
        deviceType: DeviceTypeApi,
        discoveryConfiguration: DiscoveryConfigurationApi,
    ): Boolean

    fun onConnectBluetoothReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean,
    )

    fun onConnectHandoffReader(
        result: Result<ReaderApi>,
        serialNumber: String,
    )

    fun onConnectInternetReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        failIfInUse: Boolean,
    )

    fun onConnectMobileReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
    )

    fun onConnectUsbReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean,
    )

    fun onGetConnectedReader(): ReaderApi?

    fun onCancelReaderReconnection(
        result: Result<Unit>,
    )

    fun onListLocations(
        result: Result<List<LocationApi>>,
        endingBefore: String?,
        limit: Long?,
        startingAfter: String?,
    )

    fun onInstallAvailableUpdate()

    fun onCancelReaderUpdate(
        result: Result<Unit>,
    )

    fun onDisconnectReader(
        result: Result<Unit>,
    )

    fun onGetPaymentStatus(): PaymentStatusApi

    fun onCreatePaymentIntent(
        result: Result<PaymentIntentApi>,
        parameters: PaymentIntentParametersApi,
    )

    fun onRetrievePaymentIntent(
        result: Result<PaymentIntentApi>,
        clientSecret: String,
    )

    fun onStartCollectPaymentMethod(
        result: Result<PaymentIntentApi>,
        operationId: Long,
        paymentIntentId: String,
        skipTipping: Boolean,
    )

    fun onStopCollectPaymentMethod(
        result: Result<Unit>,
        operationId: Long,
    )

    fun onConfirmPaymentIntent(
        result: Result<PaymentIntentApi>,
        paymentIntentId: String,
    )

    fun onCancelPaymentIntent(
        result: Result<PaymentIntentApi>,
        paymentIntentId: String,
    )

    fun onCreateSetupIntent(
        result: Result<SetupIntentApi>,
        customerId: String?,
        metadata: HashMap<String, String>?,
        onBehalfOf: String?,
        description: String?,
        usage: SetupIntentUsageApi?,
    )

    fun onRetrieveSetupIntent(
        result: Result<SetupIntentApi>,
        clientSecret: String,
    )

    fun onStartCollectSetupIntentPaymentMethod(
        result: Result<SetupIntentApi>,
        operationId: Long,
        setupIntentId: String,
        customerConsentCollected: Boolean,
        isCustomerCancellationEnabled: Boolean?,
    )

    fun onStopCollectSetupIntentPaymentMethod(
        result: Result<Unit>,
        operationId: Long,
    )

    fun onConfirmSetupIntent(
        result: Result<SetupIntentApi>,
        setupIntentId: String,
    )

    fun onCancelSetupIntent(
        result: Result<SetupIntentApi>,
        setupIntentId: String,
    )

    fun onStartCollectRefundPaymentMethod(
        result: Result<Unit>,
        operationId: Long,
        chargeId: String,
        amount: Long,
        currency: String,
        metadata: HashMap<String, String>?,
        reverseTransfer: Boolean?,
        refundApplicationFee: Boolean?,
        isCustomerCancellationEnabled: Boolean?,
    )

    fun onStopCollectRefundPaymentMethod(
        result: Result<Unit>,
        operationId: Long,
    )

    fun onConfirmRefund(
        result: Result<RefundApi>,
    )

    fun onSetReaderDisplay(
        result: Result<Unit>,
        cart: CartApi,
    )

    fun onClearReaderDisplay(
        result: Result<Unit>,
    )

    private fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
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
                    val res = onSupportsReadersOfType((args[0] as Int).let { DeviceTypeApi.values()[it] }, (args[1] as List<Any?>).let { DiscoveryConfigurationApi.deserialize(it) })
                    result.success(res)
                }
                "connectBluetoothReader" -> {
                    val res = Result<ReaderApi>(result) { it.serialize() }
                    onConnectBluetoothReader(res, args[0] as String, args[1] as String, args[2] as Boolean)
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
                    onConnectUsbReader(res, args[0] as String, args[1] as String, args[2] as Boolean)
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
                    val res = Result<List<LocationApi>>(result) { it.map { it.serialize()}  }
                    onListLocations(res, args[0] as String?, (args[1] as? Number)?.toLong(), args[2] as String?)
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
                "getPaymentStatus" -> {
                    val res = onGetPaymentStatus()
                    result.success(res.ordinal)
                }
                "createPaymentIntent" -> {
                    val res = Result<PaymentIntentApi>(result) { it.serialize() }
                    onCreatePaymentIntent(res, (args[0] as List<Any?>).let { PaymentIntentParametersApi.deserialize(it) })
                }
                "retrievePaymentIntent" -> {
                    val res = Result<PaymentIntentApi>(result) { it.serialize() }
                    onRetrievePaymentIntent(res, args[0] as String)
                }
                "startCollectPaymentMethod" -> {
                    val res = Result<PaymentIntentApi>(result) { it.serialize() }
                    onStartCollectPaymentMethod(res, (args[0] as Number).toLong(), args[1] as String, args[2] as Boolean)
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
                    onCreateSetupIntent(res, args[0] as String?, args[1]?.let { hashMapOf(*(it as HashMap<*, *>).map { (k, v) -> k as String to v as String }.toTypedArray()) }, args[2] as String?, args[3] as String?, (args[4] as Int?)?.let { SetupIntentUsageApi.values()[it] })
                }
                "retrieveSetupIntent" -> {
                    val res = Result<SetupIntentApi>(result) { it.serialize() }
                    onRetrieveSetupIntent(res, args[0] as String)
                }
                "startCollectSetupIntentPaymentMethod" -> {
                    val res = Result<SetupIntentApi>(result) { it.serialize() }
                    onStartCollectSetupIntentPaymentMethod(res, (args[0] as Number).toLong(), args[1] as String, args[2] as Boolean, args[3] as Boolean?)
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
                    onStartCollectRefundPaymentMethod(res, (args[0] as Number).toLong(), args[1] as String, (args[2] as Number).toLong(), args[3] as String, args[4]?.let { hashMapOf(*(it as HashMap<*, *>).map { (k, v) -> k as String to v as String }.toTypedArray()) }, args[5] as Boolean?, args[6] as Boolean?, args[7] as Boolean?)
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
        } catch (e: PlatformException) {
            result.error(e.code, e.message, e.details)
        }
    }

    companion object {
        private lateinit var channel: MethodChannel
        private lateinit var coroutineScope: CoroutineScope

        fun setHandler(
            binaryMessenger: BinaryMessenger,
            api: StripeTerminalPlatformApi,
            coroutineScope: CoroutineScope? = null,
        ) {
            channel = MethodChannel(binaryMessenger, "StripeTerminalPlatform")
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
    binaryMessenger: BinaryMessenger,
) {
    private val channel: EventChannel = EventChannel(binaryMessenger, "StripeTerminalPlatform#discoverReaders")

    fun setHandler(
        onListen: (sink: ControllerSink<List<ReaderApi>>, configuration: DiscoveryConfigurationApi) -> Unit,
        onCancel: () -> Unit,
    ) {
        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as List<Any?>
                val sink = ControllerSink<List<ReaderApi>>(events) {it.map { it.serialize()} }
                onListen(sink, (args[0] as List<Any?>).let { DiscoveryConfigurationApi.deserialize(it) })
            }
            override fun onCancel(arguments: Any?) = onCancel()
        })
    }

    fun removeHandler() = channel.setStreamHandler(null)
}

class StripeTerminalHandlersApi(
    binaryMessenger: BinaryMessenger,
) {
    private val channel: MethodChannel = MethodChannel(binaryMessenger, "StripeTerminalHandlers")

    fun requestConnectionToken(
        onError: (code: String, message: String?, details: Any?) -> Unit,
        onSuccess: (data: String) -> Unit,
    ) {
        channel.invokeMethod(
            "_onRequestConnectionToken",
            listOf<Any?>(),
            object : MethodChannel.Result {
                override fun notImplemented() {}
                override fun error(code: String, message: String?, details: Any?) = 
                    onError(code, message, details)
                override fun success(result: Any?) =
                    onSuccess(result as String)
            }
        )
    }

    fun unexpectedReaderDisconnect(
        reader: ReaderApi,
    ) {
        channel.invokeMethod("_onUnexpectedReaderDisconnect", listOf<Any?>(reader.serialize()))
    }

    fun connectionStatusChange(
        connectionStatus: ConnectionStatusApi,
    ) {
        channel.invokeMethod("_onConnectionStatusChange", listOf<Any?>(connectionStatus.ordinal))
    }

    fun paymentStatusChange(
        paymentStatus: PaymentStatusApi,
    ) {
        channel.invokeMethod("_onPaymentStatusChange", listOf<Any?>(paymentStatus.ordinal))
    }

    fun readerReportEvent(
        event: ReaderEventApi,
    ) {
        channel.invokeMethod("_onReaderReportEvent", listOf<Any?>(event.ordinal))
    }

    fun readerRequestDisplayMessage(
        message: ReaderDisplayMessageApi,
    ) {
        channel.invokeMethod("_onReaderRequestDisplayMessage", listOf<Any?>(message.ordinal))
    }

    fun readerRequestInput(
        options: List<ReaderInputOptionApi>,
    ) {
        channel.invokeMethod("_onReaderRequestInput", listOf<Any?>(options.map { it.ordinal} ))
    }

    fun readerBatteryLevelUpdate(
        batteryLevel: Double,
        batteryStatus: BatteryStatusApi?,
        isCharging: Boolean,
    ) {
        channel.invokeMethod("_onReaderBatteryLevelUpdate", listOf<Any?>(batteryLevel, batteryStatus?.ordinal, isCharging))
    }

    fun readerReportLowBatteryWarning() {
        channel.invokeMethod("_onReaderReportLowBatteryWarning", listOf<Any?>())
    }

    fun readerReportAvailableUpdate(
        update: ReaderSoftwareUpdateApi,
    ) {
        channel.invokeMethod("_onReaderReportAvailableUpdate", listOf<Any?>(update.serialize()))
    }

    fun readerStartInstallingUpdate(
        update: ReaderSoftwareUpdateApi,
    ) {
        channel.invokeMethod("_onReaderStartInstallingUpdate", listOf<Any?>(update.serialize()))
    }

    fun readerReportSoftwareUpdateProgress(
        progress: Double,
    ) {
        channel.invokeMethod("_onReaderReportSoftwareUpdateProgress", listOf<Any?>(progress))
    }

    fun readerFinishInstallingUpdate(
        update: ReaderSoftwareUpdateApi?,
        exception: TerminalExceptionApi?,
    ) {
        channel.invokeMethod("_onReaderFinishInstallingUpdate", listOf<Any?>(update?.serialize(), exception?.serialize()))
    }

    fun readerReconnectFailed(
        reader: ReaderApi,
    ) {
        channel.invokeMethod("_onReaderReconnectFailed", listOf<Any?>(reader.serialize()))
    }

    fun readerReconnectStarted(
        reader: ReaderApi,
    ) {
        channel.invokeMethod("_onReaderReconnectStarted", listOf<Any?>(reader.serialize()))
    }

    fun readerReconnectSucceeded(
        reader: ReaderApi,
    ) {
        channel.invokeMethod("_onReaderReconnectSucceeded", listOf<Any?>(reader.serialize()))
    }
}

data class AddressApi(
    val city: String?,
    val country: String?,
    val line1: String?,
    val line2: String?,
    val postalCode: String?,
    val state: String?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            city,
            country,
            line1,
            line2,
            postalCode,
            state,
        )
    }
}

enum class BatteryStatusApi {
    CRITICAL, LOW, NOMINAL;
}

enum class CaptureMethodApi {
    AUTOMATIC, MANUAL;
}

enum class CardBrandApi {
    AMEX, DINERS_CLUB, DISCOVER, JCB, MASTER_CARD, UNION_PAY, VISA, INTERAC, EFTPOS_AU;
}

enum class CardFundingTypeApi {
    CREDIT, DEBIT, PREPAID;
}

data class CardNetworksApi(
    val available: List<CardBrandApi>,
    val preferred: String?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            available.map { it.ordinal} ,
            preferred,
        )
    }
}

data class CardPresentDetailsApi(
    val brand: CardBrandApi?,
    val country: String?,
    val expMonth: Long,
    val expYear: Long,
    val funding: CardFundingTypeApi?,
    val last4: String?,
    val cardholderName: String?,
    val emvAuthData: String?,
    val generatedCard: String?,
    val incrementalAuthorizationStatus: IncrementalAuthorizationStatusApi?,
    val networks: CardNetworksApi?,
    val receipt: ReceiptDetailsApi?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            brand?.ordinal,
            country,
            expMonth,
            expYear,
            funding?.ordinal,
            last4,
            cardholderName,
            emvAuthData,
            generatedCard,
            incrementalAuthorizationStatus?.ordinal,
            networks?.serialize(),
            receipt?.serialize(),
        )
    }
}

data class CartApi(
    val currency: String,
    val tax: Long,
    val total: Long,
    val lineItems: List<CartLineItemApi>,
) {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): CartApi {
            return CartApi(
                currency = serialized[0] as String,
                tax = (serialized[1] as Number).toLong(),
                total = (serialized[2] as Number).toLong(),
                lineItems = (serialized[3] as List<*>).map { (it as List<Any?>).let { CartLineItemApi.deserialize(it) } },
            )
        }
    }
}

data class CartLineItemApi(
    val description: String,
    val quantity: Long,
    val amount: Long,
) {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): CartLineItemApi {
            return CartLineItemApi(
                description = serialized[0] as String,
                quantity = (serialized[1] as Number).toLong(),
                amount = (serialized[2] as Number).toLong(),
            )
        }
    }
}

enum class ConnectionStatusApi {
    NOT_CONNECTED, CONNECTED, CONNECTING;
}

enum class DeviceTypeApi {
    CHIPPER1_X, CHIPPER2_X, STRIPE_M2, COTS_DEVICE, VERIFONE_P400, WISE_CUBE, WISE_PAD3, WISE_PAD3S, WISE_POS_E, WISE_POS_E_DEVKIT, ETNA, STRIPE_S700, STRIPE_S700_DEVKIT, APPLE_BUILT_IN;
}

sealed class DiscoveryConfigurationApi {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): DiscoveryConfigurationApi {
            return when (serialized[0]) {
                "BluetoothDiscoveryConfiguration" -> BluetoothDiscoveryConfigurationApi.deserialize(serialized.drop(1))
                "BluetoothProximityDiscoveryConfiguration" -> BluetoothProximityDiscoveryConfigurationApi.deserialize(serialized.drop(1))
                "HandoffDiscoveryConfiguration" -> HandoffDiscoveryConfigurationApi.deserialize(serialized.drop(1))
                "InternetDiscoveryConfiguration" -> InternetDiscoveryConfigurationApi.deserialize(serialized.drop(1))
                "LocalMobileDiscoveryConfiguration" -> LocalMobileDiscoveryConfigurationApi.deserialize(serialized.drop(1))
                "UsbDiscoveryConfiguration" -> UsbDiscoveryConfigurationApi.deserialize(serialized.drop(1))
                else -> throw Error()
            }
        }
    }
}

data class BluetoothDiscoveryConfigurationApi(
    val isSimulated: Boolean,
    val timeout: Long?,
): DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): BluetoothDiscoveryConfigurationApi {
            return BluetoothDiscoveryConfigurationApi(
                isSimulated = serialized[0] as Boolean,
                timeout = serialized[1] as Long?,
            )
        }
    }
}

data class BluetoothProximityDiscoveryConfigurationApi(
    val isSimulated: Boolean,
): DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): BluetoothProximityDiscoveryConfigurationApi {
            return BluetoothProximityDiscoveryConfigurationApi(
                isSimulated = serialized[0] as Boolean,
            )
        }
    }
}

class HandoffDiscoveryConfigurationApi: DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): HandoffDiscoveryConfigurationApi {
            return HandoffDiscoveryConfigurationApi(
            )
        }
    }
}

data class InternetDiscoveryConfigurationApi(
    val isSimulated: Boolean,
    val locationId: String?,
): DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): InternetDiscoveryConfigurationApi {
            return InternetDiscoveryConfigurationApi(
                isSimulated = serialized[0] as Boolean,
                locationId = serialized[1] as String?,
            )
        }
    }
}

data class LocalMobileDiscoveryConfigurationApi(
    val isSimulated: Boolean,
): DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): LocalMobileDiscoveryConfigurationApi {
            return LocalMobileDiscoveryConfigurationApi(
                isSimulated = serialized[0] as Boolean,
            )
        }
    }
}

data class UsbDiscoveryConfigurationApi(
    val isSimulated: Boolean,
    val timeout: Long?,
): DiscoveryConfigurationApi() {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): UsbDiscoveryConfigurationApi {
            return UsbDiscoveryConfigurationApi(
                isSimulated = serialized[0] as Boolean,
                timeout = serialized[1] as Long?,
            )
        }
    }
}

enum class IncrementalAuthorizationStatusApi {
    NOT_SUPPORTED, SUPPORTED;
}

data class LocationApi(
    val address: AddressApi?,
    val displayName: String?,
    val id: String?,
    val livemode: Boolean?,
    val metadata: HashMap<String, String>,
) {
    fun serialize(): List<Any?> {
        return listOf(
            address?.serialize(),
            displayName,
            id,
            livemode,
            hashMapOf(*metadata.map { (k, v) -> k to v }.toTypedArray()),
        )
    }
}

enum class LocationStatusApi {
    SET, NOT_SET;
}

data class PaymentIntentApi(
    val id: String,
    val created: Long,
    val status: PaymentIntentStatusApi,
    val amount: Double,
    val captureMethod: String,
    val currency: String,
    val metadata: HashMap<String, String>,
    val paymentMethodId: String?,
    val amountTip: Double?,
    val statementDescriptor: String?,
    val statementDescriptorSuffix: String?,
    val amountCapturable: Double?,
    val amountReceived: Double?,
    val application: String?,
    val applicationFeeAmount: Double?,
    val cancellationReason: String?,
    val canceledAt: Long?,
    val clientSecret: String?,
    val confirmationMethod: String?,
    val customer: String?,
    val description: String?,
    val invoice: String?,
    val onBehalfOf: String?,
    val review: String?,
    val receiptEmail: String?,
    val setupFutureUsage: String?,
    val transferGroup: String?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            id,
            created,
            status.ordinal,
            amount,
            captureMethod,
            currency,
            hashMapOf(*metadata.map { (k, v) -> k to v }.toTypedArray()),
            paymentMethodId,
            amountTip,
            statementDescriptor,
            statementDescriptorSuffix,
            amountCapturable,
            amountReceived,
            application,
            applicationFeeAmount,
            cancellationReason,
            canceledAt,
            clientSecret,
            confirmationMethod,
            customer,
            description,
            invoice,
            onBehalfOf,
            review,
            receiptEmail,
            setupFutureUsage,
            transferGroup,
        )
    }
}

data class PaymentIntentParametersApi(
    val amount: Long,
    val currency: String,
    val captureMethod: CaptureMethodApi,
    val paymentMethodTypes: List<PaymentMethodTypeApi>,
) {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): PaymentIntentParametersApi {
            return PaymentIntentParametersApi(
                amount = (serialized[0] as Number).toLong(),
                currency = serialized[1] as String,
                captureMethod = (serialized[2] as Int).let { CaptureMethodApi.values()[it] },
                paymentMethodTypes = (serialized[3] as List<*>).map { (it as Int).let { PaymentMethodTypeApi.values()[it] } },
            )
        }
    }
}

enum class PaymentIntentStatusApi {
    CANCELED, PROCESSING, REQUIRES_CAPTURE, REQUIRES_CONFIRMATION, REQUIRES_PAYMENT_METHOD, SUCCEEDED;
}

data class PaymentMethodDetailsApi(
    val cardPresent: CardPresentDetailsApi?,
    val interacPresent: CardPresentDetailsApi?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            cardPresent?.serialize(),
            interacPresent?.serialize(),
        )
    }
}

enum class PaymentMethodTypeApi {
    CARD_PRESENT, CARD, INTERACT_PRESENT;
}

enum class PaymentStatusApi {
    NOT_READY, READY, WAITING_FOR_INPUT, PROCESSING;
}

data class ReaderApi(
    val locationStatus: LocationStatusApi?,
    val deviceType: DeviceTypeApi?,
    val simulated: Boolean,
    val locationId: String?,
    val location: LocationApi?,
    val serialNumber: String,
    val availableUpdate: Boolean,
    val batteryLevel: Double,
    val label: String?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            locationStatus?.ordinal,
            deviceType?.ordinal,
            simulated,
            locationId,
            location?.serialize(),
            serialNumber,
            availableUpdate,
            batteryLevel,
            label,
        )
    }
}

enum class ReaderDisplayMessageApi {
    CHECK_MOBILE_DEVICE, RETRY_CARD, INSERT_CARD, INSERT_OR_SWIPE_CARD, SWIPE_CARD, REMOVE_CARD, MULTIPLE_CONTACTLESS_CARDS_DETECTED, TRY_ANOTHER_READ_METHOD, TRY_ANOTHER_CARD, CARD_REMOVED_TOO_EARLY;
}

enum class ReaderEventApi {
    CARD_INSERTED, CARD_REMOVED;
}

enum class ReaderInputOptionApi {
    INSERT_CARD, SWIPE_CARD, TAP_CARD, MANUAL_ENTRY;
}

data class ReaderSoftwareUpdateApi(
    val components: List<UpdateComponentApi>,
    val keyProfileName: String?,
    val onlyInstallRequiredUpdates: Boolean,
    val requiredAt: Long,
    val settingsVersion: String?,
    val timeEstimate: UpdateTimeEstimateApi,
    val version: String,
) {
    fun serialize(): List<Any?> {
        return listOf(
            components.map { it.ordinal} ,
            keyProfileName,
            onlyInstallRequiredUpdates,
            requiredAt,
            settingsVersion,
            timeEstimate.ordinal,
            version,
        )
    }
}

data class ReceiptDetailsApi(
    val accountType: String?,
    val applicationPreferredName: String,
    val authorizationCode: String?,
    val authorizationResponseCode: String,
    val applicationCryptogram: String,
    val dedicatedFileName: String,
    val transactionStatusInformation: String,
    val terminalVerificationResults: String,
) {
    fun serialize(): List<Any?> {
        return listOf(
            accountType,
            applicationPreferredName,
            authorizationCode,
            authorizationResponseCode,
            applicationCryptogram,
            dedicatedFileName,
            transactionStatusInformation,
            terminalVerificationResults,
        )
    }
}

data class RefundApi(
    val id: String,
    val amount: Long,
    val chargeId: String,
    val created: Long,
    val currency: String,
    val metadata: HashMap<String, String>,
    val reason: String?,
    val status: RefundStatusApi?,
    val paymentMethodDetails: PaymentMethodDetailsApi?,
    val failureReason: String?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            id,
            amount,
            chargeId,
            created,
            currency,
            hashMapOf(*metadata.map { (k, v) -> k to v }.toTypedArray()),
            reason,
            status?.ordinal,
            paymentMethodDetails?.serialize(),
            failureReason,
        )
    }
}

enum class RefundStatusApi {
    SUCCEEDED, PENDING, FAILED;
}

data class SetupAttemptApi(
    val id: String,
    val applicationId: String?,
    val created: Long,
    val customerId: String?,
    val onBehalfOfId: String?,
    val paymentMethodId: String?,
    val paymentMethodDetails: SetupAttemptPaymentMethodDetailsApi?,
    val setupIntentId: String,
    val status: SetupAttemptStatusApi,
) {
    fun serialize(): List<Any?> {
        return listOf(
            id,
            applicationId,
            created,
            customerId,
            onBehalfOfId,
            paymentMethodId,
            paymentMethodDetails?.serialize(),
            setupIntentId,
            status.ordinal,
        )
    }
}

data class SetupAttemptCardPresentDetailsApi(
    val emvAuthData: String,
    val generatedCard: String,
) {
    fun serialize(): List<Any?> {
        return listOf(
            emvAuthData,
            generatedCard,
        )
    }
}

data class SetupAttemptPaymentMethodDetailsApi(
    val cardPresent: SetupAttemptCardPresentDetailsApi?,
    val interacPresent: SetupAttemptCardPresentDetailsApi?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            cardPresent?.serialize(),
            interacPresent?.serialize(),
        )
    }
}

enum class SetupAttemptStatusApi {
    REQUIRES_CONFIRMATION, REQUIRES_ACTION, PROCESSING, SUCCEEDED, FAILED, ABANDONED;
}

data class SetupIntentApi(
    val id: String,
    val created: Long,
    val customerId: String?,
    val metadata: HashMap<String, String>,
    val usage: SetupIntentUsageApi,
    val status: SetupIntentStatusApi,
    val latestAttempt: SetupAttemptApi?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            id,
            created,
            customerId,
            hashMapOf(*metadata.map { (k, v) -> k to v }.toTypedArray()),
            usage.ordinal,
            status.ordinal,
            latestAttempt?.serialize(),
        )
    }
}

enum class SetupIntentStatusApi {
    REQUIRES_PAYMENT_METHOD, REQUIRES_CONFIRMATION, REQUIRES_ACTION, PROCESSING, SUCCEEDED, CANCELLED;
}

enum class SetupIntentUsageApi {
    ON_SESSION, OFF_SESSION;
}

data class TerminalExceptionApi(
    val rawCode: String,
    val message: String?,
    val details: String?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            rawCode,
            message,
            details,
        )
    }
}

enum class TerminalExceptionCodeApi {
    PAYMENT_INTENT_NOT_RETRIEVED, CANCEL_FAILED, NOT_CONNECTED_TO_READER, ALREADY_CONNECTED_TO_READER, BLUETOOTH_PERMISSION_DENIED, PROCESS_INVALID_PAYMENT_INTENT, INVALID_CLIENT_SECRET, UNSUPPORTED_OPERATION, UNEXPECTED_OPERATION, UNSUPPORTED_SDK, USB_PERMISSION_DENIED, MISSING_REQUIRED_PARAMETER, INVALID_REQUIRED_PARAMETER, INVALID_TIP_PARAMETER, LOCAL_MOBILE_LIBRARY_NOT_INCLUDED, LOCAL_MOBILE_UNSUPPORTED_DEVICE, LOCAL_MOBILE_UNSUPPORTED_ANDROID_VERSION, LOCAL_MOBILE_DEVICE_TAMPERED, LOCAL_MOBILE_DEBUG_NOT_SUPPORTED, OFFLINE_MODE_UNSUPPORTED_ANDROID_VERSION, CANCELED, LOCATION_SERVICES_DISABLED, BLUETOOTH_SCAN_TIMED_OUT, BLUETOOTH_LOW_ENERGY_UNSUPPORTED, READER_SOFTWARE_UPDATE_FAILED_BATTERY_LOW, READER_SOFTWARE_UPDATE_FAILED_INTERRUPTED, CARD_INSERT_NOT_READ, CARD_SWIPE_NOT_READ, CARD_READ_TIMED_OUT, CARD_REMOVED, CUSTOMER_CONSENT_REQUIRED, CARD_LEFT_IN_READER, USB_DISCOVERY_TIMED_OUT, FEATURE_NOT_ENABLED_ON_ACCOUNT, READER_BUSY, READER_COMMUNICATION_ERROR, BLUETOOTH_ERROR, BLUETOOTH_DISCONNECTED, BLUETOOTH_RECONNECT_STARTED, USB_DISCONNECTED, USB_RECONNECT_STARTED, READER_CONNECTED_TO_ANOTHER_DEVICE, READER_SOFTWARE_UPDATE_FAILED, READER_SOFTWARE_UPDATE_FAILED_READER_ERROR, READER_SOFTWARE_UPDATE_FAILED_SERVER_ERROR, LOCAL_MOBILE_NFC_DISABLED, UNSUPPORTED_READER_VERSION, UNEXPECTED_SDK_ERROR, DECLINED_BY_STRIPE_API, DECLINED_BY_READER, REQUEST_TIMED_OUT, STRIPE_API_CONNECTION_ERROR, STRIPE_API_ERROR, STRIPE_API_RESPONSE_DECODING_ERROR, CONNECTION_TOKEN_PROVIDER_ERROR, SESSION_EXPIRED, ANDROID_API_LEVEL_ERROR, AMOUNT_EXCEEDS_MAX_OFFLINE_AMOUNT, OFFLINE_PAYMENTS_DATABASE_TOO_LARGE, READER_CONNECTION_NOT_AVAILABLE_OFFLINE, READER_CONNECTION_OFFLINE_LOCATION_MISMATCH, NO_LAST_SEEN_ACCOUNT, INVALID_OFFLINE_CURRENCY, CARD_SWIPE_NOT_AVAILABLE, INTERAC_NOT_SUPPORTED_OFFLINE, ONLINE_PIN_NOT_SUPPORTED_OFFLINE, OFFLINE_AND_CARD_EXPIRED, OFFLINE_TRANSACTION_DECLINED, OFFLINE_COLLECT_AND_PROCESS_MISMATCH, OFFLINE_TESTMODE_PAYMENT_IN_LIVEMODE, OFFLINE_LIVEMODE_PAYMENT_IN_TESTMODE, OFFLINE_PAYMENT_INTENT_NOT_FOUND, MISSING_EMV_DATA, CONNECTION_TOKEN_PROVIDER_ERROR_WHILE_FORWARDING, ACCOUNT_ID_MISMATCH_WHILE_FORWARDING, FORCE_OFFLINE_WITH_FEATURE_DISABLED, NOT_CONNECTED_TO_INTERNET_AND_REQUIRE_ONLINE_SET;
}

enum class UpdateComponentApi {
    INCREMENTAL, FIRMWARE, CONFIG, KEYS;
}

enum class UpdateTimeEstimateApi {
    LESS_THAN_ONE_MINUTE, ONE_TO_TWO_MINUTES, TWO_TO_FIVE_MINUTES, FIVE_TO_FIFTEEN_MINUTES;
}

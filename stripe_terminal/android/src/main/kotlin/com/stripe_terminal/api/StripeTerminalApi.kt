// GENERATED CODE - DO NOT MODIFY BY HAND

package com.stripe_terminal.api

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

interface StripeTerminalApi {
    fun onListLocations(
        result: Result<List<LocationApi>>,
        endingBefore: String?,
        limit: Long?,
        startingAfter: String?,
    )

    fun onConnectionStatus(): ConnectionStatusApi

    fun onConnectBluetoothReader(
        result: Result<StripeReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean,
    )

    fun onConnectInternetReader(
        result: Result<StripeReaderApi>,
        serialNumber: String,
        failIfInUse: Boolean,
    )

    fun onConnectMobileReader(
        result: Result<StripeReaderApi>,
        serialNumber: String,
        locationId: String,
    )

    fun onConnectedReader(): StripeReaderApi?

    fun onDisconnectReader(
        result: Result<Unit>,
    )

    fun onInstallAvailableUpdate(
        serialNumber: String,
    )

    fun onSetReaderDisplay(
        result: Result<Unit>,
        cart: CartApi,
    )

    fun onClearReaderDisplay(
        result: Result<Unit>,
    )

    fun onRetrievePaymentIntent(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String,
    )

    fun onInit()

    fun onStartReadReusableCard(
        result: Result<StripePaymentMethodApi>,
        operationId: Long,
        customer: String?,
        metadata: HashMap<String, String>?,
    )

    fun onStopReadReusableCard(
        result: Result<Unit>,
        operationId: Long,
    )

    fun onStartCollectPaymentMethod(
        result: Result<StripePaymentIntentApi>,
        operationId: Long,
        paymentIntentId: String,
        moto: Boolean,
        skipTipping: Boolean,
    )

    fun onStopCollectPaymentMethod(
        result: Result<Unit>,
        operationId: Long,
    )

    fun onProcessPayment(
        result: Result<StripePaymentIntentApi>,
        paymentIntentId: String,
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
                "listLocations" -> {
                    val res = Result<List<LocationApi>>(result) { it.map { it.serialize()}  }
                    onListLocations(res, args[0] as String?, (args[1] as? Number)?.toLong(), args[2] as String?)
                }
                "connectionStatus" -> {
                    val res = onConnectionStatus()
                    result.success(res.ordinal)
                }
                "connectBluetoothReader" -> {
                    val res = Result<StripeReaderApi>(result) { it.serialize() }
                    onConnectBluetoothReader(res, args[0] as String, args[1] as String, args[2] as Boolean)
                }
                "connectInternetReader" -> {
                    val res = Result<StripeReaderApi>(result) { it.serialize() }
                    onConnectInternetReader(res, args[0] as String, args[1] as Boolean)
                }
                "connectMobileReader" -> {
                    val res = Result<StripeReaderApi>(result) { it.serialize() }
                    onConnectMobileReader(res, args[0] as String, args[1] as String)
                }
                "connectedReader" -> {
                    val res = onConnectedReader()
                    result.success(res?.serialize())
                }
                "disconnectReader" -> {
                    val res = Result<Unit>(result) { null }
                    onDisconnectReader(res)
                }
                "installAvailableUpdate" -> {
                    onInstallAvailableUpdate(args[0] as String)
                    result.success(null)
                }
                "setReaderDisplay" -> {
                    val res = Result<Unit>(result) { null }
                    onSetReaderDisplay(res, (args[0] as List<Any?>).let { CartApi.deserialize(it) })
                }
                "clearReaderDisplay" -> {
                    val res = Result<Unit>(result) { null }
                    onClearReaderDisplay(res)
                }
                "retrievePaymentIntent" -> {
                    val res = Result<StripePaymentIntentApi>(result) { it.serialize() }
                    onRetrievePaymentIntent(res, args[0] as String)
                }
                "_init" -> {
                    onInit()
                    result.success(null)
                }
                "_startReadReusableCard" -> {
                    val res = Result<StripePaymentMethodApi>(result) { it.serialize() }
                    onStartReadReusableCard(res, (args[0] as Number).toLong(), args[1] as String?, args[2]?.let { hashMapOf(*(it as HashMap<*, *>).map { (k, v) -> k as String to v as String }.toTypedArray()) })
                }
                "_stopReadReusableCard" -> {
                    val res = Result<Unit>(result) { null }
                    onStopReadReusableCard(res, (args[0] as Number).toLong())
                }
                "_startCollectPaymentMethod" -> {
                    val res = Result<StripePaymentIntentApi>(result) { it.serialize() }
                    onStartCollectPaymentMethod(res, (args[0] as Number).toLong(), args[1] as String, args[2] as Boolean, args[3] as Boolean)
                }
                "_stopCollectPaymentMethod" -> {
                    val res = Result<Unit>(result) { null }
                    onStopCollectPaymentMethod(res, (args[0] as Number).toLong())
                }
                "_processPayment" -> {
                    val res = Result<StripePaymentIntentApi>(result) { it.serialize() }
                    onProcessPayment(res, args[0] as String)
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
            api: StripeTerminalApi,
            coroutineScope: CoroutineScope? = null,
        ) {
            channel = MethodChannel(binaryMessenger, "StripeTerminal")
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
    private val channel: EventChannel = EventChannel(binaryMessenger, "StripeTerminal#_discoverReaders")

    fun setHandler(
        onListen: (sink: ControllerSink<List<StripeReaderApi>>, discoveryMethod: DiscoveryMethodApi, simulated: Boolean, locationId: String?) -> Unit,
        onCancel: () -> Unit,
    ) {
        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as List<Any?>
                val sink = ControllerSink<List<StripeReaderApi>>(events) {it.map { it.serialize()} }
                onListen(sink, (args[0] as Int).let { DiscoveryMethodApi.values()[it] }, args[1] as Boolean, args[2] as String?)
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
        reader: StripeReaderApi,
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

    fun availableUpdate(
        availableUpdate: Boolean,
    ) {
        channel.invokeMethod("_onAvailableUpdate", listOf<Any?>(availableUpdate))
    }

    fun reportReaderSoftwareUpdateProgress(
        progress: Double,
    ) {
        channel.invokeMethod("_onReportReaderSoftwareUpdateProgress", listOf<Any?>(progress))
    }
}

data class LocationApi(
    val address: AddressApi?,
    val displayName: String?,
    val id: String?,
    val livemode: Boolean?,
    val metadata: HashMap<String, String>?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            address?.serialize(),
            displayName,
            id,
            livemode,
            metadata?.let { hashMapOf(*it.map { (k, v) -> k to v }.toTypedArray()) },
        )
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

data class StripeReaderApi(
    val locationStatus: LocationStatusApi,
    val batteryLevel: Double,
    val deviceType: DeviceTypeApi,
    val simulated: Boolean,
    val availableUpdate: Boolean,
    val locationId: String?,
    val serialNumber: String,
    val label: String?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            locationStatus.ordinal,
            batteryLevel,
            deviceType.ordinal,
            simulated,
            availableUpdate,
            locationId,
            serialNumber,
            label,
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

data class StripePaymentIntentApi(
    val id: String,
    val amount: Double,
    val amountCapturable: Double,
    val amountReceived: Double,
    val application: String?,
    val applicationFeeAmount: Double?,
    val captureMethod: String?,
    val cancellationReason: String?,
    val canceledAt: Long?,
    val clientSecret: String?,
    val confirmationMethod: String?,
    val created: Long,
    val currency: String?,
    val customer: String?,
    val description: String?,
    val invoice: String?,
    val livemode: Boolean,
    val metadata: HashMap<String, String>?,
    val onBehalfOf: String?,
    val paymentMethodId: String?,
    val status: PaymentIntentStatusApi?,
    val review: String?,
    val receiptEmail: String?,
    val setupFutureUsage: String?,
    val transferGroup: String?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            id,
            amount,
            amountCapturable,
            amountReceived,
            application,
            applicationFeeAmount,
            captureMethod,
            cancellationReason,
            canceledAt,
            clientSecret,
            confirmationMethod,
            created,
            currency,
            customer,
            description,
            invoice,
            livemode,
            metadata?.let { hashMapOf(*it.map { (k, v) -> k to v }.toTypedArray()) },
            onBehalfOf,
            paymentMethodId,
            status?.ordinal,
            review,
            receiptEmail,
            setupFutureUsage,
            transferGroup,
        )
    }
}

data class StripePaymentMethodApi(
    val id: String,
    val cardDetails: CardDetailsApi?,
    val customer: String?,
    val livemode: Boolean,
    val metadata: HashMap<String, String>?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            id,
            cardDetails?.serialize(),
            customer,
            livemode,
            metadata?.let { hashMapOf(*it.map { (k, v) -> k to v }.toTypedArray()) },
        )
    }
}

data class CardDetailsApi(
    val brand: String?,
    val country: String?,
    val expMonth: Long,
    val expYear: Long,
    val fingerprint: String?,
    val funding: String?,
    val last4: String?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            brand,
            country,
            expMonth,
            expYear,
            fingerprint,
            funding,
            last4,
        )
    }
}

enum class StripeTerminalExceptionCodeApi {
    PAYMENT_INTENT_NOT_RETRIEVED, CANCEL_FAILED, NOT_CONNECTED_TO_READER, ALREADY_CONNECTED_TO_READER, BLUETOOTH_PERMISSION_DENIED, PROCESS_INVALID_PAYMENT_INTENT, INVALID_CLIENT_SECRET, UNSUPPORTED_OPERATION, UNEXPECTED_OPERATION, UNSUPPORTED_SDK, USB_PERMISSION_DENIED, MISSING_REQUIRED_PARAMETER, INVALID_REQUIRED_PARAMETER, INVALID_TIP_PARAMETER, LOCAL_MOBILE_LIBRARY_NOT_INCLUDED, LOCAL_MOBILE_UNSUPPORTED_DEVICE, LOCAL_MOBILE_UNSUPPORTED_ANDROID_VERSION, LOCAL_MOBILE_DEVICE_TAMPERED, LOCAL_MOBILE_DEBUG_NOT_SUPPORTED, OFFLINE_MODE_UNSUPPORTED_ANDROID_VERSION, CANCELED, LOCATION_SERVICES_DISABLED, BLUETOOTH_SCAN_TIMED_OUT, BLUETOOTH_LOW_ENERGY_UNSUPPORTED, READER_SOFTWARE_UPDATE_FAILED_BATTERY_LOW, READER_SOFTWARE_UPDATE_FAILED_INTERRUPTED, CARD_INSERT_NOT_READ, CARD_SWIPE_NOT_READ, CARD_READ_TIMED_OUT, CARD_REMOVED, CUSTOMER_CONSENT_REQUIRED, CARD_LEFT_IN_READER, USB_DISCOVERY_TIMED_OUT, FEATURE_NOT_ENABLED_ON_ACCOUNT, READER_BUSY, READER_COMMUNICATION_ERROR, BLUETOOTH_ERROR, BLUETOOTH_DISCONNECTED, BLUETOOTH_RECONNECT_STARTED, USB_DISCONNECTED, USB_RECONNECT_STARTED, READER_CONNECTED_TO_ANOTHER_DEVICE, READER_SOFTWARE_UPDATE_FAILED, READER_SOFTWARE_UPDATE_FAILED_READER_ERROR, READER_SOFTWARE_UPDATE_FAILED_SERVER_ERROR, LOCAL_MOBILE_NFC_DISABLED, UNSUPPORTED_READER_VERSION, UNEXPECTED_SDK_ERROR, DECLINED_BY_STRIPE_API, DECLINED_BY_READER, REQUEST_TIMED_OUT, STRIPE_API_CONNECTION_ERROR, STRIPE_API_ERROR, STRIPE_API_RESPONSE_DECODING_ERROR, CONNECTION_TOKEN_PROVIDER_ERROR, SESSION_EXPIRED, ANDROID_API_LEVEL_ERROR, AMOUNT_EXCEEDS_MAX_OFFLINE_AMOUNT, OFFLINE_PAYMENTS_DATABASE_TOO_LARGE, READER_CONNECTION_NOT_AVAILABLE_OFFLINE, READER_CONNECTION_OFFLINE_LOCATION_MISMATCH, NO_LAST_SEEN_ACCOUNT, INVALID_OFFLINE_CURRENCY, CARD_SWIPE_NOT_AVAILABLE, INTERAC_NOT_SUPPORTED_OFFLINE, ONLINE_PIN_NOT_SUPPORTED_OFFLINE, OFFLINE_AND_CARD_EXPIRED, OFFLINE_TRANSACTION_DECLINED, OFFLINE_COLLECT_AND_PROCESS_MISMATCH, OFFLINE_TESTMODE_PAYMENT_IN_LIVEMODE, OFFLINE_LIVEMODE_PAYMENT_IN_TESTMODE, OFFLINE_PAYMENT_INTENT_NOT_FOUND, MISSING_EMV_DATA, CONNECTION_TOKEN_PROVIDER_ERROR_WHILE_FORWARDING, ACCOUNT_ID_MISMATCH_WHILE_FORWARDING, FORCE_OFFLINE_WITH_FEATURE_DISABLED, NOT_CONNECTED_TO_INTERNET_AND_REQUIRE_ONLINE_SET;
}

enum class ConnectionStatusApi {
    NOT_CONNECTED, CONNECTED, CONNECTING;
}

enum class LocationStatusApi {
    UNKNOWN, SET, NOT_SET;
}

enum class DeviceTypeApi {
    CHIPPER1_X, CHIPPER2_X, STRIPE_M2, COTS_DEVICE, VERIFONE_P400, WISE_CUBE, WISEPAD3, WISEPAD3S, WISEPOS_E, WISEPOS_E_DEVKIT, ETNA, STRIPE_S700, STRIPE_S700_DEVKIT, UNKNOWN;
}

enum class PaymentIntentStatusApi {
    CANCELED, PROCESSING, REQUIRES_CAPTURE, REQUIRES_CONFIRMATION, REQUIRES_PAYMENT_METHOD, SUCCEEDED;
}

enum class DiscoveryMethodApi {
    BLUETOOTH_SCAN, BLUETOOTH_PROXIMITY, INTERNET, LOCAL_MOBILE, HAND_OFF, EMBEDDED, USB;
}

enum class PaymentStatusApi {
    NOT_READY, READY, WAITING_FOR_INPUT, PROCESSING;
}

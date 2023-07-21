package com.stripe_terminal.api

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

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
        details: Any?,
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

abstract class StripeTerminalApi: FlutterPlugin, MethodChannel.MethodCallHandler {
    lateinit var channel: MethodChannel

    abstract fun onListLocations(
        result: Result<List<LocationApi>>,
        endingBefore: String?,
        limit: Long?,
        startingAfter: String?,
    )

    abstract fun onConnectionStatus(
        result: Result<ConnectionStatusApi>,
    )

    abstract fun onConnectBluetoothReader(
        result: Result<StripeReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean,
    )

    abstract fun onConnectInternetReader(
        result: Result<StripeReaderApi>,
        serialNumber: String,
        failIfInUse: Boolean,
    )

    abstract fun onConnectMobileReader(
        result: Result<StripeReaderApi>,
        serialNumber: String,
        locationId: String,
    )

    abstract fun onConnectedReader(
        result: Result<StripeReaderApi?>,
    )

    abstract fun onDisconnectReader(
        result: Result<Unit>,
    )

    abstract fun onSetReaderDisplay(
        result: Result<Unit>,
        cart: CartApi,
    )

    abstract fun onClearReaderDisplay(
        result: Result<Unit>,
    )

    abstract fun onRetrievePaymentIntent(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String,
    )

    abstract fun onProcessPayment(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String,
    )

    abstract fun onInit(
        result: Result<Unit>,
    )

    abstract fun onStartReadReusableCard(
        result: Result<StripePaymentMethodApi>,
        id: Long,
        customer: String?,
        metadata: HashMap<String, String>?,
    )

    abstract fun onStopReadReusableCard(
        result: Result<Unit>,
        id: Long,
    )

    abstract fun onStartCollectPaymentMethod(
        result: Result<StripePaymentIntentApi>,
        id: Long,
        clientSecret: String,
        moto: Boolean,
        skipTipping: Boolean,
    )

    abstract fun onStopCollectPaymentMethod(
        result: Result<Unit>,
        id: Long,
    )

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val args = call.arguments<List<Any?>>()!!
        when (call.method) {
            "listLocations" -> {
                val res = Result<List<LocationApi>>(result) {it.map{it.serialize()}}
                onListLocations(res, args[0] as String?, args[1] as Long?, args[2] as String?)
            }
            "connectionStatus" -> {
                val res = Result<ConnectionStatusApi>(result) {it.ordinal}
                onConnectionStatus(res)
            }
            "connectBluetoothReader" -> {
                val res = Result<StripeReaderApi>(result) {it.serialize()}
                onConnectBluetoothReader(res, args[0] as String, args[1] as String, args[2] as Boolean)
            }
            "connectInternetReader" -> {
                val res = Result<StripeReaderApi>(result) {it.serialize()}
                onConnectInternetReader(res, args[0] as String, args[1] as Boolean)
            }
            "connectMobileReader" -> {
                val res = Result<StripeReaderApi>(result) {it.serialize()}
                onConnectMobileReader(res, args[0] as String, args[1] as String)
            }
            "connectedReader" -> {
                val res = Result<StripeReaderApi?>(result) {it?.serialize()}
                onConnectedReader(res)
            }
            "disconnectReader" -> {
                val res = Result<Unit>(result) {null}
                onDisconnectReader(res)
            }
            "setReaderDisplay" -> {
                val res = Result<Unit>(result) {null}
                onSetReaderDisplay(res, (args[0] as List<Any?>).let{CartApi.deserialize(it)})
            }
            "clearReaderDisplay" -> {
                val res = Result<Unit>(result) {null}
                onClearReaderDisplay(res)
            }
            "retrievePaymentIntent" -> {
                val res = Result<StripePaymentIntentApi>(result) {it.serialize()}
                onRetrievePaymentIntent(res, args[0] as String)
            }
            "processPayment" -> {
                val res = Result<StripePaymentIntentApi>(result) {it.serialize()}
                onProcessPayment(res, args[0] as String)
            }
            "_init" -> {
                val res = Result<Unit>(result) {null}
                onInit(res)
            }
            "_startReadReusableCard" -> {
                val res = Result<StripePaymentMethodApi>(result) {it.serialize()}
                onStartReadReusableCard(res, args[0] as Long, args[1] as String?, args[2]?.let{hashMapOf(*(it as HashMap<*, *>).map{(k, v) -> k as String to v as String}.toTypedArray())})
            }
            "_stopReadReusableCard" -> {
                val res = Result<Unit>(result) {null}
                onStopReadReusableCard(res, args[0] as Long)
            }
            "_startCollectPaymentMethod" -> {
                val res = Result<StripePaymentIntentApi>(result) {it.serialize()}
                onStartCollectPaymentMethod(res, args[0] as Long, args[1] as String, args[2] as Boolean, args[3] as Boolean)
            }
            "_stopCollectPaymentMethod" -> {
                val res = Result<Unit>(result) {null}
                onStopCollectPaymentMethod(res, args[0] as Long)
            }
        }
    }

    override fun onAttachedToEngine(
        flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    ) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "StripeTerminal")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(
        flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    ) {
        channel.setMethodCallHandler(null)
    }
}

class DiscoverReadersControllerApi(
    binaryMessenger: BinaryMessenger,
) {
    private val channel: EventChannel = EventChannel(binaryMessenger, "StripeTerminal#discoverReaders")

    fun setHandler(
        onListen: (sink: ControllerSink<List<StripeReaderApi>>, discoveryMethod: DiscoveryMethodApi, simulated: Boolean, locationId: String?) -> Unit,
        onCancel: () -> Unit,
    ) {
        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as List<Any?>
                val sink = ControllerSink<List<StripeReaderApi>>(events) {it.map{it.serialize()}}
                onListen(sink, (args[0] as Int).let{DiscoveryMethodApi.values()[it]}, args[1] as Boolean, args[2] as String?)
            }
            override fun onCancel(arguments: Any?) = onCancel()
        })
    }

    fun removeHandler() = channel.setStreamHandler(null)
}

class OnConnectionStatusChangeControllerApi(
    binaryMessenger: BinaryMessenger,
) {
    private val channel: EventChannel = EventChannel(binaryMessenger, "StripeTerminal#_onConnectionStatusChange")

    fun setHandler(
        onListen: (sink: ControllerSink<ConnectionStatusApi>) -> Unit,
        onCancel: () -> Unit,
    ) {
        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as List<Any?>
                val sink = ControllerSink<ConnectionStatusApi>(events) {it.ordinal}
                onListen(sink)
            }
            override fun onCancel(arguments: Any?) = onCancel()
        })
    }

    fun removeHandler() = channel.setStreamHandler(null)
}

class OnUnexpectedReaderDisconnectControllerApi(
    binaryMessenger: BinaryMessenger,
) {
    private val channel: EventChannel = EventChannel(binaryMessenger, "StripeTerminal#_onUnexpectedReaderDisconnect")

    fun setHandler(
        onListen: (sink: ControllerSink<StripeReaderApi>) -> Unit,
        onCancel: () -> Unit,
    ) {
        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as List<Any?>
                val sink = ControllerSink<StripeReaderApi>(events) {it.serialize()}
                onListen(sink)
            }
            override fun onCancel(arguments: Any?) = onCancel()
        })
    }

    fun removeHandler() = channel.setStreamHandler(null)
}

class OnPaymentStatusChangeControllerApi(
    binaryMessenger: BinaryMessenger,
) {
    private val channel: EventChannel = EventChannel(binaryMessenger, "StripeTerminal#_onPaymentStatusChange")

    fun setHandler(
        onListen: (sink: ControllerSink<PaymentStatusApi>) -> Unit,
        onCancel: () -> Unit,
    ) {
        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as List<Any?>
                val sink = ControllerSink<PaymentStatusApi>(events) {it.ordinal}
                onListen(sink)
            }
            override fun onCancel(arguments: Any?) = onCancel()
        })
    }

    fun removeHandler() = channel.setStreamHandler(null)
}

class StripeTerminalHandlersApi(
    binaryMessenger: BinaryMessenger,
) {
    val channel: MethodChannel = MethodChannel(binaryMessenger, "_StripeTerminalHandlers")

    suspend fun requestConnectionToken(): String {
        return suspendCoroutine { continuation ->
            channel.invokeMethod(
                "_onRequestConnectionToken",
                listOf<Any?>(),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        continuation.resume(result as String)
                    }
                    override fun error(code: String, message: String?, details: Any?) {
                        continuation.resumeWithException(PlatformException(code, message, details))
                    }
                    override fun notImplemented() {}
                }
            )
        }
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
            metadata?.let{hashMapOf(*it.map{(k, v) -> k to v}.toTypedArray())},
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
                tax = serialized[1] as Long,
                total = serialized[2] as Long,
                lineItems = (serialized[3] as List<*>).map{(it as List<Any?>).let{CartLineItemApi.deserialize(it)}},
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
                quantity = serialized[1] as Long,
                amount = serialized[2] as Long,
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
            metadata?.let{hashMapOf(*it.map{(k, v) -> k to v}.toTypedArray())},
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
            metadata?.let{hashMapOf(*it.map{(k, v) -> k to v}.toTypedArray())},
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
    CANCEL_FAILED, NOT_CONNECTED_TO_READER, ALREADY_CONNECTED_TO_READER, BLUETOOTH_PERMISSION_DENIED, PROCESS_INVALID_PAYMENT_INTENT, INVALID_CLIENT_SECRET, UNSUPPORTED_OPERATION, UNEXPECTED_OPERATION, UNSUPPORTED_SDK, USB_PERMISSION_DENIED, MISSING_REQUIRED_PARAMETER, INVALID_REQUIRED_PARAMETER, INVALID_TIP_PARAMETER, LOCAL_MOBILE_LIBRARY_NOT_INCLUDED, LOCAL_MOBILE_UNSUPPORTED_DEVICE, LOCAL_MOBILE_UNSUPPORTED_ANDROID_VERSION, LOCAL_MOBILE_DEVICE_TAMPERED, LOCAL_MOBILE_DEBUG_NOT_SUPPORTED, OFFLINE_MODE_UNSUPPORTED_ANDROID_VERSION, CANCELED, LOCATION_SERVICES_DISABLED, BLUETOOTH_SCAN_TIMED_OUT, BLUETOOTH_LOW_ENERGY_UNSUPPORTED, READER_SOFTWARE_UPDATE_FAILED_BATTERY_LOW, READER_SOFTWARE_UPDATE_FAILED_INTERRUPTED, CARD_INSERT_NOT_READ, CARD_SWIPE_NOT_READ, CARD_READ_TIMED_OUT, CARD_REMOVED, CUSTOMER_CONSENT_REQUIRED, CARD_LEFT_IN_READER, USB_DISCOVERY_TIMED_OUT, FEATURE_NOT_ENABLED_ON_ACCOUNT, READER_BUSY, READER_COMMUNICATION_ERROR, BLUETOOTH_ERROR, BLUETOOTH_DISCONNECTED, BLUETOOTH_RECONNECT_STARTED, USB_DISCONNECTED, USB_RECONNECT_STARTED, READER_CONNECTED_TO_ANOTHER_DEVICE, READER_SOFTWARE_UPDATE_FAILED, READER_SOFTWARE_UPDATE_FAILED_READER_ERROR, READER_SOFTWARE_UPDATE_FAILED_SERVER_ERROR, LOCAL_MOBILE_NFC_DISABLED, UNSUPPORTED_READER_VERSION, UNEXPECTED_SDK_ERROR, DECLINED_BY_STRIPE_API, DECLINED_BY_READER, REQUEST_TIMED_OUT, STRIPE_API_CONNECTION_ERROR, STRIPE_API_ERROR, STRIPE_API_RESPONSE_DECODING_ERROR, CONNECTION_TOKEN_PROVIDER_ERROR, SESSION_EXPIRED, ANDROID_API_LEVEL_ERROR, AMOUNT_EXCEEDS_MAX_OFFLINE_AMOUNT, OFFLINE_PAYMENTS_DATABASE_TOO_LARGE, READER_CONNECTION_NOT_AVAILABLE_OFFLINE, READER_CONNECTION_OFFLINE_LOCATION_MISMATCH, NO_LAST_SEEN_ACCOUNT, INVALID_OFFLINE_CURRENCY, CARD_SWIPE_NOT_AVAILABLE, INTERAC_NOT_SUPPORTED_OFFLINE, ONLINE_PIN_NOT_SUPPORTED_OFFLINE, OFFLINE_AND_CARD_EXPIRED, OFFLINE_TRANSACTION_DECLINED, OFFLINE_COLLECT_AND_PROCESS_MISMATCH, OFFLINE_TESTMODE_PAYMENT_IN_LIVEMODE, OFFLINE_LIVEMODE_PAYMENT_IN_TESTMODE, OFFLINE_PAYMENT_INTENT_NOT_FOUND, MISSING_EMV_DATA, CONNECTION_TOKEN_PROVIDER_ERROR_WHILE_FORWARDING, ACCOUNT_ID_MISMATCH_WHILE_FORWARDING, FORCE_OFFLINE_WITH_FEATURE_DISABLED, NOT_CONNECTED_TO_INTERNET_AND_REQUIRE_ONLINE_SET;
}

enum class ConnectionStatusApi {
    NOT_CONNECTED, CONNECTED, CONNECTING;
}

enum class DiscoveryMethodApi {
    BLUETOOTH_SCAN, INTERNET, LOCAL_MOBILE, HAND_OFF, EMBEDDED, USB;
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

enum class PaymentStatusApi {
    NOT_READY, READY, WAITING_FOR_INPUT, PROCESSING;
}
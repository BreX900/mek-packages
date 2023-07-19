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

abstract class StripeTerminalApi: FlutterPlugin, MethodChannel.MethodCallHandler {
    lateinit var channel: MethodChannel

    abstract fun onConnectBluetoothReader(
        result: Result<StripeReaderApi>,
        readerSerialNumber: String,
        locationId: String,
    )

    abstract fun onConnectInternetReader(
        result: Result<StripeReaderApi>,
        readerSerialNumber: String,
        failIfInUse: Boolean,
    )

    abstract fun onConnectMobileReader(
        result: Result<StripeReaderApi>,
        readerSerialNumber: String,
        locationId: String,
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

    abstract fun onConnectionStatus(
        result: Result<ConnectionStatusApi>,
    )

    abstract fun onFetchConnectedReader(
        result: Result<StripeReaderApi?>,
    )

    abstract fun onReadReusableCardDetail(
        result: Result<StripePaymentMethodApi>,
    )

    abstract fun onRetrievePaymentIntent(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String,
    )

    abstract fun onCollectPaymentMethod(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String,
        collectConfiguration: CollectConfigurationApi,
    )

    abstract fun onProcessPayment(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String,
    )

    abstract fun onListLocations(
        result: Result<List<LocationApi>>,
    )

    abstract fun onInit(
        result: Result<Unit>,
    )

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val args = call.arguments<List<Any?>>()!!
        when (call.method) {
            "connectBluetoothReader" -> {
                val res = Result<StripeReaderApi>(result) {it.serialize()}
                onConnectBluetoothReader(res, args[0] as String, args[1] as String)
            }
            "connectInternetReader" -> {
                val res = Result<StripeReaderApi>(result) {it.serialize()}
                onConnectInternetReader(res, args[0] as String, args[1] as Boolean)
            }
            "connectMobileReader" -> {
                val res = Result<StripeReaderApi>(result) {it.serialize()}
                onConnectMobileReader(res, args[0] as String, args[1] as String)
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
            "connectionStatus" -> {
                val res = Result<ConnectionStatusApi>(result) {it.ordinal}
                onConnectionStatus(res)
            }
            "fetchConnectedReader" -> {
                val res = Result<StripeReaderApi?>(result) {it?.serialize()}
                onFetchConnectedReader(res)
            }
            "readReusableCardDetail" -> {
                val res = Result<StripePaymentMethodApi>(result) {it.serialize()}
                onReadReusableCardDetail(res)
            }
            "retrievePaymentIntent" -> {
                val res = Result<StripePaymentIntentApi>(result) {it.serialize()}
                onRetrievePaymentIntent(res, args[0] as String)
            }
            "collectPaymentMethod" -> {
                val res = Result<StripePaymentIntentApi>(result) {it.serialize()}
                onCollectPaymentMethod(res, args[0] as String, (args[1] as List<Any?>).let{CollectConfigurationApi.deserialize(it)})
            }
            "processPayment" -> {
                val res = Result<StripePaymentIntentApi>(result) {it.serialize()}
                onProcessPayment(res, args[0] as String)
            }
            "listLocations" -> {
                val res = Result<List<LocationApi>>(result) {it.map{it.serialize()}}
                onListLocations(res)
            }
            "_init" -> {
                val res = Result<Unit>(result) {null}
                onInit(res)
            }
        }
    }

    override fun onAttachedToEngine(
        flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    ) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "stripe_terminal")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(
        flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    ) {
        channel.setMethodCallHandler(null)
    }
}

class OnUnexpectedReaderDisconnectController {
    lateinit var channel: EventChannel
    var sink: EventChannel.EventSink? = null
    var onListen: (() -> Unit)? = null
    var onCancel: (() -> Unit)? = null
    val isClosed: Boolean get() = sink == null

    fun setup(
        binaryMessenger: BinaryMessenger,
    ) {
        channel = EventChannel(binaryMessenger, "stripe_terminal#onUnexpectedReaderDisconnect")
        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as List<Any?>
                sink = events
                onListen?.invoke()
            }
        
            override fun onCancel(arguments: Any?) {
                sink = null
                onCancel?.invoke()
            }
        })
        
    }

    fun add(
        data: StripeReaderApi,
    ) = sink!!.success(data.serialize())

    fun addError(
        code: String,
        message: String?,
        details: Any?,
    ) = sink!!.error(code, message, details)

    fun close() = sink!!.endOfStream()

    fun erase() = channel.setStreamHandler(null)
}

class OnConnectionStatusChangeController {
    lateinit var channel: EventChannel
    var sink: EventChannel.EventSink? = null
    var onListen: (() -> Unit)? = null
    var onCancel: (() -> Unit)? = null
    val isClosed: Boolean get() = sink == null

    fun setup(
        binaryMessenger: BinaryMessenger,
    ) {
        channel = EventChannel(binaryMessenger, "stripe_terminal#onConnectionStatusChange")
        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as List<Any?>
                sink = events
                onListen?.invoke()
            }
        
            override fun onCancel(arguments: Any?) {
                sink = null
                onCancel?.invoke()
            }
        })
        
    }

    fun add(
        data: ConnectionStatusApi,
    ) = sink!!.success(data.ordinal)

    fun addError(
        code: String,
        message: String?,
        details: Any?,
    ) = sink!!.error(code, message, details)

    fun close() = sink!!.endOfStream()

    fun erase() = channel.setStreamHandler(null)
}

class DiscoverReadersController {
    lateinit var channel: EventChannel
    var sink: EventChannel.EventSink? = null
    var onListen: ((config: DiscoverConfigApi) -> Unit)? = null
    var onCancel: (() -> Unit)? = null
    val isClosed: Boolean get() = sink == null

    fun setup(
        binaryMessenger: BinaryMessenger,
    ) {
        channel = EventChannel(binaryMessenger, "stripe_terminal#discoverReaders")
        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as List<Any?>
                sink = events
                onListen?.invoke((args[0] as List<Any?>).let{DiscoverConfigApi.deserialize(it)})
            }
        
            override fun onCancel(arguments: Any?) {
                sink = null
                onCancel?.invoke()
            }
        })
        
    }

    fun add(
        data: List<StripeReaderApi>,
    ) = sink!!.success(data.map{it.serialize()})

    fun addError(
        code: String,
        message: String?,
        details: Any?,
    ) = sink!!.error(code, message, details)

    fun close() = sink!!.endOfStream()

    fun erase() = channel.setStreamHandler(null)
}

class OnPaymentStatusChangeController {
    lateinit var channel: EventChannel
    var sink: EventChannel.EventSink? = null
    var onListen: (() -> Unit)? = null
    var onCancel: (() -> Unit)? = null
    val isClosed: Boolean get() = sink == null

    fun setup(
        binaryMessenger: BinaryMessenger,
    ) {
        channel = EventChannel(binaryMessenger, "stripe_terminal#onPaymentStatusChange")
        channel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as List<Any?>
                sink = events
                onListen?.invoke()
            }
        
            override fun onCancel(arguments: Any?) {
                sink = null
                onCancel?.invoke()
            }
        })
        
    }

    fun add(
        data: PaymentStatusApi,
    ) = sink!!.success(data.ordinal)

    fun addError(
        code: String,
        message: String?,
        details: Any?,
    ) = sink!!.error(code, message, details)

    fun close() = sink!!.endOfStream()

    fun erase() = channel.setStreamHandler(null)
}

class StripeTerminalHandlersApi(
    binaryMessenger: BinaryMessenger,
) {
    val channel: MethodChannel = MethodChannel(binaryMessenger, "stripe_terminal_handlers")

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

enum class LocationStatusApi {
    UNKNOWN, SET, NOT_SET;
}

enum class DeviceTypeApi {
    CHIPPER1_X, CHIPPER2_X, STRIPE_M2, COTS_DEVICE, VERIFONE_P400, WISE_CUBE, WISEPAD3, WISEPAD3S, WISEPOS_E, WISEPOS_E_DEVKIT, ETNA, STRIPE_S700, STRIPE_S700_DEVKIT, UNKNOWN;
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

enum class ConnectionStatusApi {
    NOT_CONNECTED, CONNECTED, CONNECTING;
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

data class DiscoverConfigApi(
    val discoveryMethod: DiscoveryMethodApi,
    val simulated: Boolean,
    val locationId: String?,
) {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): DiscoverConfigApi {
            return DiscoverConfigApi(
                discoveryMethod = (serialized[0] as Int).let{DiscoveryMethodApi.values()[it]},
                simulated = serialized[1] as Boolean,
                locationId = serialized[2] as String?,
            )
        }
    }
}

enum class DiscoveryMethodApi {
    BLUETOOTH_SCAN, INTERNET, LOCAL_MOBILE, HAND_OFF, EMBEDDED, USB;
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

enum class PaymentIntentStatusApi {
    CANCELED, PROCESSING, REQUIRES_CAPTURE, REQUIRES_CONFIRMATION, REQUIRES_PAYMENT_METHOD, SUCCEEDED;
}

enum class PaymentStatusApi {
    NOT_READY, READY, WAITING_FOR_INPUT, PROCESSING;
}

data class CollectConfigurationApi(
    val skipTipping: Boolean,
) {
    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): CollectConfigurationApi {
            return CollectConfigurationApi(
                skipTipping = serialized[0] as Boolean,
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
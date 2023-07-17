package com.stripe_terminal.api

import io.flutter.embedding.engine.plugins.FlutterPlugin
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
    ) {
        result.success(serializer(data))
    }

    fun error(
        code: String,
        message: String,
        details: Any?,
    ) {
        result.error(code, message, details)
    }
}

abstract class StripeTerminalApi: FlutterPlugin, MethodChannel.MethodCallHandler {
    lateinit var channel: MethodChannel

    suspend fun requestConnectionToken(): String {
        return suspendCoroutine { continuation ->
            channel.invokeMethod(
                "_onRequestConnectionToken",
                listOf<Any?>(),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        continuation.resume(result as String)
                    }
                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                        continuation.resumeWithException(PlatformException(errorCode, errorMessage, errorDetails))
                    }
                    override fun notImplemented() {}
                }
            )
        }
    }

    suspend fun readersFound(
        readers: List<StripeReaderApi>,
    ) {
        return suspendCoroutine { continuation ->
            channel.invokeMethod(
                "_onReadersFound",
                listOf<Any?>(readers.map{it.serialize()}),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        continuation.resume(Unit)
                    }
                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                        continuation.resumeWithException(PlatformException(errorCode, errorMessage, errorDetails))
                    }
                    override fun notImplemented() {}
                }
            )
        }
    }

    abstract fun onConnectBluetoothReader(
        result: Result<StripeReaderApi>,
        readerSerialNumber: String,
        locationId: String?,
    )

    abstract fun onConnectInternetReader(
        result: Result<StripeReaderApi>,
        readerSerialNumber: String,
        failIfInUse: Boolean,
    )

    abstract fun onListLocations(
        result: Result<List<LocationApi>>,
    )

    abstract fun onConnectMobileReader(
        result: Result<StripeReaderApi>,
        readerSerialNumber: String,
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
        collectConfiguration: CollectConfigurationApi,
    )

    abstract fun onProcessPayment(
        result: Result<StripePaymentIntentApi>,
    )

    abstract fun onInit(
        result: Result<Unit>,
    )

    abstract fun onStartDiscoverReaders(
        result: Result<Unit>,
        config: DiscoverConfigApi,
    )

    abstract fun onStopDiscoverReaders(
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
                onConnectBluetoothReader(res, args[0] as String, args[1] as String?)
            }
            "connectInternetReader" -> {
                val res = Result<StripeReaderApi>(result) {it.serialize()}
                onConnectInternetReader(res, args[0] as String, args[1] as Boolean)
            }
            "listLocations" -> {
                val res = Result<List<LocationApi>>(result) {it.map{it.serialize()}}
                onListLocations(res)
            }
            "connectMobileReader" -> {
                val res = Result<StripeReaderApi>(result) {it.serialize()}
                onConnectMobileReader(res, args[0] as String)
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
                onCollectPaymentMethod(res, (args[0] as List<Any?>).let{CollectConfigurationApi.deserialize(it)})
            }
            "processPayment" -> {
                val res = Result<StripePaymentIntentApi>(result) {it.serialize()}
                onProcessPayment(res)
            }
            "_init" -> {
                val res = Result<Unit>(result) {null}
                onInit(res)
            }
            "_startDiscoverReaders" -> {
                val res = Result<Unit>(result) {null}
                onStartDiscoverReaders(res, (args[0] as List<Any?>).let{DiscoverConfigApi.deserialize(it)})
            }
            "_stopDiscoverReaders" -> {
                val res = Result<Unit>(result) {null}
                onStopDiscoverReaders(res)
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

    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): StripeReaderApi {
            return StripeReaderApi(
                locationStatus = (serialized[0] as Int).let{LocationStatusApi.values()[it]},
                batteryLevel = serialized[1] as Double,
                deviceType = (serialized[2] as Int).let{DeviceTypeApi.values()[it]},
                simulated = serialized[3] as Boolean,
                availableUpdate = serialized[4] as Boolean,
                locationId = serialized[5] as String?,
                serialNumber = serialized[6] as String,
                label = serialized[7] as String?,
            )
        }
    }
}

enum class LocationStatusApi {
    UNKNOWN, SET, NOT_SET;
}

enum class DeviceTypeApi {
    CHIPPER1_X, CHIPPER2_X, STRIPE_M2, COTS_DEVICE, VERIFONE_P400, WISE_CUBE, WISEPAD3, WISEPAD3S, WISEPOS_E, WISEPOS_E_DEVKIT, ETNA, STRIPE_S700, STRIPE_S700_DEVKIT, UNKNOWN;
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
            metadata?.let{hashMapOf(*it.map{(k, v) -> k to v as String}.toTypedArray())},
        )
    }

    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): LocationApi {
            return LocationApi(
                address = (serialized[0] as List<Any?>?)?.let{AddressApi.deserialize(it)},
                displayName = serialized[1] as String?,
                id = serialized[2] as String?,
                livemode = serialized[3] as Boolean?,
                metadata = serialized[4]?.let{hashMapOf(*(it as HashMap<*, *>).map{(k, v) -> k as String to v as String}.toTypedArray())},
            )
        }
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

    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): AddressApi {
            return AddressApi(
                city = serialized[0] as String?,
                country = serialized[1] as String?,
                line1 = serialized[2] as String?,
                line2 = serialized[3] as String?,
                postalCode = serialized[4] as String?,
                state = serialized[5] as String?,
            )
        }
    }
}

data class CartApi(
    val currency: String,
    val tax: Long,
    val total: Long,
    val lineItems: List<CartLineItemApi>,
) {
    fun serialize(): List<Any?> {
        return listOf(
            currency,
            tax,
            total,
            lineItems.map{it.serialize()},
        )
    }

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
    fun serialize(): List<Any?> {
        return listOf(
            description,
            quantity,
            amount,
        )
    }

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
            metadata?.let{hashMapOf(*it.map{(k, v) -> k to v as String}.toTypedArray())},
        )
    }

    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): StripePaymentMethodApi {
            return StripePaymentMethodApi(
                id = serialized[0] as String,
                cardDetails = (serialized[1] as List<Any?>?)?.let{CardDetailsApi.deserialize(it)},
                customer = serialized[2] as String?,
                livemode = serialized[3] as Boolean,
                metadata = serialized[4]?.let{hashMapOf(*(it as HashMap<*, *>).map{(k, v) -> k as String to v as String}.toTypedArray())},
            )
        }
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

    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): CardDetailsApi {
            return CardDetailsApi(
                brand = serialized[0] as String?,
                country = serialized[1] as String?,
                expMonth = serialized[2] as Long,
                expYear = serialized[3] as Long,
                fingerprint = serialized[4] as String?,
                funding = serialized[5] as String?,
                last4 = serialized[6] as String?,
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
            metadata?.let{hashMapOf(*it.map{(k, v) -> k to v as String}.toTypedArray())},
            onBehalfOf,
            paymentMethodId,
            status?.ordinal,
            review,
            receiptEmail,
            setupFutureUsage,
            transferGroup,
        )
    }

    companion object {
        fun deserialize(
            serialized: List<Any?>,
        ): StripePaymentIntentApi {
            return StripePaymentIntentApi(
                id = serialized[0] as String,
                amount = serialized[1] as Double,
                amountCapturable = serialized[2] as Double,
                amountReceived = serialized[3] as Double,
                application = serialized[4] as String?,
                applicationFeeAmount = serialized[5] as Double?,
                captureMethod = serialized[6] as String?,
                cancellationReason = serialized[7] as String?,
                canceledAt = serialized[8] as Long?,
                clientSecret = serialized[9] as String?,
                confirmationMethod = serialized[10] as String?,
                created = serialized[11] as Long,
                currency = serialized[12] as String?,
                customer = serialized[13] as String?,
                description = serialized[14] as String?,
                invoice = serialized[15] as String?,
                livemode = serialized[16] as Boolean,
                metadata = serialized[17]?.let{hashMapOf(*(it as HashMap<*, *>).map{(k, v) -> k as String to v as String}.toTypedArray())},
                onBehalfOf = serialized[18] as String?,
                paymentMethodId = serialized[19] as String?,
                status = (serialized[20] as Int?)?.let{PaymentIntentStatusApi.values()[it]},
                review = serialized[21] as String?,
                receiptEmail = serialized[22] as String?,
                setupFutureUsage = serialized[23] as String?,
                transferGroup = serialized[24] as String?,
            )
        }
    }
}

enum class PaymentIntentStatusApi {
    CANCELED, PROCESSING, REQUIRES_CAPTURE, REQUIRES_CONFIRMATION, REQUIRES_PAYMENT_METHOD, SUCCEEDED;
}

data class CollectConfigurationApi(
    val skipTipping: Boolean,
) {
    fun serialize(): List<Any?> {
        return listOf(
            skipTipping,
        )
    }

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

data class DiscoverConfigApi(
    val discoveryMethod: DiscoveryMethodApi,
    val simulated: Boolean,
    val locationId: String?,
) {
    fun serialize(): List<Any?> {
        return listOf(
            discoveryMethod.ordinal,
            simulated,
            locationId,
        )
    }

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
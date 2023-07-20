package com.stripe_terminal

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.TerminalApplicationDelegate
import com.stripe.stripeterminal.external.callable.*
import com.stripe.stripeterminal.external.models.*
import com.stripe.stripeterminal.external.callable.ConnectionTokenProvider
import com.stripe.stripeterminal.log.LogLevel
import com.stripe_terminal.api.CartApi
import com.stripe_terminal.api.ConnectionStatusApi
import com.stripe_terminal.api.ControllerSink
import com.stripe_terminal.api.DiscoverReadersControllerApi
import com.stripe_terminal.api.DiscoveryMethodApi
import com.stripe_terminal.api.LocationApi
import com.stripe_terminal.api.OnConnectionStatusChangeControllerApi
import com.stripe_terminal.api.OnPaymentStatusChangeControllerApi
import com.stripe_terminal.api.OnUnexpectedReaderDisconnectControllerApi
import com.stripe_terminal.api.PaymentStatusApi
import com.stripe_terminal.api.StripePaymentIntentApi
import com.stripe_terminal.api.StripePaymentMethodApi
import com.stripe_terminal.api.StripeReaderApi
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import kotlinx.coroutines.runBlocking
import com.stripe_terminal.api.StripeTerminalApi
import com.stripe_terminal.api.Result
import com.stripe_terminal.api.StripeTerminalHandlersApi
import com.stripe_terminal.api.toApi
import com.stripe_terminal.api.toHost
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.Dispatchers


/** StripeTerminalPlugin */
class StripeTerminalPlugin : FlutterPlugin, ActivityAware, StripeTerminalApi(),
    ConnectionTokenProvider, TerminalListener {
    private lateinit var _handlers: StripeTerminalHandlersApi

    private lateinit var _discoverReadersController: DiscoverReadersControllerApi

    private lateinit var _onConnectionStatusChangeController: OnConnectionStatusChangeControllerApi
    private var _onConnectionStatusChangeSink: ControllerSink<ConnectionStatusApi>? = null
    private lateinit var _onUnexpectedReaderDisconnectController: OnUnexpectedReaderDisconnectControllerApi
    private var _onUnexpectedReaderDisconnectSink: ControllerSink<StripeReaderApi>? = null
    private lateinit var _onPaymentIntentStatusController: OnPaymentStatusChangeControllerApi
    private var _onPaymentIntentStatusSink: ControllerSink<PaymentStatusApi>? = null

    private val _terminal: Terminal get() = Terminal.getInstance()

    private var _activity: Activity? = null
    private var _discoveredReaders: List<Reader> = arrayListOf()

    private val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        arrayOf(
            Manifest.permission.BLUETOOTH_SCAN,
            Manifest.permission.BLUETOOTH_ADMIN,
        )
    } else {
        arrayOf(
            Manifest.permission.BLUETOOTH_ADMIN,
        )
    }


    override fun onInit(result: Result<Unit>) {
        val permissionStatus = permissions.map {
            ContextCompat.checkSelfPermission(_activity!!, it)
        }

        if (permissionStatus.contains(PackageManager.PERMISSION_DENIED)) {
            result.error(
                "stripeTerminal#permissionDeclinedPermanenty",
                "You have declined the necessary permission, please allow from settings to continue.",
                null
            )
            return
        }

        if (Terminal.isInitialized()) {
            result.success(Unit)
            return
        }

        Terminal.initTerminal(
            _activity!!.applicationContext,
            LogLevel.NONE,
            this,
            this
        )
        result.success(Unit)
    }

    //region LOCATIONS
    override fun onListLocations(
        result: Result<List<LocationApi>>,
        endingBefore: String?,
        limit: Long?,
        startingAfter: String?,
    ) {
        val params = ListLocationsParameters.Builder()
        params.endingBefore = endingBefore
        params.startingAfter = startingAfter
        params.limit = limit?.toInt()
        _terminal.listLocations(params.build(),
            object : TerminalErrorHandler(result::error), LocationListCallback {
                override fun onSuccess(locations: List<Location>, hasMore: Boolean) =
                    result.success(locations.map { it.toApi() })
            })
    }
    //endregion

    //region Connection Status
    override fun onConnectionStatus(result: Result<ConnectionStatusApi>) {
        result.success(_terminal.connectionStatus.toApi())
    }
    //endregion

    //region Readers
    override fun onConnectBluetoothReader(
        result: Result<StripeReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean,
    ) {
        val reader = findActiveReader(result, serialNumber) ?: return

        _terminal.connectBluetoothReader(reader,
            ConnectionConfiguration.BluetoothConnectionConfiguration(
                locationId = locationId,
                autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect
            ),
            object : BluetoothReaderListener {},
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            }
        )
    }

    override fun onConnectInternetReader(
        result: Result<StripeReaderApi>,
        serialNumber: String,
        failIfInUse: Boolean
    ) {
        val reader = findActiveReader(result, serialNumber) ?: return

        _terminal.connectInternetReader(reader,
            ConnectionConfiguration.InternetConnectionConfiguration(
                failIfInUse = failIfInUse
            ),
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            })
    }

    override fun onConnectMobileReader(
        result: Result<StripeReaderApi>,
        serialNumber: String,
        locationId: String,
    ) {
        val reader = findActiveReader(result, serialNumber) ?: return

        val config = ConnectionConfiguration.LocalMobileConnectionConfiguration(
            locationId = locationId
        )
        _terminal.connectLocalMobileReader(reader, config,
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            })
    }

    override fun onConnectedReader(result: Result<StripeReaderApi?>) {
        result.success(_terminal.connectedReader?.toApi())
    }


    override fun onDisconnectReader(result: Result<Unit>) {
        _terminal.disconnectReader(object : TerminalErrorHandler(result::error), Callback {
            override fun onSuccess() = result.success(Unit)
        })
    }
    //endregion

    //region Reader Display
    override fun onSetReaderDisplay(result: Result<Unit>, cart: CartApi) {
        _terminal.setReaderDisplay(cart.toHost(),
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            })
    }

    override fun onClearReaderDisplay(result: Result<Unit>) {
        _terminal.clearReaderDisplay(object : TerminalErrorHandler(result::error), Callback {
            override fun onSuccess() = result.success(Unit)
        })
    }
    //endregion

    override fun onReadReusableCard(
        result: Result<StripePaymentMethodApi>,
        customer: String?,
        metadata: HashMap<String, String>?
    ) {
        val params = ReadReusableCardParameters.Builder()
        if (customer != null) params.setCustomer(customer)
        if (metadata != null) params.putAllMetadata(metadata)
        _terminal.readReusableCard(params.build(),
            object : TerminalErrorHandler(result::error), PaymentMethodCallback {
                override fun onSuccess(paymentMethod: PaymentMethod) =
                    result.success(paymentMethod.toApi())
            })
    }

    //region Payment
    override fun onRetrievePaymentIntent(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String
    ) {
        _terminal.retrievePaymentIntent(clientSecret,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) =
                    result.success(paymentIntent.toApi())
            })
    }

    override fun onCollectPaymentMethod(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String,
        moto: Boolean,
        skipTipping: Boolean,
    ) {
        _terminal.retrievePaymentIntent(clientSecret,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    _terminal.collectPaymentMethod(
                        paymentIntent,
                        object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                            override fun onSuccess(paymentIntent: PaymentIntent) =
                                result.success(paymentIntent.toApi())
                        },
                        CollectConfiguration.Builder()
                            .setMoto(moto)
                            .skipTipping(skipTipping)
                            .build(),
                    )
                }
            })
    }

    override fun onProcessPayment(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String,
    ) {
        _terminal.retrievePaymentIntent(clientSecret,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    _terminal.processPayment(
                        paymentIntent,
                        object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                            override fun onSuccess(paymentIntent: PaymentIntent) =
                                result.success(paymentIntent.toApi())
                        })
                }
            })
    }
    //endregion

    private var _discoverReaderCancelable: Cancelable? = null

    private fun setupDiscoverReadersController(binaryMessenger: BinaryMessenger) {
        _discoverReadersController = DiscoverReadersControllerApi(binaryMessenger)
        _discoverReadersController.setHandler({ sink, discoveryMethod: DiscoveryMethodApi, simulated: Boolean, locationId: String? ->
            val config = DiscoveryConfiguration(
                isSimulated = simulated,
                discoveryMethod = discoveryMethod.toHost(),
                location = locationId
            )
            _discoverReaderCancelable =
                _terminal.discoverReaders(config, object : DiscoveryListener {
                    override fun onUpdateDiscoveredReaders(readers: List<Reader>) {
                        _discoveredReaders = readers
                        _activity!!.runOnUiThread {
                            sink.success(readers.map { it.toApi() })
                        }
                    }
                }, object : TerminalErrorHandler(sink::error), Callback {
                    // Ignore result
                    override fun onSuccess() {}
                })
        }, {
            // Ignore results
            _discoverReaderCancelable!!.cancel(object : Callback {
                override fun onFailure(e: TerminalException) {
                    _discoverReaderCancelable = null
                }

                override fun onSuccess() {
                    _discoverReaderCancelable = null
                }
            })
        })
    }

    private fun setupOnConnectionStatusChangeController(binaryMessenger: BinaryMessenger) {
        _onConnectionStatusChangeController = OnConnectionStatusChangeControllerApi(binaryMessenger)
        _onConnectionStatusChangeController.setHandler({ sink ->
            _onConnectionStatusChangeSink = sink
        }, {
            _onConnectionStatusChangeSink = null
        })
    }

    private fun setupOnUnexpectedReaderDisconnectController(binaryMessenger: BinaryMessenger) {
        _onUnexpectedReaderDisconnectController =
            OnUnexpectedReaderDisconnectControllerApi(binaryMessenger)
        _onUnexpectedReaderDisconnectController.setHandler({ sink ->
            _onUnexpectedReaderDisconnectSink = sink
        }, {
            _onUnexpectedReaderDisconnectSink = null
        })
    }

    private fun setupOnPaymentStatusChangeController(binaryMessenger: BinaryMessenger) {
        _onPaymentIntentStatusController = OnPaymentStatusChangeControllerApi(binaryMessenger)
        _onPaymentIntentStatusController.setHandler({ sink ->
            _onPaymentIntentStatusSink = sink
        }, {
            _onPaymentIntentStatusSink = null
        })
    }

    // ======================== Flutter

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        super.onAttachedToEngine(flutterPluginBinding)
        val binaryMessenger = flutterPluginBinding.binaryMessenger
        _handlers = StripeTerminalHandlersApi(binaryMessenger)

        setupDiscoverReadersController(binaryMessenger)
        setupOnConnectionStatusChangeController(binaryMessenger)
        setupOnUnexpectedReaderDisconnectController(binaryMessenger)
        setupOnPaymentStatusChangeController(binaryMessenger)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        if (_terminal.connectedReader != null) {
            _terminal.disconnectReader(object : Callback {
                // Ignore results
                override fun onFailure(e: TerminalException) {}
                override fun onSuccess() {}
            })
        }
        _discoverReaderCancelable?.cancel(object : Callback {
            // Ignore results
            override fun onFailure(e: TerminalException) {}
            override fun onSuccess() {}
        })
        _discoverReaderCancelable = null

        _discoverReadersController.removeHandler()
        _onConnectionStatusChangeController.removeHandler()
        _onUnexpectedReaderDisconnectController.removeHandler();
        _onPaymentIntentStatusController.removeHandler();

        super.onDetachedFromEngine(flutterPluginBinding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        _activity = binding.activity
        TerminalApplicationDelegate.onCreate(_activity!!.application)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        _activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        _activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        _activity = null
    }

    // ======================== STRIPE

    override fun fetchConnectionToken(callback: ConnectionTokenCallback) {
        runBlocking(Dispatchers.Main) {
            try {
                val token = _handlers.requestConnectionToken()
                callback.onSuccess(token)
            } catch (error: Throwable) {
                callback.onFailure(ConnectionTokenException("", error))
            }
        }
    }

    override fun onUnexpectedReaderDisconnect(reader: Reader) {
        _activity!!.runOnUiThread {
            _onUnexpectedReaderDisconnectSink?.success(reader.toApi())
        }
    }

    override fun onConnectionStatusChange(status: ConnectionStatus) {
        _activity!!.runOnUiThread {
            _onConnectionStatusChangeSink?.success(status.toApi())
        }
    }

    override fun onPaymentStatusChange(status: PaymentStatus) {
        _activity!!.runOnUiThread {
            _onPaymentIntentStatusSink?.success(status.toApi())
        }
    }

    // ======================== INTERNAL METHODS


    private fun findActiveReader(result: Result<*>, serialNumber: String): Reader? {
        val reader = _discoveredReaders.firstOrNull { it.serialNumber == serialNumber }
        if (reader == null) {
            result.error(
                TerminalException.TerminalErrorCode.READER_CONNECTED_TO_ANOTHER_DEVICE.name,
                "Reader with provided serial number no longer exists",
                null
            )
        }
        return reader
    }
}

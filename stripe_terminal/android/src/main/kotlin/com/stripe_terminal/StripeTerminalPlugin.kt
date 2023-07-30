package com.stripe_terminal

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.TerminalApplicationDelegate
import com.stripe.stripeterminal.external.callable.Callback
import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.ConnectionTokenCallback
import com.stripe.stripeterminal.external.callable.ConnectionTokenProvider
import com.stripe.stripeterminal.external.callable.DiscoveryListener
import com.stripe.stripeterminal.external.callable.LocationListCallback
import com.stripe.stripeterminal.external.callable.PaymentIntentCallback
import com.stripe.stripeterminal.external.callable.PaymentMethodCallback
import com.stripe.stripeterminal.external.callable.ReaderCallback
import com.stripe.stripeterminal.external.callable.TerminalListener
import com.stripe.stripeterminal.external.models.CollectConfiguration
import com.stripe.stripeterminal.external.models.ConnectionConfiguration
import com.stripe.stripeterminal.external.models.ConnectionStatus
import com.stripe.stripeterminal.external.models.ConnectionTokenException
import com.stripe.stripeterminal.external.models.DeviceType
import com.stripe.stripeterminal.external.models.DiscoveryConfiguration
import com.stripe.stripeterminal.external.models.DiscoveryMethod
import com.stripe.stripeterminal.external.models.ListLocationsParameters
import com.stripe.stripeterminal.external.models.Location
import com.stripe.stripeterminal.external.models.PaymentIntent
import com.stripe.stripeterminal.external.models.PaymentMethod
import com.stripe.stripeterminal.external.models.PaymentStatus
import com.stripe.stripeterminal.external.models.ReadReusableCardParameters
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.TerminalException
import com.stripe.stripeterminal.log.LogLevel
import com.stripe_terminal.api.CartApi
import com.stripe_terminal.api.ConnectionStatusApi
import com.stripe_terminal.api.DiscoverReadersControllerApi
import com.stripe_terminal.api.DiscoveryMethodApi
import com.stripe_terminal.api.LocationApi
import com.stripe_terminal.api.PaymentIntentApi
import com.stripe_terminal.api.PaymentMethodApi
import com.stripe_terminal.api.PlatformException
import com.stripe_terminal.api.ReaderApi
import com.stripe_terminal.api.Result
import com.stripe_terminal.api.StripeTerminalHandlersApi
import com.stripe_terminal.api.StripeTerminalPlatformApi
import com.stripe_terminal.api.toApi
import com.stripe_terminal.api.toHost
import com.stripe_terminal.plugin.ReaderDelegatePlugin
import com.stripe_terminal.plugin.ReaderReconnectionListenerPlugin
import com.stripe_terminal.plugin.TerminalErrorHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger

class StripeTerminalPlugin : FlutterPlugin, ActivityAware,
    StripeTerminalPlatformApi,
    ConnectionTokenProvider, TerminalListener {
    private lateinit var _handlers: StripeTerminalHandlersApi
    private lateinit var _discoverReadersController: DiscoverReadersControllerApi

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

    override fun onInit() {
        val permissionStatus = permissions.map {
            ContextCompat.checkSelfPermission(_activity!!, it)
        }

        if (permissionStatus.contains(PackageManager.PERMISSION_DENIED)) {
            throw PlatformException(
                "stripeTerminal#permissionDeclinedPermanenty",
                "You have declined the necessary permission, please allow from settings to continue.",
                null
            )
        }

        // If a hot restart is performed in flutter the terminal is already initialized but we need to clean it up
        if (Terminal.isInitialized()) {
            clean()
            return
        }

        Terminal.initTerminal(
            _activity!!.applicationContext,
            LogLevel.NONE,
            this,
            this,
        )
    }

    //region Terminal listeners
    override fun fetchConnectionToken(callback: ConnectionTokenCallback) {
        _activity!!.runOnUiThread {
            _handlers.requestConnectionToken({ code, message, details ->
                val exception = PlatformException(code, message, details)
                callback.onFailure(ConnectionTokenException("", exception))
            }, { token ->
                callback.onSuccess(token)
            })
        }
    }
    //endregion

    //region Reader discovery, connection and updates
    private var _discoverReaderCancelable: Cancelable? = null
    private val _readerDelegate = ReaderDelegatePlugin(_handlers)
    private val _readerReconnectionDelegate = ReaderReconnectionListenerPlugin(_handlers)

    override fun onConnectionStatusChange(status: ConnectionStatus) {
        _activity!!.runOnUiThread {
            _handlers.connectionStatusChange(status.toApi())
        }
    }

    override fun onConnectionStatus(): ConnectionStatusApi {
        return _terminal.connectionStatus.toApi()
    }

    override fun onUnexpectedReaderDisconnect(reader: Reader) {
        _activity!!.runOnUiThread {
            _handlers.unexpectedReaderDisconnect(reader.toApi())
        }
    }

    private fun setupDiscoverReadersController(binaryMessenger: BinaryMessenger) {
        _discoverReadersController = DiscoverReadersControllerApi(binaryMessenger)
        _discoverReadersController.setHandler({ sink, discoveryMethod: DiscoveryMethodApi, simulated: Boolean, locationId: String? ->
            val hostDiscoveryMethod = discoveryMethod.toHost()
            if (hostDiscoveryMethod == null) {
                sink.error("discoveryMethodNotSupported", null, null)
                sink.endOfStream()
                return@setHandler
            }

            val config = DiscoveryConfiguration(
                isSimulated = simulated,
                discoveryMethod = hostDiscoveryMethod,
                location = locationId
            )

            // Ignore error, the previous stream can no longer receive events
            _discoverReaderCancelable?.cancel(EmptyCallback())

            _discoverReaderCancelable =
                _terminal.discoverReaders(config, object : DiscoveryListener {
                    override fun onUpdateDiscoveredReaders(readers: List<Reader>) {
                        _discoveredReaders = readers
                        _activity!!.runOnUiThread { sink.success(readers.map { it.toApi() }) }
                    }
                }, object : TerminalErrorHandler(sink::error), Callback {
                    override fun onFailure(e: TerminalException) = _activity!!.runOnUiThread {
                        super.onFailure(e)
                        sink.endOfStream()
                    }

                    override fun onSuccess() = _activity!!.runOnUiThread { sink.endOfStream() }
                })
        }, {
            // Ignore error, flutter stream already closed
            _discoverReaderCancelable?.cancel(EmptyCallback())
        })
    }

    override fun onConnectBluetoothReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean,
    ) {
        val reader = findActiveReader(result, serialNumber) ?: return

        _terminal.connectBluetoothReader(reader,
            ConnectionConfiguration.BluetoothConnectionConfiguration(
                locationId = locationId,
                autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect,
                bluetoothReaderReconnectionListener = _readerReconnectionDelegate,
            ),
            _readerDelegate,
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            }
        )
    }

    override fun onConnectHandoffReader(
        result: Result<ReaderApi>,
        serialNumber: String,
    ) {
        val reader = findActiveReader(result, serialNumber) ?: return

        _terminal.connectHandoffReader(reader,
            ConnectionConfiguration.HandoffConnectionConfiguration(),
            _readerDelegate,
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            }
        )
    }

    override fun onConnectInternetReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        failIfInUse: Boolean
    ) {
        val reader = findActiveReader(result, serialNumber) ?: return

        _terminal.connectInternetReader(reader,
            ConnectionConfiguration.InternetConnectionConfiguration(
                failIfInUse = failIfInUse,
            ),
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            })
    }

    override fun onConnectMobileReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
    ) {
        val reader = findActiveReader(result, serialNumber) ?: return

        val config = ConnectionConfiguration.LocalMobileConnectionConfiguration(
            locationId = locationId,
        )
        _terminal.connectLocalMobileReader(reader, config,
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            })
    }

    override fun onConnectUsbReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean,
    ) {
        val reader = findActiveReader(result, serialNumber) ?: return

        _terminal.connectUsbReader(reader,
            ConnectionConfiguration.UsbConnectionConfiguration(
                locationId = locationId,
                autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect,
                usbReaderReconnectionListener = _readerReconnectionDelegate,
            ),
            _readerDelegate,
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            }
        )
    }

    override fun onConnectedReader(): ReaderApi? {
        return _terminal.connectedReader?.toApi()
    }

    override fun onCancelReaderReconnection(result: Result<Unit>) {
        if (_readerReconnectionDelegate.cancelReconnect == null) {
            result.success(Unit)
        }
        _readerReconnectionDelegate.cancelReconnect?.cancel(object : Callback, TerminalErrorHandler(result::error) {
            override fun onSuccess() = result.success(Unit)
        })
    }

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

    override fun onInstallAvailableUpdate() {
        _terminal.installAvailableUpdate()
    }

    override fun onCancelReaderUpdate(result: Result<Unit>) {
        if (_readerDelegate.cancelUpdate == null) {
            result.success(Unit)
        }
        _readerDelegate.cancelUpdate?.cancel(object : Callback, TerminalErrorHandler(result::error) {
            override fun onSuccess() = result.success(Unit)
        })
    }

    override fun onDisconnectReader(result: Result<Unit>) {
        _terminal.disconnectReader(object : TerminalErrorHandler(result::error), Callback {
            override fun onSuccess() = result.success(Unit)
        })
    }
    //endregion

    //region Taking Payment
    private var _paymentIntents = HashMap<String, PaymentIntent>()

    override fun onPaymentStatusChange(status: PaymentStatus) {
        _activity!!.runOnUiThread {
            _handlers.paymentStatusChange(status.toApi())
        }
    }

    override fun onRetrievePaymentIntent(
        result: Result<PaymentIntentApi>,
        clientSecret: String
    ) {
        _terminal.retrievePaymentIntent(clientSecret,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    _paymentIntents[paymentIntent.id] = paymentIntent
                    result.success(paymentIntent.toApi())
                }
            })
    }

    private val _cancelablesCollectPaymentMethod = HashMap<Long, Cancelable>()

    override fun onStartCollectPaymentMethod(
        result: Result<PaymentIntentApi>,
        operationId: Long,
        paymentIntentId: String,
        moto: Boolean,
        skipTipping: Boolean,
    ) {
        val paymentIntent = _paymentIntents[paymentIntentId]
        if (paymentIntent == null) {
            result.error("", "")
            return
        }
        _cancelablesCollectPaymentMethod[operationId] = _terminal.collectPaymentMethod(
            paymentIntent,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onFailure(e: TerminalException) {
                    _cancelablesCollectPaymentMethod.remove(operationId)
                    super.onFailure(e)
                }

                override fun onSuccess(paymentIntent: PaymentIntent) {
                    _cancelablesCollectPaymentMethod.remove(operationId)
                    result.success(paymentIntent.toApi())
                    _paymentIntents[paymentIntent.id] = paymentIntent
                }
            },
            CollectConfiguration.Builder()
                .setMoto(moto)
                .skipTipping(skipTipping)
                .build(),
        )
    }

    override fun onStopCollectPaymentMethod(result: Result<Unit>, operationId: Long) {
        _cancelablesCollectPaymentMethod.remove(operationId)
            ?.cancel(object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            })
    }

    override fun onProcessPayment(
        result: Result<PaymentIntentApi>,
        paymentIntentId: String,
    ) {
        val paymentIntent = _paymentIntents[paymentIntentId]
        if (paymentIntent == null) {
            result.error("", "")
            return
        }
        _terminal.processPayment(
            paymentIntent,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    result.success(paymentIntent.toApi())
                    _paymentIntents.remove(paymentIntent.id)
                }
            })
    }
    //endregion

    //region Saving payment details for later use
    private val _cancelablesReadReusableCard = HashMap<Long, Cancelable>()

    override fun onStartReadReusableCard(
        result: Result<PaymentMethodApi>,
        operationId: Long,
        customer: String?,
        metadata: HashMap<String, String>?,
    ) {
        val params = ReadReusableCardParameters.Builder()
        if (customer != null) params.setCustomer(customer)
        if (metadata != null) params.putAllMetadata(metadata)
        _cancelablesReadReusableCard[operationId] = _terminal.readReusableCard(params.build(),
            object : TerminalErrorHandler(result::error), PaymentMethodCallback {
                override fun onFailure(e: TerminalException) {
                    _cancelablesReadReusableCard.remove(operationId)
                    super.onFailure(e)
                }

                override fun onSuccess(paymentMethod: PaymentMethod) {
                    _cancelablesReadReusableCard.remove(operationId)
                    result.success(paymentMethod.toApi())
                }
            })
    }

    override fun onStopReadReusableCard(
        result: Result<Unit>,
        operationId: Long,
    ) {
        _cancelablesReadReusableCard.remove(operationId)
            ?.cancel(object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            })
    }
    //endregion

    //region Display information to customers
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

    //region Android
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val binaryMessenger = flutterPluginBinding.binaryMessenger
        StripeTerminalPlatformApi.setHandler(binaryMessenger, this)
        _handlers = StripeTerminalHandlersApi(binaryMessenger)

        setupDiscoverReadersController(binaryMessenger)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        clean()

        _discoverReadersController.removeHandler()
        StripeTerminalPlatformApi.removeHandler()
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
    //endregion

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

    private fun clean() {
        if (_terminal.connectedReader != null) _terminal.disconnectReader(EmptyCallback())

        _discoverReaderCancelable?.cancel(EmptyCallback())
        _discoverReaderCancelable = null

        _cancelablesReadReusableCard.values.forEach { it.cancel(EmptyCallback()) }
        _cancelablesReadReusableCard.clear()
        _cancelablesCollectPaymentMethod.values.forEach { it.cancel(EmptyCallback()) }
        _cancelablesCollectPaymentMethod.clear()

        _discoveredReaders = arrayListOf()
        _paymentIntents = hashMapOf()
    }
}

class EmptyCallback : Callback {
    override fun onFailure(e: TerminalException) {}
    override fun onSuccess() {}
}

package com.stripe_terminal

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.external.callable.*
import com.stripe.stripeterminal.external.models.*
import com.stripe.stripeterminal.external.callable.ConnectionTokenProvider
import com.stripe.stripeterminal.log.LogLevel
import com.stripe_terminal.api.CartApi
import com.stripe_terminal.api.CollectConfigurationApi
import com.stripe_terminal.api.ConnectionStatusApi
import com.stripe_terminal.api.DiscoverConfigApi
import com.stripe_terminal.api.LocationApi
import com.stripe_terminal.api.StripePaymentIntentApi
import com.stripe_terminal.api.StripePaymentMethodApi
import com.stripe_terminal.api.StripeReaderApi
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import kotlinx.coroutines.runBlocking
import com.stripe_terminal.api.StripeTerminalApi
import com.stripe_terminal.api.Result
import com.stripe_terminal.api.toApi
import com.stripe_terminal.api.toHost
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.Dispatchers


/** StripeTerminalPlugin */
class StripeTerminalPlugin : FlutterPlugin, StripeTerminalApi(), ActivityAware,
    ConnectionTokenProvider
//    , PluginRegistry.RequestPermissionsResultListener, ActivityAware, FlutterActivityEvents
{
    //
//    private lateinit var channel: MethodChannel
    private val REQUEST_CODE_LOCATION = 1012

    //    private lateinit var tokenProvider: StripeTokenProvider
//    private var cancelableDiscover: Cancelable? = null
//    private var activeReaders: List<Reader> = arrayListOf()
//    private var simulated = false
    private val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        arrayOf(
//            Manifest.permission.ACCESS_FINE_LOCATION,
//            Manifest.permission.BLUETOOTH,
//            Manifest.permission.BLUETOOTH_ADMIN,
            Manifest.permission.BLUETOOTH_SCAN,
//            Manifest.permission.BLUETOOTH_CONNECT,
        )
    } else {
        arrayOf(
//            Manifest.permission.ACCESS_FINE_LOCATION,
//            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN,
        )
    }

    //
//
//    // Change this to other level soon
//    private val logLevel = LogLevel.VERBOSE
//
    // Create your listener object. Override any methods that you want to be notified about
    private val listener = object : TerminalListener {
        override fun onUnexpectedReaderDisconnect(reader: Reader) {
            // TODO: Trigger the user about the issue.
        }
    }

    //    var result: Result? = null
    private fun requestPermissions(result: Result<Unit>): Boolean {
        val permissionStatus = permissions.map {
            ContextCompat.checkSelfPermission(currentActivity!!, it)
        }

        if (permissionStatus.contains(PackageManager.PERMISSION_DENIED)) {
            result.error(
                "stripeTerminal#permissionDeclinedPermanenty",
                "You have declined the necessary permission, please allow from settings to continue.",
                null
            )
            return false
        }

        if (Terminal.isInitialized()) {
            result.success(Unit)
            return true
        }

        Terminal.initTerminal(
            currentActivity!!.applicationContext,
            LogLevel.NONE,
            this,
            listener
        )
        result.success(Unit)
        return true


//        val cannotAskPermissions = permissions.map {
//            ActivityCompat.shouldShowRequestPermissionRationale(currentActivity!!, it)
//        }
//
//        if (cannotAskPermissions.contains(true)) {

//        }
//
//        this.result = result
//
//        ActivityCompat.requestPermissions(currentActivity!!, permissions, REQUEST_CODE_LOCATION)
//
//        return false
    }


    private var currentActivity: Activity? = null
    private var activeReaders: List<Reader> = arrayListOf()

    override fun onInit(result: Result<Unit>) {
        requestPermissions(result)
//        Terminal.initTerminal(
//            currentActivity!!.applicationContext,
//            LogLevel.NONE,
//            this,
//            listener
//        )
//        result.success(Unit)
    }

    override fun onConnectBluetoothReader(
        result: Result<StripeReaderApi>,
        readerSerialNumber: String,
        locationId: String
    ) {
        ensureStatusIs(result, ConnectionStatus.NOT_CONNECTED) ?: return

        val reader = findActiveReader(result, readerSerialNumber) ?: return

        val config = ConnectionConfiguration.BluetoothConnectionConfiguration(
            locationId = locationId,
        )
        Terminal.getInstance().connectBluetoothReader(
            reader,
            config,
            object : BluetoothReaderListener {},
            object : TerminalErrorHandler(result), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            }
        )
    }

    override fun onConnectInternetReader(
        result: Result<StripeReaderApi>,
        readerSerialNumber: String,
        failIfInUse: Boolean
    ) {
        ensureStatusIs(result, ConnectionStatus.NOT_CONNECTED) ?: return

        val reader = findActiveReader(result, readerSerialNumber) ?: return

        val connectionConfig =
            ConnectionConfiguration.InternetConnectionConfiguration(
                failIfInUse = failIfInUse
            )
        Terminal.getInstance().connectInternetReader(
            reader,
            connectionConfig,
            object : TerminalErrorHandler(result), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            })
    }

    override fun onConnectMobileReader(
        result: Result<StripeReaderApi>,
        readerSerialNumber: String,
        locationId: String,
    ) {
        ensureStatusIs(result, ConnectionStatus.NOT_CONNECTED) ?: return

        val reader = findActiveReader(result, readerSerialNumber) ?: return

        val config = ConnectionConfiguration.LocalMobileConnectionConfiguration(
            locationId = locationId
        )
        Terminal.getInstance().connectLocalMobileReader(
            reader,
            config,
            object : TerminalErrorHandler(result), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            })
    }

    override fun onListLocations(result: Result<List<LocationApi>>) {
        val params = ListLocationsParameters.Builder().build()
        Terminal.getInstance()
            .listLocations(params, object : TerminalErrorHandler(result), LocationListCallback {
                override fun onSuccess(locations: List<Location>, hasMore: Boolean) =
                    result.success(locations.map { it.toApi() })
            })
    }

    override fun onDisconnectReader(result: Result<Unit>) {
        Terminal.getInstance().disconnectReader(object : TerminalErrorHandler(result), Callback {
            override fun onSuccess() = result.success(Unit)
        })
//                if (Terminal.getInstance().connectedReader != null) {} else {
//                    result.error(
//                        "stripeTerminal#unableToDisconnect",
//                        "No reader connected to disconnect from.",
//                        null
//                    )
//                }
    }

    override fun onSetReaderDisplay(result: Result<Unit>, cart: CartApi) {
        Terminal.getInstance()
            .setReaderDisplay(cart.toHost(), object : TerminalErrorHandler(result), Callback {
                override fun onSuccess() = result.success(Unit)
            })
    }

    override fun onClearReaderDisplay(result: Result<Unit>) {
        Terminal.getInstance().clearReaderDisplay(object : TerminalErrorHandler(result), Callback {
            override fun onSuccess() = result.success(Unit)
        })
    }

    override fun onConnectionStatus(result: Result<ConnectionStatusApi>) {
        result.success(Terminal.getInstance().connectionStatus.toApi())
    }

    override fun onFetchConnectedReader(result: Result<StripeReaderApi?>) {
        result.success(Terminal.getInstance().connectedReader?.toApi())
    }

    override fun onReadReusableCardDetail(result: Result<StripePaymentMethodApi>) {
        ensureStatusIs(result, ConnectionStatus.CONNECTED) ?: return

        val params = ReadReusableCardParameters.Builder().build()
        Terminal.getInstance()
            .readReusableCard(params, object : TerminalErrorHandler(result), PaymentMethodCallback {
                override fun onSuccess(paymentMethod: PaymentMethod) =
                    result.success(paymentMethod.toApi())
            })
    }

    override fun onRetrievePaymentIntent(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String
    ) {
        ensureStatusIs(result, ConnectionStatus.CONNECTED) ?: return

        Terminal.getInstance().retrievePaymentIntent(
            clientSecret,
            object : TerminalErrorHandler(result), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) =
                    result.success(paymentIntent.toApi())
            })
    }

    override fun onCollectPaymentMethod(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String,
        collectConfiguration: CollectConfigurationApi
    ) {
        ensureStatusIs(result, ConnectionStatus.CONNECTED) ?: return

        Terminal.getInstance().retrievePaymentIntent(
            clientSecret,
            object : TerminalErrorHandler(result), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    Terminal.getInstance().collectPaymentMethod(
                        paymentIntent,
                        object : TerminalErrorHandler(result), PaymentIntentCallback {
                            override fun onSuccess(paymentIntent: PaymentIntent) =
                                result.success(paymentIntent.toApi())
                        },
                        CollectConfiguration.Builder().skipTipping(collectConfiguration.skipTipping)
                            .build(),
                    )
                }
            })
    }

    override fun onProcessPayment(
        result: Result<StripePaymentIntentApi>,
        clientSecret: String,
    ) {
        ensureStatusIs(result, ConnectionStatus.CONNECTED) ?: return

        Terminal.getInstance().retrievePaymentIntent(
            clientSecret,
            object : TerminalErrorHandler(result), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    Terminal.getInstance().processPayment(
                        paymentIntent,
                        object : TerminalErrorHandler(result), PaymentIntentCallback {
                            override fun onSuccess(paymentIntent: PaymentIntent) =
                                result.success(paymentIntent.toApi())
                        })
                }
            })
    }

    private var discoverReaderCancelable: Cancelable? = null

    override fun onStartDiscoverReaders(result: Result<Unit>, config: DiscoverConfigApi) {
        discoverReaderCancelable =
            Terminal.getInstance().discoverReaders(config.toHost(), object : DiscoveryListener {
                override fun onUpdateDiscoveredReaders(readers: List<Reader>) {
                    activeReaders = readers
                    runBlocking(Dispatchers.Main) {
                        readersFound(readers.map { it.toApi() })
                    }
                }
            }, object : TerminalErrorHandler(result), Callback {
                override fun onSuccess() = result.success(Unit)
            })
    }

    override fun onStopDiscoverReaders(result: Result<Unit>) {
        discoverReaderCancelable?.cancel(object : TerminalErrorHandler(result), Callback {
            override fun onSuccess() {
                discoverReaderCancelable = null
                result.success(Unit)
            }
        }) ?: result.success(Unit)
    }

    // ======================== ACTIVITY AWARE

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
//        TerminalApplicationDelegate.onCreate(currentActivity!!.application)
//        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        currentActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
//        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        currentActivity = null
    }

    // ======================== STRIPE

    override fun fetchConnectionToken(callback: ConnectionTokenCallback) {
        runBlocking(Dispatchers.Main) {
            try {
                val token = requestConnectionToken()
                callback.onSuccess(token)
            } catch (error: Throwable) {
                callback.onFailure(ConnectionTokenException("", error))
            }
        }
    }

    // ======================== INTERNAL METHODS


    private fun ensureStatusIs(result: Result<*>, targetStatus: ConnectionStatus): Any? {
//        val currentStatus = Terminal.getInstance().connectionStatus
//        if (currentStatus == targetStatus) return true
//        when (currentStatus) {
//            ConnectionStatus.NOT_CONNECTED -> {
//                result.error(
//                    TerminalException.TerminalErrorCode.NOT_CONNECTED_TO_READER.name,
//                    "You must connect to a device before you can use it.",
//                    null
//                )
//            }
//
//            ConnectionStatus.CONNECTING -> {
//                result.error(
//                    TerminalException.TerminalErrorCode.READER_BUSY.name,
//                    "A new connection is being established with a device thus you cannot request a new connection at the moment.",
//                    null
//                )
//
//            }
//
//            ConnectionStatus.CONNECTED -> {
//                result.error(
//                    TerminalException.TerminalErrorCode.ALREADY_CONNECTED_TO_READER.name,
//                    "A device with serial number ${Terminal.getInstance().connectedReader!!.serialNumber} is already connected",
//                    null
//                )
//            }
//        }
        return true
    }

    private fun findActiveReader(result: Result<*>, serialNumber: String): Reader? {
        val reader = activeReaders.firstOrNull { it.serialNumber == serialNumber }
        if (reader == null) {
            result.error(
                TerminalException.TerminalErrorCode.READER_CONNECTED_TO_ANOTHER_DEVICE.name,
                "Reader with provided serial number no longer exists",
                null
            )
        }
        return reader
    }

    //    override fun onRequestPermissionsResult(
//        requestCode: Int,
//        permissions: Array<out String>,
//        grantResults: IntArray
//    ): Boolean {
//        val permissionStatus = permissions.map {
//            ContextCompat.checkSelfPermission(currentActivity!!, it)
//        }
//        if (permissionStatus.contains(PackageManager.PERMISSION_DENIED)) {
//            result?.error(
//                "stripeTerminal#insuffecientPermission",
//                "You have not provided enough permission for the scanner to work",
//                null
//            )
//        } else {
//            _startStripe()
//        }
//        return requestCode == REQUEST_CODE_LOCATION
//    }
//
//
//    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
//        channel.setMethodCallHandler(null)
//        if (Terminal.getInstance().connectedReader != null) {
//            Terminal.getInstance().disconnectReader(object : Callback {
//                override fun onFailure(e: TerminalException) {
//                }
//
//                override fun onSuccess() {
//                }
//            })
//        }
//        cancelableDiscover?.cancel(
//            object : Callback {
//                override fun onFailure(e: TerminalException) {
//                }
//
//                override fun onSuccess() {
//                }
//            }
//        )
//        cancelableDiscover = null
//    }
//
//    /*
//     These functions are stub functions that are not relevent to the plugin but needs to be defined in order to get the few necessary callbacks
//    */
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        TODO("Not yet implemented")
//    }
//
//    override fun onNewIntent(intent: Intent?) {
//        TODO("Not yet implemented")
//    }
//
//    override fun onPause() {
//        TODO("Not yet implemented")
//    }
//
//    override fun onStart() {
//        TODO("Not yet implemented")
//    }
//
//    override fun onResume() {
//        TODO("Not yet implemented")
//    }
//
//    override fun onPostResume() {
//        TODO("Not yet implemented")
//    }
//
//    override fun onDestroy() {
//        TODO("Not yet implemented")
//    }
//
//    override fun onStop() {
//        TODO("Not yet implemented")
//    }
//
//    override fun onBackPressed(): Boolean {
//        TODO("Not yet implemented")
//    }
//
//    override fun onUserLeaveHint() {
//        TODO("Not yet implemented")
//    }
//
//    override fun onConfigurationChanged(p0: Configuration) {
//        TODO("Not yet implemented")
//    }
//
//    override fun onLowMemory() {
//        TODO("Not yet implemented")
//    }
//
//    override fun onTrimMemory(p0: Int) {
//        TerminalApplicationDelegate.onTrimMemory(currentActivity!!.application, p0)
//    }
//
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
//        TODO("Not yet implemented")
//    }
}


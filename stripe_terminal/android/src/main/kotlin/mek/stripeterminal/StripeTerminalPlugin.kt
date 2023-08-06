package mek.stripeterminal

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.TerminalApplicationDelegate
import com.stripe.stripeterminal.external.callable.Callback
import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.DiscoveryListener
import com.stripe.stripeterminal.external.callable.LocationListCallback
import com.stripe.stripeterminal.external.callable.PaymentIntentCallback
import com.stripe.stripeterminal.external.callable.PaymentMethodCallback
import com.stripe.stripeterminal.external.callable.ReaderCallback
import com.stripe.stripeterminal.external.callable.RefundCallback
import com.stripe.stripeterminal.external.callable.SetupIntentCallback
import com.stripe.stripeterminal.external.models.CaptureMethod
import com.stripe.stripeterminal.external.models.CollectConfiguration
import com.stripe.stripeterminal.external.models.ConnectionConfiguration
import com.stripe.stripeterminal.external.models.DiscoveryConfiguration
import com.stripe.stripeterminal.external.models.ListLocationsParameters
import com.stripe.stripeterminal.external.models.Location
import com.stripe.stripeterminal.external.models.PaymentIntent
import com.stripe.stripeterminal.external.models.PaymentIntentParameters
import com.stripe.stripeterminal.external.models.PaymentMethod
import com.stripe.stripeterminal.external.models.PaymentMethodType
import com.stripe.stripeterminal.external.models.ReadReusableCardParameters
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.Refund
import com.stripe.stripeterminal.external.models.RefundParameters
import com.stripe.stripeterminal.external.models.SetupIntent
import com.stripe.stripeterminal.external.models.SetupIntentCancellationParameters
import com.stripe.stripeterminal.external.models.SetupIntentParameters
import com.stripe.stripeterminal.external.models.TerminalException
import com.stripe.stripeterminal.log.LogLevel
import mek.stripeterminal.api.CartApi
import mek.stripeterminal.api.ConnectionStatusApi
import mek.stripeterminal.api.DeviceTypeApi
import mek.stripeterminal.api.DiscoverReadersControllerApi
import mek.stripeterminal.api.DiscoveryMethodApi
import mek.stripeterminal.api.LocationApi
import mek.stripeterminal.api.PaymentIntentApi
import mek.stripeterminal.api.PaymentMethodApi
import mek.stripeterminal.api.PlatformException
import mek.stripeterminal.api.ReaderApi
import mek.stripeterminal.api.Result
import mek.stripeterminal.api.StripeTerminalHandlersApi
import mek.stripeterminal.api.StripeTerminalPlatformApi
import mek.stripeterminal.api.toApi
import mek.stripeterminal.api.toHost
import mek.stripeterminal.plugin.ReaderDelegatePlugin
import mek.stripeterminal.plugin.ReaderReconnectionListenerPlugin
import mek.stripeterminal.plugin.TerminalErrorHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import mek.stripeterminal.api.CaptureMethodApi
import mek.stripeterminal.api.PaymentIntentParametersApi
import mek.stripeterminal.api.PaymentMethodTypeApi
import mek.stripeterminal.api.PaymentStatusApi
import mek.stripeterminal.api.RefundApi
import mek.stripeterminal.api.SetupIntentApi
import mek.stripeterminal.api.SetupIntentUsageApi
import mek.stripeterminal.api.TerminalExceptionCodeApi
import mek.stripeterminal.plugin.TerminalDelegatePlugin

class StripeTerminalPlugin : FlutterPlugin, ActivityAware, StripeTerminalPlatformApi {
    private lateinit var _handlers: StripeTerminalHandlersApi

    private var _activity: Activity? = null
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

    private val _terminal: Terminal get() = Terminal.getInstance()

    override fun onInit(shouldPrintLogs: Boolean) {
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

        TerminalApplicationDelegate.onCreate(_activity!!.application)
        val delegate = TerminalDelegatePlugin(_handlers)
        Terminal.initTerminal(
            _activity!!.applicationContext,
            if (shouldPrintLogs) LogLevel.VERBOSE else LogLevel.NONE,
            delegate,
            delegate,
        )
    }

    override fun onClearCachedCredentials() = _terminal.clearCachedCredentials()

    //region Reader discovery, connection and updates
    private lateinit var _discoverReadersController: DiscoverReadersControllerApi
    private var _discoverReaderCancelable: Cancelable? = null
    private var _discoveredReaders: List<Reader> = arrayListOf()
    private lateinit var _readerDelegate: ReaderDelegatePlugin
    private lateinit var _readerReconnectionDelegate: ReaderReconnectionListenerPlugin

    override fun onGetConnectionStatus(): ConnectionStatusApi = _terminal.connectionStatus.toApi()

    override fun onSupportsReadersOfType(
        deviceType: DeviceTypeApi,
        discoveryMethod: DiscoveryMethodApi,
        simulated: Boolean
    ): Boolean {
        val hostDeviceType = deviceType.toHost() ?: return false
        val hostDiscoveryMethod = discoveryMethod.toHost() ?: return false
        val result = _terminal.supportsReadersOfType(
            deviceType = hostDeviceType,
            discoveryMethod = hostDiscoveryMethod,
            simulated = simulated
        )
        return result.isSupported
    }

    private fun setupDiscoverReadersController(binaryMessenger: BinaryMessenger) {
        _discoverReadersController = DiscoverReadersControllerApi(binaryMessenger)
        _discoverReadersController.setHandler({ sink, discoveryMethod: DiscoveryMethodApi, simulated: Boolean, locationId: String? ->
            val hostDiscoveryMethod = discoveryMethod.toHost()
            if (hostDiscoveryMethod == null) {
                sink.error("", "Discovery method not supported: $discoveryMethod", null)
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
                        runOnMainThread { sink.success(readers.map { it.toApi() }) }
                    }
                }, object : TerminalErrorHandler(sink::error), Callback {
                    override fun onFailure(e: TerminalException) = runOnMainThread {
                        super.onFailure(e)
                        sink.endOfStream()
                    }

                    override fun onSuccess() = runOnMainThread { sink.endOfStream() }
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

    override fun onGetConnectedReader(): ReaderApi? = _terminal.connectedReader?.toApi()

    override fun onCancelReaderReconnection(result: Result<Unit>) {
        if (_readerReconnectionDelegate.cancelReconnect == null) {
            result.success(Unit)
        }
        _readerReconnectionDelegate.cancelReconnect?.cancel(object : Callback,
            TerminalErrorHandler(result::error) {
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

    override fun onInstallAvailableUpdate() = _terminal.installAvailableUpdate()

    override fun onCancelReaderUpdate(result: Result<Unit>) {
        if (_readerDelegate.cancelUpdate == null) {
            result.success(Unit)
        }
        _readerDelegate.cancelUpdate?.cancel(object : Callback,
            TerminalErrorHandler(result::error) {
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

    override fun onGetPaymentStatus(): PaymentStatusApi = _terminal.paymentStatus.toApi()

    override fun onCreatePaymentIntent(
        result: Result<PaymentIntentApi>,
        parameters: PaymentIntentParametersApi
    ) {
        _terminal.createPaymentIntent(
            PaymentIntentParameters.Builder(
                amount = parameters.amount,
                currency = parameters.currency,
                captureMethod = when (parameters.captureMethod) {
                    CaptureMethodApi.MANUAL -> CaptureMethod.Manual
                    CaptureMethodApi.AUTOMATIC -> CaptureMethod.Automatic
                },
                allowedPaymentMethodTypes = parameters.paymentMethodTypes.map {
                    when (it) {
                        PaymentMethodTypeApi.CARD_PRESENT -> PaymentMethodType.CARD_PRESENT
                        PaymentMethodTypeApi.CARD -> PaymentMethodType.CARD
                        PaymentMethodTypeApi.INTERACT_PRESENT -> PaymentMethodType.INTERAC_PRESENT
                    }
                },
            ).build(), object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    _paymentIntents[paymentIntent.id] = paymentIntent
                    result.success(paymentIntent.toApi())
                }
            })
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

    private var _cancelablesCollectPaymentMethod = HashMap<Long, Cancelable>()

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
        val paymentIntent = findPaymentIntent(result, paymentIntentId) ?: return
        _terminal.processPayment(
            paymentIntent,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    result.success(paymentIntent.toApi())
                    _paymentIntents.remove(paymentIntent.id)
                }
            })
    }

    override fun onCancelPaymentIntent(result: Result<PaymentIntentApi>, paymentIntentId: String) {
        val paymentIntent = findPaymentIntent(result, paymentIntentId) ?: return
        _terminal.cancelPaymentIntent(
            paymentIntent,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    _paymentIntents.remove(paymentIntentId)
                    result.success(paymentIntent.toApi())
                }
            })
    }
    //endregion

    //region Saving payment details for later use
    private var _cancelablesReadReusableCard = HashMap<Long, Cancelable>()
    private var _setupIntents = HashMap<String, SetupIntent>()
    private var _cancelablesCollectSetupIntentPaymentMethod = HashMap<Long, Cancelable>()

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

    override fun onCreateSetupIntent(
        result: Result<SetupIntentApi>,
        customerId: String?,
        metadata: HashMap<String, String>?,
        onBehalfOf: String?,
        description: String?,
        usage: SetupIntentUsageApi?
    ) {
        _terminal.createSetupIntent(
            SetupIntentParameters.Builder()
                .setCustomer(customerId)
                .setMetadata(metadata)
                .setOnBehalfOf(onBehalfOf)
                .setDescription(description)
                .setUsage(usage?.toHost())
                .build(),
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    _setupIntents[setupIntent.id] = setupIntent
                    result.success(setupIntent.toApi())
                }
            }
        )
    }

    override fun onRetrieveSetupIntent(result: Result<SetupIntentApi>, clientSecret: String) {
        _terminal.retrieveSetupIntent(
            clientSecret,
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    _setupIntents[setupIntent.id] = setupIntent
                    result.success(setupIntent.toApi())
                }
            })
    }

    override fun onStartCollectSetupIntentPaymentMethod(
        result: Result<SetupIntentApi>,
        operationId: Long,
        setupIntentId: String,
        customerConsentCollected: Boolean
    ) {
        val setupIntent = findSetupIntent(result, setupIntentId) ?: return
        _cancelablesCollectSetupIntentPaymentMethod[operationId] =
            _terminal.collectSetupIntentPaymentMethod(
                setupIntent,
                customerConsentCollected,
                object : TerminalErrorHandler(result::error), SetupIntentCallback {
                    override fun onFailure(e: TerminalException) {
                        _cancelablesCollectSetupIntentPaymentMethod.remove(operationId)
                        super.onFailure(e)
                    }

                    override fun onSuccess(setupIntent: SetupIntent) {
                        _cancelablesCollectSetupIntentPaymentMethod.remove(operationId)
                        _setupIntents[setupIntent.id] = setupIntent
                        result.success(setupIntent.toApi())
                    }
                })
    }

    override fun onStopCollectSetupIntentPaymentMethod(result: Result<Unit>, operationId: Long) {
        _cancelablesCollectSetupIntentPaymentMethod.remove(operationId)
            ?.cancel(object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            })
    }

    override fun onConfirmSetupIntent(result: Result<SetupIntentApi>, setupIntentId: String) {
        val setupIntent = findSetupIntent(result, setupIntentId) ?: return
        _terminal.confirmSetupIntent(
            setupIntent,
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    _setupIntents[setupIntent.id] = setupIntent
                    result.success(setupIntent.toApi())
                }
            })
    }

    override fun onCancelSetupIntent(result: Result<SetupIntentApi>, setupIntentId: String) {
        val setupIntent = findSetupIntent(result, setupIntentId) ?: return
        _terminal.cancelSetupIntent(
            setupIntent,
            SetupIntentCancellationParameters.Builder().build(),
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    _setupIntents.remove(setupIntent.id)
                    result.success(setupIntent.toApi())
                }
            })
    }
    //endregion

    //region Saving payment details for later use
    private var _cancelablesCollectRefundPaymentMethod = HashMap<Long, Cancelable>()

    override fun onStartCollectRefundPaymentMethod(
        result: Result<Unit>,
        operationId: Long,
        chargeId: String,
        amount: Long,
        currency: String,
        metadata: HashMap<String, String>?,
        reverseTransfer: Boolean?,
        refundApplicationFee: Boolean?
    ) {
        _cancelablesCollectRefundPaymentMethod[operationId] = _terminal.collectRefundPaymentMethod(
            RefundParameters.Builder(
                chargeId = chargeId,
                amount = amount,
                currency = currency,
            ).let {
                metadata?.let(it::setMetadata)
                reverseTransfer?.let(it::setReverseTransfer)
                refundApplicationFee?.let(it::setRefundApplicationFee)
                it.build()
            },
            object : TerminalErrorHandler(result::error), Callback {
                override fun onFailure(e: TerminalException) {
                    _cancelablesCollectRefundPaymentMethod.remove(operationId)
                    super.onFailure(e)
                }

                override fun onSuccess() {
                    _cancelablesCollectRefundPaymentMethod.remove(operationId)
                    result.success(Unit)
                }
            })
    }

    override fun onStopCollectRefundPaymentMethod(result: Result<Unit>, operationId: Long) {
        _cancelablesCollectRefundPaymentMethod.remove(operationId)
            ?.cancel(object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            })
    }

    override fun onProcessRefund(result: Result<RefundApi>) {
        _terminal.processRefund(object : TerminalErrorHandler(result::error), RefundCallback {
            override fun onSuccess(refund: Refund) = result.success(refund.toApi())
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

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val binaryMessenger = flutterPluginBinding.binaryMessenger
        StripeTerminalPlatformApi.setHandler(binaryMessenger, this)
        _handlers = StripeTerminalHandlersApi(binaryMessenger)
        _readerDelegate = ReaderDelegatePlugin(_handlers)
        _readerReconnectionDelegate = ReaderReconnectionListenerPlugin(_handlers)

        setupDiscoverReadersController(binaryMessenger)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        clean()

        _discoverReadersController.removeHandler()
        StripeTerminalPlatformApi.removeHandler()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        _activity = binding.activity
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

    private fun findPaymentIntent(result: Result<*>, paymentIntentId: String): PaymentIntent? {
        val paymentIntent = _paymentIntents[paymentIntentId]
        if (paymentIntent == null) {
            result.error(
                TerminalExceptionCodeApi.PAYMENT_INTENT_NOT_RETRIEVED.name,
                null,
                null
            )
        }
        return paymentIntent
    }

    private fun findSetupIntent(result: Result<*>, setupIntentId: String): SetupIntent? {
        val setupIntent = _setupIntents[setupIntentId]
        if (setupIntent == null) {
            result.error(
                TerminalExceptionCodeApi.PAYMENT_INTENT_NOT_RETRIEVED.name,
                null,
                null
            )
        }
        return setupIntent
    }

    private fun clean() {
        if (_terminal.connectedReader != null) _terminal.disconnectReader(EmptyCallback())

        _discoverReaderCancelable?.cancel(EmptyCallback())
        _discoverReaderCancelable = null
        _discoveredReaders = arrayListOf()

        _cancelablesCollectPaymentMethod.values.forEach { it.cancel(EmptyCallback()) }
        _cancelablesCollectPaymentMethod = hashMapOf()
        _paymentIntents = hashMapOf()

        _cancelablesReadReusableCard.values.forEach { it.cancel(EmptyCallback()) }
        _cancelablesReadReusableCard = hashMapOf()
        _cancelablesCollectSetupIntentPaymentMethod.values.forEach { it.cancel(EmptyCallback()) }
        _cancelablesCollectSetupIntentPaymentMethod = hashMapOf()
        _setupIntents = hashMapOf()

        _cancelablesCollectRefundPaymentMethod.values.forEach { it.cancel(EmptyCallback()) }
        _cancelablesCollectRefundPaymentMethod = hashMapOf()
    }
}

class EmptyCallback : Callback {
    override fun onFailure(e: TerminalException) {}
    override fun onSuccess() {}
}

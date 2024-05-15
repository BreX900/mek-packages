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
import com.stripe.stripeterminal.external.callable.LocationListCallback
import com.stripe.stripeterminal.external.callable.PaymentIntentCallback
import com.stripe.stripeterminal.external.callable.ReaderCallback
import com.stripe.stripeterminal.external.callable.RefundCallback
import com.stripe.stripeterminal.external.callable.SetupIntentCallback
import com.stripe.stripeterminal.external.models.CollectConfiguration
import com.stripe.stripeterminal.external.models.ConnectionConfiguration
import com.stripe.stripeterminal.external.models.DeviceType
import com.stripe.stripeterminal.external.models.ListLocationsParameters
import com.stripe.stripeterminal.external.models.Location
import com.stripe.stripeterminal.external.models.PaymentIntent
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.Refund
import com.stripe.stripeterminal.external.models.RefundConfiguration
import com.stripe.stripeterminal.external.models.RefundParameters
import com.stripe.stripeterminal.external.models.SetupIntent
import com.stripe.stripeterminal.external.models.SetupIntentCancellationParameters
import com.stripe.stripeterminal.external.models.SetupIntentConfiguration
import com.stripe.stripeterminal.external.models.SetupIntentParameters
import com.stripe.stripeterminal.external.models.TerminalException
import com.stripe.stripeterminal.log.LogLevel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import mek.stripeterminal.api.CartApi
import mek.stripeterminal.api.ConnectionStatusApi
import mek.stripeterminal.api.DeviceTypeApi
import mek.stripeterminal.api.DiscoverReadersControllerApi
import mek.stripeterminal.api.DiscoveryConfigurationApi
import mek.stripeterminal.api.LocationApi
import mek.stripeterminal.api.PaymentIntentApi
import mek.stripeterminal.api.PaymentIntentParametersApi
import mek.stripeterminal.api.PaymentStatusApi
import mek.stripeterminal.api.ReaderApi
import mek.stripeterminal.api.RefundApi
import mek.stripeterminal.api.Result
import mek.stripeterminal.api.SetupIntentApi
import mek.stripeterminal.api.SetupIntentUsageApi
import mek.stripeterminal.api.SimulatorConfigurationApi
import mek.stripeterminal.api.TerminalExceptionCodeApi
import mek.stripeterminal.api.TerminalHandlersApi
import mek.stripeterminal.api.TerminalPlatformApi
import mek.stripeterminal.api.TippingConfigurationApi
import mek.stripeterminal.mappings.toApi
import mek.stripeterminal.mappings.toHost
import mek.stripeterminal.mappings.toPlatformError
import mek.stripeterminal.plugin.DiscoverReadersSubject
import mek.stripeterminal.plugin.ReaderDelegatePlugin
import mek.stripeterminal.plugin.ReaderReconnectionListenerPlugin
import mek.stripeterminal.plugin.TerminalDelegatePlugin
import mek.stripeterminal.plugin.TerminalErrorHandler

class TerminalPlugin : FlutterPlugin, ActivityAware, TerminalPlatformApi {
    private lateinit var handlers: TerminalHandlersApi

    private var activity: Activity? = null
    private val permissions =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT
            )
        } else {
            arrayOf(
                Manifest.permission.BLUETOOTH_ADMIN
            )
        }

    private val terminal: Terminal get() = Terminal.getInstance()

    override fun onInit(shouldPrintLogs: Boolean) {
        val permissionStatus = permissions.map { ContextCompat.checkSelfPermission(activity!!, it) }

        if (permissionStatus.contains(PackageManager.PERMISSION_DENIED)) {
            throw createApiError(
                TerminalExceptionCodeApi.UNKNOWN,
                "You have declined the necessary permission, " +
                    "please allow from settings to continue."
            )
                .toPlatformError()
        }

        // If a hot restart is performed in flutter the terminal is already initialized but we need to
        // clean it up
        if (Terminal.isInitialized()) {
            clean()
            return
        }

        TerminalApplicationDelegate.onCreate(activity!!.application)
        val delegate = TerminalDelegatePlugin(handlers)
        Terminal.initTerminal(
            activity!!.applicationContext,
            if (shouldPrintLogs) LogLevel.VERBOSE else LogLevel.NONE,
            delegate,
            delegate
        )
    }

    override fun onClearCachedCredentials() = terminal.clearCachedCredentials()

    // region Reader discovery, connection and updates
    private lateinit var discoverReadersController: DiscoverReadersControllerApi
    private var discoverReadersSubject = DiscoverReadersSubject()
    private val discoveredReaders: List<Reader>
        get() = discoverReadersSubject.readers

    private lateinit var readerDelegate: ReaderDelegatePlugin
    private lateinit var readerReconnectionDelegate: ReaderReconnectionListenerPlugin

    override fun onGetConnectionStatus(): ConnectionStatusApi = terminal.connectionStatus.toApi()

    override fun onSupportsReadersOfType(
        deviceType: DeviceTypeApi?,
        discoveryConfiguration: DiscoveryConfigurationApi
    ): Boolean {
        val hostDeviceType =
            (if (deviceType != null) deviceType.toHost() else DeviceType.UNKNOWN) ?: return false
        val hostDiscoveryConfiguration = discoveryConfiguration.toHost() ?: return false
        val result =
            terminal.supportsReadersOfType(
                deviceType = hostDeviceType,
                discoveryConfiguration = hostDiscoveryConfiguration
            )
        return result.isSupported
    }

    private fun setupDiscoverReadersController(binaryMessenger: BinaryMessenger) {
        discoverReadersController = DiscoverReadersControllerApi(binaryMessenger)
        discoverReadersController.setHandler(
            discoverReadersSubject::onListen,
            discoverReadersSubject::onCancel
        )
    }

    override fun onConnectBluetoothReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean
    ) {
        val reader = findActiveReader(serialNumber)

        terminal.connectBluetoothReader(
            reader,
            ConnectionConfiguration.BluetoothConnectionConfiguration(
                locationId = locationId,
                autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect,
                bluetoothReaderReconnectionListener = readerReconnectionDelegate
            ),
            readerDelegate,
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            }
        )
    }

    override fun onConnectHandoffReader(result: Result<ReaderApi>, serialNumber: String) {
        val reader = findActiveReader(serialNumber)

        terminal.connectHandoffReader(
            reader,
            ConnectionConfiguration.HandoffConnectionConfiguration(),
            readerDelegate,
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
        val reader = findActiveReader(serialNumber)

        terminal.connectInternetReader(
            reader,
            ConnectionConfiguration.InternetConnectionConfiguration(
                failIfInUse = failIfInUse
            ),
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            }
        )
    }

    override fun onConnectMobileReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean
    ) {
        val reader = findActiveReader(serialNumber)

        val config =
            ConnectionConfiguration.LocalMobileConnectionConfiguration(
                locationId = locationId,
                autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect,
                localMobileReaderReconnectionListener = readerReconnectionDelegate
            )
        terminal.connectLocalMobileReader(
            reader,
            config,
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            }
        )
    }

    override fun onConnectUsbReader(
        result: Result<ReaderApi>,
        serialNumber: String,
        locationId: String,
        autoReconnectOnUnexpectedDisconnect: Boolean
    ) {
        val reader = findActiveReader(serialNumber)

        terminal.connectUsbReader(
            reader,
            ConnectionConfiguration.UsbConnectionConfiguration(
                locationId = locationId,
                autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect,
                usbReaderReconnectionListener = readerReconnectionDelegate
            ),
            readerDelegate,
            object : TerminalErrorHandler(result::error), ReaderCallback {
                override fun onSuccess(reader: Reader) = result.success(reader.toApi())
            }
        )
    }

    override fun onGetConnectedReader(): ReaderApi? = terminal.connectedReader?.toApi()

    override fun onCancelReaderReconnection(result: Result<Unit>) {
        if (readerReconnectionDelegate.cancelReconnect == null) {
            result.success(Unit)
        }
        readerReconnectionDelegate.cancelReconnect?.cancel(
            object : Callback, TerminalErrorHandler(result::error) {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onListLocations(
        result: Result<List<LocationApi>>,
        endingBefore: String?,
        limit: Long?,
        startingAfter: String?
    ) {
        val params = ListLocationsParameters.Builder()
        params.endingBefore = endingBefore
        params.startingAfter = startingAfter
        params.limit = limit?.toInt()
        terminal.listLocations(
            params.build(),
            object : TerminalErrorHandler(result::error), LocationListCallback {
                override fun onSuccess(locations: List<Location>, hasMore: Boolean) =
                    result.success(locations.map { it.toApi() })
            }
        )
    }

    override fun onInstallAvailableUpdate() = terminal.installAvailableUpdate()

    override fun onCancelReaderUpdate(result: Result<Unit>) {
        if (readerDelegate.cancelUpdate == null) {
            result.success(Unit)
        }
        readerDelegate.cancelUpdate?.cancel(
            object : Callback, TerminalErrorHandler(result::error) {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onRebootReader(result: Result<Unit>) {
        terminal.rebootReader(
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onDisconnectReader(result: Result<Unit>) {
        terminal.disconnectReader(
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onSetSimulatorConfiguration(configuration: SimulatorConfigurationApi) {
        Terminal.getInstance().simulatorConfiguration = configuration.toHost()
    }
    // endregion

    // region Taking Payment
    private var paymentIntents = HashMap<String, PaymentIntent>()

    override fun onGetPaymentStatus(): PaymentStatusApi = terminal.paymentStatus.toApi()

    override fun onCreatePaymentIntent(
        result: Result<PaymentIntentApi>,
        parameters: PaymentIntentParametersApi
    ) {
        terminal.createPaymentIntent(
            params = parameters.toHost(),
            callback =
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    paymentIntents[paymentIntent.id!!] = paymentIntent
                    result.success(paymentIntent.toApi())
                }
            }
        )
    }

    override fun onRetrievePaymentIntent(result: Result<PaymentIntentApi>, clientSecret: String) {
        terminal.retrievePaymentIntent(
            clientSecret,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    paymentIntents[paymentIntent.id!!] = paymentIntent
                    result.success(paymentIntent.toApi())
                }
            }
        )
    }

    private var cancelablesCollectPaymentMethod = HashMap<Long, Cancelable>()

    override fun onStartCollectPaymentMethod(
        result: Result<PaymentIntentApi>,
        operationId: Long,
        paymentIntentId: String,
        skipTipping: Boolean,
        tippingConfiguration: TippingConfigurationApi?,
        shouldUpdatePaymentIntent: Boolean,
        customerCancellationEnabled: Boolean
    ) {
        val paymentIntent = findPaymentIntent(paymentIntentId)
        val config =
            CollectConfiguration.Builder()
                .skipTipping(skipTipping)
                .setTippingConfiguration(tippingConfiguration?.toHost())
                .updatePaymentIntent(shouldUpdatePaymentIntent)
                .setEnableCustomerCancellation(customerCancellationEnabled)

        cancelablesCollectPaymentMethod[operationId] =
            terminal.collectPaymentMethod(
                paymentIntent,
                config = config.build(),
                callback =
                object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                    override fun onFailure(e: TerminalException) {
                        cancelablesCollectPaymentMethod.remove(operationId)
                        super.onFailure(e)
                    }

                    override fun onSuccess(paymentIntent: PaymentIntent) {
                        cancelablesCollectPaymentMethod.remove(operationId)
                        result.success(paymentIntent.toApi())
                        paymentIntents[paymentIntent.id!!] = paymentIntent
                    }
                }
            )
    }

    override fun onStopCollectPaymentMethod(result: Result<Unit>, operationId: Long) {
        cancelablesCollectPaymentMethod
            .remove(operationId)
            ?.cancel(
                object : TerminalErrorHandler(result::error), Callback {
                    override fun onSuccess() = result.success(Unit)
                }
            )
    }

    override fun onConfirmPaymentIntent(result: Result<PaymentIntentApi>, paymentIntentId: String) {
        val paymentIntent = findPaymentIntent(paymentIntentId)
        terminal.confirmPaymentIntent(
            paymentIntent,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onFailure(e: TerminalException) {
                    val paymentIntentUpdated = e.paymentIntent
                    if (paymentIntentUpdated != null) {
                        paymentIntents[paymentIntentUpdated.id!!] = paymentIntentUpdated
                    }
                    super.onFailure(e)
                }

                override fun onSuccess(paymentIntent: PaymentIntent) {
                    paymentIntents.remove(paymentIntent.id)
                    result.success(paymentIntent.toApi())
                }
            }
        )
    }

    override fun onCancelPaymentIntent(result: Result<PaymentIntentApi>, paymentIntentId: String) {
        val paymentIntent = findPaymentIntent(paymentIntentId)
        terminal.cancelPaymentIntent(
            paymentIntent,
            object : TerminalErrorHandler(result::error), PaymentIntentCallback {
                override fun onSuccess(paymentIntent: PaymentIntent) {
                    paymentIntents.remove(paymentIntentId)
                    result.success(paymentIntent.toApi())
                }
            }
        )
    }
    // endregion

    // region Saving payment details for later use
    private var setupIntents = HashMap<String, SetupIntent>()
    private var cancelablesCollectSetupIntentPaymentMethod = HashMap<Long, Cancelable>()

    override fun onCreateSetupIntent(
        result: Result<SetupIntentApi>,
        customerId: String?,
        metadata: HashMap<String, String>?,
        onBehalfOf: String?,
        description: String?,
        usage: SetupIntentUsageApi?
    ) {
        terminal.createSetupIntent(
            SetupIntentParameters.Builder()
                .setCustomer(customerId)
                .setMetadata(metadata)
                .setOnBehalfOf(onBehalfOf)
                .setDescription(description)
                .setUsage(usage?.toHost())
                .build(),
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    setupIntents[setupIntent.id] = setupIntent
                    result.success(setupIntent.toApi())
                }
            }
        )
    }

    override fun onRetrieveSetupIntent(result: Result<SetupIntentApi>, clientSecret: String) {
        terminal.retrieveSetupIntent(
            clientSecret,
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    setupIntents[setupIntent.id] = setupIntent
                    result.success(setupIntent.toApi())
                }
            }
        )
    }

    override fun onStartCollectSetupIntentPaymentMethod(
        result: Result<SetupIntentApi>,
        operationId: Long,
        setupIntentId: String,
        customerConsentCollected: Boolean,
        customerCancellationEnabled: Boolean
    ) {
        val setupIntent = findSetupIntent(setupIntentId)
        val config =
            SetupIntentConfiguration.Builder()
                .setEnableCustomerCancellation(customerCancellationEnabled)

        cancelablesCollectSetupIntentPaymentMethod[operationId] =
            terminal.collectSetupIntentPaymentMethod(
                setupIntent,
                customerConsentCollected = customerConsentCollected,
                config = config.build(),
                callback =
                object : TerminalErrorHandler(result::error), SetupIntentCallback {
                    override fun onFailure(e: TerminalException) {
                        cancelablesCollectSetupIntentPaymentMethod.remove(operationId)
                        super.onFailure(e)
                    }

                    override fun onSuccess(setupIntent: SetupIntent) {
                        cancelablesCollectSetupIntentPaymentMethod.remove(operationId)
                        setupIntents[setupIntent.id] = setupIntent
                        result.success(setupIntent.toApi())
                    }
                }
            )
    }

    override fun onStopCollectSetupIntentPaymentMethod(result: Result<Unit>, operationId: Long) {
        cancelablesCollectSetupIntentPaymentMethod
            .remove(operationId)
            ?.cancel(
                object : TerminalErrorHandler(result::error), Callback {
                    override fun onSuccess() = result.success(Unit)
                }
            )
    }

    override fun onConfirmSetupIntent(result: Result<SetupIntentApi>, setupIntentId: String) {
        val setupIntent = findSetupIntent(setupIntentId)
        terminal.confirmSetupIntent(
            setupIntent,
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    setupIntents[setupIntent.id] = setupIntent
                    result.success(setupIntent.toApi())
                }
            }
        )
    }

    override fun onCancelSetupIntent(result: Result<SetupIntentApi>, setupIntentId: String) {
        val setupIntent = findSetupIntent(setupIntentId)
        terminal.cancelSetupIntent(
            setupIntent,
            SetupIntentCancellationParameters.Builder().build(),
            object : TerminalErrorHandler(result::error), SetupIntentCallback {
                override fun onSuccess(setupIntent: SetupIntent) {
                    setupIntents.remove(setupIntent.id)
                    result.success(setupIntent.toApi())
                }
            }
        )
    }
    // endregion

    // region Saving payment details for later use
    private var cancelablesCollectRefundPaymentMethod = HashMap<Long, Cancelable>()

    override fun onStartCollectRefundPaymentMethod(
        result: Result<Unit>,
        operationId: Long,
        chargeId: String,
        amount: Long,
        currency: String,
        metadata: HashMap<String, String>?,
        reverseTransfer: Boolean?,
        refundApplicationFee: Boolean?,
        customerCancellationEnabled: Boolean
    ) {
        val config =
            RefundConfiguration.Builder().setEnableCustomerCancellation(customerCancellationEnabled)

        cancelablesCollectRefundPaymentMethod[operationId] =
            terminal.collectRefundPaymentMethod(
                RefundParameters.Builder(
                    chargeId = chargeId,
                    amount = amount,
                    currency = currency
                )
                    .let {
                        metadata?.let(it::setMetadata)
                        reverseTransfer?.let(it::setReverseTransfer)
                        refundApplicationFee?.let(it::setRefundApplicationFee)
                        it.build()
                    },

                config = config.build(),
                callback =
                object : TerminalErrorHandler(result::error), Callback {
                    override fun onFailure(e: TerminalException) {
                        cancelablesCollectRefundPaymentMethod.remove(operationId)
                        super.onFailure(e)
                    }

                    override fun onSuccess() {
                        cancelablesCollectRefundPaymentMethod.remove(operationId)
                        result.success(Unit)
                    }
                }
            )
    }

    override fun onStopCollectRefundPaymentMethod(result: Result<Unit>, operationId: Long) {
        cancelablesCollectRefundPaymentMethod
            .remove(operationId)
            ?.cancel(
                object : TerminalErrorHandler(result::error), Callback {
                    override fun onSuccess() = result.success(Unit)
                }
            )
    }

    override fun onConfirmRefund(result: Result<RefundApi>) {
        terminal.confirmRefund(
            object : TerminalErrorHandler(result::error), RefundCallback {
                override fun onSuccess(refund: Refund) = result.success(refund.toApi())
            }
        )
    }
    // endregion

    // region Display information to customers
    override fun onSetReaderDisplay(result: Result<Unit>, cart: CartApi) {
        terminal.setReaderDisplay(
            cart.toHost(),
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }

    override fun onClearReaderDisplay(result: Result<Unit>) {
        terminal.clearReaderDisplay(
            object : TerminalErrorHandler(result::error), Callback {
                override fun onSuccess() = result.success(Unit)
            }
        )
    }
    // endregion

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val binaryMessenger = flutterPluginBinding.binaryMessenger
        TerminalPlatformApi.setHandler(binaryMessenger, this)
        handlers = TerminalHandlersApi(binaryMessenger)
        readerDelegate = ReaderDelegatePlugin(handlers)
        readerReconnectionDelegate = ReaderReconnectionListenerPlugin(handlers)

        setupDiscoverReadersController(binaryMessenger)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        if (Terminal.isInitialized()) clean()

        discoverReadersController.removeHandler()
        TerminalPlatformApi.removeHandler()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    // ======================== INTERNAL METHODS

    private fun findActiveReader(serialNumber: String): Reader {
        val reader = discoveredReaders.firstOrNull { it.serialNumber == serialNumber }
        return reader
            ?: throw createApiError(TerminalExceptionCodeApi.READER_NOT_RECOVERED).toPlatformError()
    }

    private fun findPaymentIntent(paymentIntentId: String): PaymentIntent {
        val paymentIntent = paymentIntents[paymentIntentId]
        return paymentIntent
            ?: throw createApiError(TerminalExceptionCodeApi.PAYMENT_INTENT_NOT_RECOVERED)
                .toPlatformError()
    }

    private fun findSetupIntent(setupIntentId: String): SetupIntent {
        val setupIntent = setupIntents[setupIntentId]
        return setupIntent
            ?: throw createApiError(TerminalExceptionCodeApi.SETUP_INTENT_NOT_RECOVERED)
                .toPlatformError()
    }

    private fun clean() {
        if (terminal.connectedReader != null) terminal.disconnectReader(EmptyCallback())

        discoverReadersSubject.clear()

        cancelablesCollectPaymentMethod.values.forEach { it.cancel(EmptyCallback()) }
        cancelablesCollectPaymentMethod = hashMapOf()
        paymentIntents = hashMapOf()

        cancelablesCollectSetupIntentPaymentMethod.values.forEach { it.cancel(EmptyCallback()) }
        cancelablesCollectSetupIntentPaymentMethod = hashMapOf()
        setupIntents = hashMapOf()

        cancelablesCollectRefundPaymentMethod.values.forEach { it.cancel(EmptyCallback()) }
        cancelablesCollectRefundPaymentMethod = hashMapOf()
    }
}

class EmptyCallback : Callback {
    override fun onFailure(e: TerminalException) {}

    override fun onSuccess() {}
}

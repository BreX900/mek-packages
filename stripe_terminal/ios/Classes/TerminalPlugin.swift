import Flutter
import StripeTerminal
import UIKit

public class TerminalPlugin: NSObject, FlutterPlugin, TerminalPlatformApi {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = TerminalPlugin(registrar.messenger())
        setTerminalPlatformApiHandler(registrar.messenger(), instance)
        instance.onAttachedToEngine()
    }
    
    private let handlers: TerminalHandlersApi

    init(_ binaryMessenger: FlutterBinaryMessenger) {
        self.handlers = TerminalHandlersApi(binaryMessenger)
        self._discoverReadersController = DiscoverReadersControllerApi(binaryMessenger: binaryMessenger)
        self._readerDelegate = ReaderDelegatePlugin(handlers)
    }

    public func onAttachedToEngine() {
        self.setupDiscoverReaders()
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        if (Terminal.hasTokenProvider()) { self._clean() }
        
        self._discoverReadersController.removeHandler()
        removeTerminalPlatformApiHandler()
    }
    
    func onInit(_ shouldPrintLogs: Bool) async throws {
        // If a hot restart is performed in flutter the terminal is already initialized but we need to clean it up
        if Terminal.hasTokenProvider() {
            _clean()
            return
        }
        
        let delegate = TerminalDelegatePlugin(handlers)
        Terminal.setTokenProvider(delegate)
        Terminal.shared.delegate = delegate
        if (shouldPrintLogs) { Terminal.setLogListener { message in print(message) } }
    }
    
    func onClearCachedCredentials() throws {
        Terminal.shared.clearCachedCredentials()
        self._clean();
    }

// MARK: - Reader discovery, connection and updates
    private let _discoverReadersController: DiscoverReadersControllerApi
    private let _discoveryDelegate = DiscoveryDelegatePlugin()
    private var _readers: [Reader] { get {
        return _discoveryDelegate.readers
    } }
    private let _readerDelegate: ReaderDelegatePlugin

    func onGetConnectionStatus() throws -> ConnectionStatusApi {
        return Terminal.shared.connectionStatus.toApi()
    }
    
    func onSupportsReadersOfType(
        _ deviceType: DeviceTypeApi?,
        _ discoveryConfiguration: DiscoveryConfigurationApi
    ) throws -> Bool {
        let hostDiscoveryMethod = discoveryConfiguration.toHostDiscoveryMethod()
        guard let hostDiscoveryMethod else {
            return false
        }
        let hostDeviceType = deviceType?.toHost()
        guard let hostDeviceType else {
            return false
        }
        let result = Terminal.shared.supportsReaders(
            of: hostDeviceType,
            discoveryMethod: hostDiscoveryMethod,
            simulated: discoveryConfiguration.toHostSimulated()
        )
        do {
            try result.get()
            return true
        } catch {
            return false
        }
    }
    
    func setupDiscoverReaders() {
        _discoverReadersController.setHandler(
            _discoveryDelegate.onListen,
            _discoveryDelegate.onCancel
        )
    }
    
    func onConnectReader(
        _ serialNumber: String,
        _ configuration: any ConnectionConfigurationApi
    ) async throws -> ReaderApi {
        let configuration = try configuration.toHost(_readerDelegate)
        if let configuration = configuration {
            do {
                 let reader = try await Terminal.shared.connectReader(
                     _findReader(serialNumber),
                     connectionConfig: configuration
                 )
                 return reader.toApi()
             } catch let error as NSError {
                 throw error.toPlatformError()
             }
        }
        throw PlatformError("", "Unsupported connection configuration")
    }

    func onGetConnectedReader() throws -> ReaderApi? {
        return Terminal.shared.connectedReader?.toApi()
    }
    
    func onCancelReaderReconnection() async throws {
        try await _readerDelegate.cancelReconnection()
    }
    
    func onListLocations(_ endingBefore: String?, _ limit: Int?, _ startingAfter: String?) async throws -> [LocationApi] {
        let params = ListLocationsParametersBuilder()
            .setEndingBefore(endingBefore)
            .setStartingAfter(startingAfter)
        limit.apply { params.setLimit(UInt($0)) }
        do {
            return try await Terminal.shared.listLocations(parameters: params.build()).0.map { $0.toApi() }
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }
    
    func onInstallAvailableUpdate() throws {
        Terminal.shared.installAvailableUpdate()
    }
    
    func onCancelReaderUpdate() async throws {
        try await _readerDelegate.cancelUpdate()
    }
    
    func onRebootReader() async throws {
        do {
            try await Terminal.shared.rebootReader()
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }
    
    func onDisconnectReader() async throws {
        do {
            try await Terminal.shared.disconnectReader()
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }
    
    func onSetSimulatorConfiguration(_ configuration: SimulatorConfigurationApi) throws {
        Terminal.shared.simulatorConfiguration.availableReaderUpdate = configuration.update.toHost()
        Terminal.shared.simulatorConfiguration.simulatedCard = configuration.simulatedCard.toHost()
        Terminal.shared.simulatorConfiguration.simulatedTipAmount = configuration.simulatedTipAmount?.nsNumberValue
    }
    
// MARK: - Taking payments
    
    private var _paymentIntents: [String: PaymentIntent] = [:]
    
    func onGetPaymentStatus() throws -> PaymentStatusApi {
        return Terminal.shared.paymentStatus.toApi()
    }
    
    func onCreatePaymentIntent(_ parameters: PaymentIntentParametersApi) async throws -> PaymentIntentApi {
        do {
            let paymentIntent = try await Terminal.shared.createPaymentIntent(parameters.toHost())
            _paymentIntents[paymentIntent.stripeId!] = paymentIntent
            return paymentIntent.toApi()
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }

    func onRetrievePaymentIntent(
        _ clientSecret: String
    ) async throws -> PaymentIntentApi {
        do {
            let paymentIntent = try await Terminal.shared.retrievePaymentIntent(clientSecret: clientSecret)
            _paymentIntents[paymentIntent.stripeId!] = paymentIntent
            return paymentIntent.toApi()
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }

    private var _cancelablesCollectPaymentMethod: [Int: Cancelable] = [:]
    
    func onStartCollectPaymentMethod(
        _ result: Result<PaymentIntentApi>,
        _ operationId: Int,
        _ paymentIntentId: String,
        _ requestDynamicCurrencyConversion: Bool,
        _ surchargeNotice: String?,
        _ skipTipping: Bool,
        _ tippingConfiguration: TippingConfigurationApi?,
        _ shouldUpdatePaymentIntent: Bool,
        _ customerCancellationEnabled: Bool
    ) throws {
        let paymentIntent = try _findPaymentIntent(paymentIntentId)
        let config = CollectConfigurationBuilder()
            .setSurchargeNotice(surchargeNotice)
            .setRequestDynamicCurrencyConversion(requestDynamicCurrencyConversion)
            .setSkipTipping(skipTipping)
            .setTippingConfiguration(try tippingConfiguration?.toHost())
            .setUpdatePaymentIntent(shouldUpdatePaymentIntent)
            .setEnableCustomerCancellation(customerCancellationEnabled)
            
        self._cancelablesCollectPaymentMethod[operationId] = Terminal.shared.collectPaymentMethod(
            paymentIntent,
            collectConfig: try config.build(),
            completion: { paymentIntent, error in
            self._cancelablesCollectPaymentMethod.removeValue(forKey: operationId)
            if let error = error as? NSError {
                result.error(error.toPlatformError())
                return
            }
            self._paymentIntents[paymentIntent!.stripeId!] = paymentIntent!
            result.success(paymentIntent!.toApi())
        })
    }

    func onStopCollectPaymentMethod(
        _ operationId: Int
    ) async throws {
        try await _cancelablesCollectPaymentMethod.removeValue(forKey: operationId)?.cancel()
    }
    
    private var _confirmPaymentIntentCancelables: [Int: Cancelable] = [:]
    
    func onStartConfirmPaymentIntent(
        _ result: Result<PaymentIntentApi>,
        _ operationId: Int,
        _ paymentIntentId: String
    ) throws {
        let paymentIntent = try _findPaymentIntent(paymentIntentId)
        Terminal.shared.confirmPaymentIntent(paymentIntent, completion: { paymentIntent, error in
            self._cancelablesCollectPaymentMethod.removeValue(forKey: operationId)
            if let error = error {
                result.error(error.toPlatformError())
                return
            }
            self._paymentIntents[paymentIntent!.stripeId!] = paymentIntent!
            result.success(paymentIntent!.toApi())
        })
    }
    
    func onStopConfirmPaymentIntent(_ operationId: Int) async throws {
        try await _cancelablesCollectPaymentMethod.removeValue(forKey: operationId)?.cancel()
    }
    
    func onCancelPaymentIntent(_ paymentIntentId: String) async throws -> PaymentIntentApi {
        do {
            let paymentIntent = try _findPaymentIntent(paymentIntentId)
            let newPaymentIntent = try await Terminal.shared.cancelPaymentIntent(paymentIntent)
            _paymentIntents.removeValue(forKey: paymentIntentId)
            return newPaymentIntent.toApi()
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }
    
// MARK: - Saving payment details for later use
   
    private var _setupIntents: [String: SetupIntent] = [:]
    private var _cancelablesCollectSetupIntentPaymentMethod: [Int: Cancelable] = [:]
    
    func onCreateSetupIntent(
        _ customerId: String?,
        _ metadata: [String : String]?,
        _ onBehalfOf: String?,
        _ description: String?,
        _ usage: SetupIntentUsageApi?
    ) async throws -> SetupIntentApi {
        let params = SetupIntentParametersBuilder()
        params.setCustomer(customerId)
        params.setMetadata(metadata)
        params.setOnBehalfOf(onBehalfOf)
        params.setStripeDescription(description)
        usage.apply { params.setUsage($0.toHost()) }
        do {
            let setupIntent = try await Terminal.shared.createSetupIntent(params.build())
            _setupIntents[setupIntent.stripeId!] = setupIntent
            return setupIntent.toApi()
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }
    
    func onRetrieveSetupIntent(_ clientSecret: String) async throws -> SetupIntentApi {
        do {
            let setupIntent = try await Terminal.shared.retrieveSetupIntent(clientSecret: clientSecret)
            _setupIntents[setupIntent.stripeId!] = setupIntent
            return setupIntent.toApi()
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }
    func onStartCollectSetupIntentPaymentMethod(
        _ result: Result<SetupIntentApi>,
        _ operationId: Int,
        _ setupIntentId: String,
        _ allowRedisplay: AllowRedisplayApi,
        _ customerCancellationEnabled: Bool
    ) throws {
        let setupIntent = try _findSetupIntent(setupIntentId)
        let config = SetupIntentConfigurationBuilder()
            .setEnableCustomerCancellation(customerCancellationEnabled)
        
        _cancelablesCollectSetupIntentPaymentMethod[operationId] = Terminal.shared.collectSetupIntentPaymentMethod(
            setupIntent,
            allowRedisplay: allowRedisplay.toHost(),
            setupConfig: try config.build(),
            completion: { setupIntent, error in
                self._cancelablesCollectSetupIntentPaymentMethod.removeValue(forKey: operationId)
                if let error = error as? NSError {
                    result.error(error.toPlatformError())
                    return
                }
                self._setupIntents[setupIntent!.stripeId!] = setupIntent!
                result.success(setupIntent!.toApi())
        })
    }
    
    func onStopCollectSetupIntentPaymentMethod(_ operationId: Int) async throws {
        try await _cancelablesCollectSetupIntentPaymentMethod.removeValue(forKey: operationId)?.cancel()
    }
    
    private var _confirmSetupIntentCancelables: [Int: Cancelable] = [:]
    
    func onStartConfirmSetupIntent(
        _ result: Result<SetupIntentApi>,
        _ operationId: Int,
        _ setupIntentId: String
    ) throws {
        let setupIntent = try _findSetupIntent(setupIntentId)
        _confirmSetupIntentCancelables[operationId] = Terminal.shared.confirmSetupIntent(setupIntent, completion: { setupIntent, error in
            self._confirmSetupIntentCancelables.removeValue(forKey: operationId)
            if let error = error {
                result.error(error.toPlatformError())
                return
            }
            self._setupIntents[setupIntent!.stripeId!] = setupIntent!
            result.success(setupIntent!.toApi())
    })
    }
    
    func onStopConfirmSetupIntent(_ operationId: Int) async throws {
        try await _confirmSetupIntentCancelables.removeValue(forKey: operationId)?.cancel()
    }
    
    func onCancelSetupIntent(_ setupIntentId: String) async throws -> SetupIntentApi {
        let setupIntent = try _findSetupIntent(setupIntentId)
        do {
            let newSetupIntent = try await Terminal.shared.cancelSetupIntent(setupIntent)
            _setupIntents.removeValue(forKey: setupIntentId)
            return newSetupIntent.toApi()
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }
// MARK: - Card-present refunds
    private var _cancelablesCollectRefundPaymentMethod: [Int: Cancelable] = [:]

    func onStartCollectRefundPaymentMethod(
        _ result: Result<Void>,
        _ operationId: Int,
        _ chargeId: String,
        _ amount: Int,
        _ currency: String,
        _ metadata: [String: String]?,
        _ reverseTransfer: Bool?,
        _ refundApplicationFee: Bool?,
        _ customerCancellationEnabled: Bool
    ) throws {
        let params = RefundParametersBuilder(chargeId: chargeId, amount: UInt(amount), currency: currency)
        params.setMetadata(metadata)
        reverseTransfer.apply(params.setReverseTransfer)
        params.setMetadata(metadata)
        
        let config = RefundConfigurationBuilder()
            .setEnableCustomerCancellation(customerCancellationEnabled)
        
        _cancelablesCollectRefundPaymentMethod[operationId] = Terminal.shared.collectRefundPaymentMethod(
            try params.build(),
            refundConfig: try config.build(),
            completion: { error in
                self._cancelablesCollectRefundPaymentMethod.removeValue(forKey: operationId)
                if let error = error as? NSError {
                    result.error(error.toPlatformError())
                    return
                }
                result.success(())
        })
    }
    
    func onStopCollectRefundPaymentMethod(_ operationId: Int) async throws {
        try await _cancelablesCollectRefundPaymentMethod.removeValue(forKey: operationId)?.cancel()
    }
    
    private var _confirmRefundCancelables: [Int: Cancelable] = [:]
    
    func onStartConfirmRefund(_ result: Result<RefundApi>, _ operationId: Int) throws {
        _confirmRefundCancelables[operationId] = Terminal.shared.confirmRefund(completion: { refund, error in
            self._confirmRefundCancelables.removeValue(forKey: operationId)
            if let error = error {
                result.error(error.toPlatformError())
                return
            }
            result.success(refund!.toApi())
    })
    }
    
    func onStopConfirmRefund(_ operationId: Int) async throws {
        try await _confirmRefundCancelables.removeValue(forKey: operationId)?.cancel()
    }
    


// MARK: - Display information to customers
    
    func onSetReaderDisplay(
        _ cart: CartApi
    ) async throws {
        do {
            try await Terminal.shared.setReaderDisplay(cart.toHost())
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }

    func onClearReaderDisplay() async throws {
        do {
            try await Terminal.shared.clearReaderDisplay()
        } catch let error as NSError {
            throw error.toPlatformError()
        }
    }
    
// MARK: - PRIVATE METHODS
    
    private func _clean() {
        if (Terminal.shared.connectedReader != nil) { Terminal.shared.disconnectReader  { error in } }
        
        self._discoveryDelegate.clear()
        
        self._cancelablesCollectPaymentMethod.values.forEach { $0.cancel { error in } }
        self._cancelablesCollectPaymentMethod = [:]
        self._confirmSetupIntentCancelables.values.forEach { $0.cancel { error in } }
        self._confirmSetupIntentCancelables = [:]
        self._paymentIntents = [:]

        self._cancelablesCollectSetupIntentPaymentMethod.values.forEach { $0.cancel { error in } }
        self._cancelablesCollectSetupIntentPaymentMethod = [:]
        self._confirmPaymentIntentCancelables.values.forEach { $0.cancel { error in } }
        self._confirmPaymentIntentCancelables = [:]
        self._setupIntents = [:]

        self._cancelablesCollectRefundPaymentMethod.values.forEach { $0.cancel { error in } }
        self._cancelablesCollectRefundPaymentMethod = [:]
        self._confirmRefundCancelables.values.forEach { $0.cancel { error in } }
        self._confirmRefundCancelables = [:]
    }

    private func _findReader(_ serialNumber: String) throws -> Reader {
        guard let reader = _readers.first(where: { $0.serialNumber == serialNumber }) else {
            throw createApiException(TerminalExceptionCodeApi.readerNotRecovered).toPlatformError()
        }
        return reader
    }
    
    private func _findPaymentIntent(_ paymentIntentId: String) throws -> PaymentIntent {
        let paymentIntent = _paymentIntents[paymentIntentId]
        guard let paymentIntent else {
            throw createApiException(TerminalExceptionCodeApi.paymentIntentNotRecovered).toPlatformError()
        }
        return paymentIntent
    }
    
    private func _findSetupIntent(_ setupIntentId: String) throws -> SetupIntent {
        let setupIntent = _setupIntents[setupIntentId]
        guard let setupIntent else {
            throw createApiException(TerminalExceptionCodeApi.setupIntentNotRecovered).toPlatformError()
        }
        return setupIntent
    }
}

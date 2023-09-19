import Flutter
import StripeTerminal
import UIKit

public class StripeTerminalPlugin: NSObject, FlutterPlugin, StripeTerminalPlatformApi {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = StripeTerminalPlugin(registrar.messenger())
        setStripeTerminalPlatformApiHandler(registrar.messenger(), instance)
        instance.onAttachedToEngine()
    }
    
    private let handlers: StripeTerminalHandlersApi
    
    init(_ binaryMessenger: FlutterBinaryMessenger) {
        self.handlers = StripeTerminalHandlersApi(binaryMessenger)
        self._discoverReadersController = DiscoverReadersControllerApi(binaryMessenger: binaryMessenger)
        self._readerDelegate = ReaderDelegatePlugin(handlers)
        self._readerReconnectionDelegate = ReaderReconnectionDelegatePlugin(handlers)
    }

    public func onAttachedToEngine() {
        self.setupDiscoverReaders()
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        self._discoverReadersController.removeHandler()
        removeStripeTerminalPlatformApiHandler()
        self._clean()
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
    }

// Reader discovery, connection and updates
    private let _discoverReadersController: DiscoverReadersControllerApi
    private let _discoveryDelegate = DiscoveryDelegatePlugin()
    private var _readers: [Reader] { get {
        return _discoveryDelegate.readers
    } }
    private let _readerDelegate: ReaderDelegatePlugin
    private let _readerReconnectionDelegate: ReaderReconnectionDelegatePlugin

    func onGetConnectionStatus() throws -> ConnectionStatusApi {
        return Terminal.shared.connectionStatus.toApi()
    }
    
    func onSupportsReadersOfType(
        _ deviceType: DeviceTypeApi,
        _ discoveryMethod: DiscoveryMethodApi,
        _ simulated: Bool
    ) throws -> Bool {
        let hostDiscoveryMethod = discoveryMethod.toHost()
        guard let hostDiscoveryMethod else {
            return false
        }
        let hostDeviceType = deviceType.toHost()
        guard let hostDeviceType else {
            return false
        }
        let result = Terminal.shared.supportsReaders(
            of: hostDeviceType,
            discoveryMethod: hostDiscoveryMethod,
            simulated: simulated
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

    func onConnectHandoffReader(_ serialNumber: String) async throws -> ReaderApi {
        throw PlatformError("", "Unsupported method")
    }

    func onConnectBluetoothReader(
        _ serialNumber: String,
        _ locationId: String,
        _ autoReconnectOnUnexpectedDisconnect: Bool
    ) async throws -> ReaderApi {
        do {
            let reader = try await Terminal.shared.connectBluetoothReader(
                _findReader(serialNumber),
                delegate: _readerDelegate,
                connectionConfig: BluetoothConnectionConfiguration(
                    locationId: locationId,
                    autoReconnectOnUnexpectedDisconnect: autoReconnectOnUnexpectedDisconnect,
                    autoReconnectionDelegate: _readerReconnectionDelegate
                )
            )
            return reader.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }

    func onConnectInternetReader(
        _ serialNumber: String,
        _ failIfInUse: Bool
    ) async throws -> ReaderApi {
        do {
            let reader = try await Terminal.shared.connectInternetReader(
                _findReader(serialNumber),
                connectionConfig: InternetConnectionConfiguration(
                    failIfInUse: failIfInUse
                )
            )
            return reader.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }

    func onConnectMobileReader(
        _ serialNumber: String,
        _ locationId: String
    ) async throws -> ReaderApi {
        do {
            let reader = try await Terminal.shared.connectLocalMobileReader(
                _findReader(serialNumber),
                delegate: _readerDelegate,
                connectionConfig: LocalMobileConnectionConfiguration(
                    locationId: locationId
                )
            )
            return reader.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }
    
    func onConnectUsbReader(_ serialNumber: String, _ locationId: String, _ autoReconnectOnUnexpectedDisconnect: Bool) async throws -> ReaderApi {
        throw PlatformError("", "Unsupported method")
    }

    func onGetConnectedReader() throws -> ReaderApi? {
        return Terminal.shared.connectedReader?.toApi()
    }
    
    func onCancelReaderReconnection() async throws {
        try await _readerReconnectionDelegate.cancelable?.cancel()
    }
    
    func onListLocations(_ endingBefore: String?, _ limit: Int?, _ startingAfter: String?) async throws -> [LocationApi] {
        do {
            return try await Terminal.shared.listLocations(parameters: ListLocationsParameters(
                limit: limit as NSNumber?,
                endingBefore: endingBefore,
                startingAfter: startingAfter
            )).0.map { $0.toApi() }
        } catch let error as NSError {
            throw error.toApi()
        }
    }
    
    func onInstallAvailableUpdate() throws {
        Terminal.shared.installAvailableUpdate()
    }
    
    func onCancelReaderUpdate() async throws {
        try await _readerDelegate.cancellableUpdate?.cancel()
    }
    
    func onDisconnectReader() async throws {
        do {
            try await Terminal.shared.disconnectReader()
        } catch let error as NSError {
            throw error.toApi()
        }
    }
    
// Taking payments
    
    private var _paymentIntents: [String: PaymentIntent] = [:]
    
    func onGetPaymentStatus() throws -> PaymentStatusApi {
        return Terminal.shared.paymentStatus.toApi()
    }
    
    func onCreatePaymentIntent(_ parameters: PaymentIntentParametersApi) async throws -> PaymentIntentApi {
        do {
            let paymentIntent = try await Terminal.shared.createPaymentIntent(parameters.toHost())
            _paymentIntents[paymentIntent.stripeId] = paymentIntent
            return paymentIntent.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }

    func onRetrievePaymentIntent(
        _ clientSecret: String
    ) async throws -> PaymentIntentApi {
        do {
            let paymentIntent = try await Terminal.shared.retrievePaymentIntent(clientSecret: clientSecret)
            _paymentIntents[paymentIntent.stripeId] = paymentIntent
            return paymentIntent.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }

    private var _cancelablesCollectPaymentMethod: [Int: Cancelable] = [:]

    func onStartCollectPaymentMethod(
        _ result: Result<PaymentIntentApi>,
        _ operationId: Int,
        _ paymentIntentId: String,
        _: Bool,
        _: Bool
    ) throws {
        let paymentIntent = try _findPaymentIntent(paymentIntentId)
        self._cancelablesCollectPaymentMethod[operationId] = Terminal.shared.collectPaymentMethod(paymentIntent) { paymentIntent, error in
            self._cancelablesCollectPaymentMethod.removeValue(forKey: operationId)
            if let error = error as? NSError {
                let platformError = error.toApi()
                result.error(platformError.code, platformError.message, platformError.details)
                return
            }
            self._paymentIntents[paymentIntent!.stripeId] = paymentIntent!
            result.success(paymentIntent!.toApi())
        }
    }

    func onStopCollectPaymentMethod(
        _ operationId: Int
    ) async throws {
        try await _cancelablesCollectPaymentMethod.removeValue(forKey: operationId)?.cancel()
    }

    func onProcessPayment(
        _ paymentIntentId: String
    ) async throws -> PaymentIntentApi {
        let paymentIntent = try _findPaymentIntent(paymentIntentId)
        do {
            let (intent, error) = await Terminal.shared.processPayment(paymentIntent)
            if let error {
                throw PlatformError(error.declineCode!, error.localizedDescription)
            }
            return intent!.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }
    
    func onCancelPaymentIntent(_ paymentIntentId: String) async throws -> PaymentIntentApi {
        do {
            let paymentIntent = try _findPaymentIntent(paymentIntentId)
            let newPaymentIntent = try await Terminal.shared.cancelPaymentIntent(paymentIntent)
            _paymentIntents.removeValue(forKey: paymentIntentId)
            return newPaymentIntent.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }
    
// Saving payment details for later use
   
    private var _cancelablesReadReusableCard: [Int: Cancelable] = [:]
    private var _setupIntents: [String: SetupIntent] = [:]
    private var _cancelablesCollectSetupIntentPaymentMethod: [Int: Cancelable] = [:]

    func onStartReadReusableCard(
        _ result: Result<PaymentMethodApi>,
        _ operationId: Int,
        _: String?,
        _: [String: String]?
    ) throws {
        _cancelablesReadReusableCard[operationId] = Terminal.shared.readReusableCard(
            ReadReusableCardParameters(),
            completion: { paymentMethod, error in
                self._cancelablesReadReusableCard.removeValue(forKey: operationId)
                if let error = error as? NSError {
                    let platformError = error.toApi()
                    result.error(platformError.code, platformError.message, platformError.details)
                    return
                }
                result.success(paymentMethod!.toApi())
            }
        )
    }

    func onStopReadReusableCard(
        _ operationId: Int
    ) async throws {
        try await _cancelablesReadReusableCard.removeValue(forKey: operationId)?.cancel()
    }
    
    func onCreateSetupIntent(
        _ customerId: String?,
        _ metadata: [String : String]?,
        _ onBehalfOf: String?,
        _ description: String?,
        _ usage: SetupIntentUsageApi?
    ) async throws -> SetupIntentApi {
        let params = SetupIntentParameters(customer: customerId)
        params.metadata = metadata
        params.onBehalfOf = onBehalfOf
        params.stripeDescription = description
        if let usage = usage { params.usage = usage.toHost() }
        do {
            let setupIntent = try await Terminal.shared.createSetupIntent(params)
            _setupIntents[setupIntent.stripeId] = setupIntent
            return setupIntent.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }
    
    func onRetrieveSetupIntent(_ clientSecret: String) async throws -> SetupIntentApi {
        do {
            let setupIntent = try await Terminal.shared.retrieveSetupIntent(clientSecret: clientSecret)
            _setupIntents[setupIntent.stripeId] = setupIntent
            return setupIntent.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }
    
    func onStartCollectSetupIntentPaymentMethod(
        _ result: Result<SetupIntentApi>,
        _ operationId: Int,
        _ setupIntentId: String,
        _ customerConsentCollected: Bool
    ) throws {
        let setupIntent = try _findSetupIntent(setupIntentId)
        _cancelablesCollectSetupIntentPaymentMethod[operationId] = Terminal.shared.collectSetupIntentPaymentMethod(
            setupIntent,
            customerConsentCollected: customerConsentCollected,
            completion: { setupIntent, error in
                self._cancelablesCollectSetupIntentPaymentMethod.removeValue(forKey: operationId)
                if let error = error as? NSError {
                    let platformError = error.toApi()
                    result.error(platformError.code, platformError.message, platformError.details)
                    return
                }
                self._setupIntents[setupIntent!.stripeId] = setupIntent!
                result.success(setupIntent!.toApi())
            }
        )
    }
    
    func onStopCollectSetupIntentPaymentMethod(_ operationId: Int) async throws {
        try await _cancelablesCollectSetupIntentPaymentMethod.removeValue(forKey: operationId)?.cancel()
    }
    
    func onConfirmSetupIntent(_ setupIntentId: String) async throws -> SetupIntentApi {
        let setupIntent = try _findSetupIntent(setupIntentId)
        let (newSetupIntent, error) = await Terminal.shared.confirmSetupIntent(setupIntent)
        if let error {
            throw PlatformError(error.declineCode!, error.localizedDescription)
        }
        _setupIntents[newSetupIntent!.stripeId] = newSetupIntent!
        return newSetupIntent!.toApi()
    }
    
    func onCancelSetupIntent(_ setupIntentId: String) async throws -> SetupIntentApi {
        let setupIntent = try _findSetupIntent(setupIntentId)
        do {
            let newSetupIntent = try await Terminal.shared.cancelSetupIntent(setupIntent)
            _setupIntents.removeValue(forKey: setupIntentId)
            return newSetupIntent.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }
// Card-present refunds
    private var _cancelablesCollectRefundPaymentMethod: [Int: Cancelable] = [:]

    func onStartCollectRefundPaymentMethod(
        _ result: Result<Void>,
        _ operationId: Int,
        _ chargeId: String,
        _ amount: Int,
        _ currency: String,
        _ metadata: [String : String]?,
        _ reverseTransfer: Bool?,
        _ refundApplicationFee: Bool?
    ) throws {
        let params = RefundParameters(chargeId: chargeId, amount: UInt(amount), currency: currency)
        if let metadata = metadata { params.metadata = metadata }
        if let reverseTransfer = reverseTransfer { params.reverseTransfer = NSNumber(value: reverseTransfer) }
        if let refundApplicationFee = refundApplicationFee { params.refundApplicationFee = NSNumber(value: refundApplicationFee) }
        _cancelablesCollectRefundPaymentMethod[operationId] = Terminal.shared.collectRefundPaymentMethod(
            params,
            completion: { error in
                self._cancelablesCollectRefundPaymentMethod.removeValue(forKey: operationId)
                if let error = error as? NSError {
                    let platformError = error.toApi()
                    result.error(platformError.code, platformError.message, platformError.details)
                    return
                }
                result.success(())
            }
        )
    }
    
    func onStopCollectRefundPaymentMethod(_ operationId: Int) async throws {
        try await _cancelablesCollectRefundPaymentMethod.removeValue(forKey: operationId)?.cancel()
    }
    
    func onProcessRefund() async throws -> RefundApi {
        do {
            let (refund, error) = await Terminal.shared.processRefund()
            if let error {
                throw PlatformError("\(error.code)", error.localizedDescription)
            }
            return refund!.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }

// Display information to customers
    
    func onSetReaderDisplay(
        _ cart: CartApi
    ) async throws {
        do {
            try await Terminal.shared.setReaderDisplay(cart.toHost())
        } catch let error as NSError {
            throw error.toApi()
        }
    }

    func onClearReaderDisplay() async throws {
        do {
            try await Terminal.shared.clearReaderDisplay()
        } catch let error as NSError {
            throw error.toApi()
        }
    }
    
    // PRIVATE METHODS
    
    private func _clean() {
        if (Terminal.shared.connectedReader != nil) { Terminal.shared.disconnectReader  { error in } }
        
        self._discoveryDelegate.clear()
        
        self._cancelablesCollectPaymentMethod.values.forEach { $0.cancel { error in } }
        self._cancelablesCollectPaymentMethod = [:]
        self._paymentIntents = [:]
        
        self._cancelablesReadReusableCard.values.forEach { $0.cancel { error in } }
        self._cancelablesReadReusableCard = [:]
        self._cancelablesCollectSetupIntentPaymentMethod.values.forEach { $0.cancel { error in } }
        self._cancelablesCollectSetupIntentPaymentMethod = [:]
        self._setupIntents = [:]

        self._cancelablesCollectRefundPaymentMethod.values.forEach { $0.cancel { error in } }
        self._cancelablesCollectRefundPaymentMethod = [:]
    }

    private func _findReader(_ serialNumber: String) throws -> Reader {
        guard let reader = _readers.first(where: { $0.serialNumber == serialNumber }) else {
            throw PlatformError(
                TerminalExceptionCodeApi.readerCommunicationError.rawValue,
                "Reader with provided serial number no longer exists"
            )
        }
        return reader
    }
    
    private func _findPaymentIntent(_ paymentIntentId: String) throws -> PaymentIntent {
        let paymentIntent = _paymentIntents[paymentIntentId]
        guard let paymentIntent else {
            throw PlatformError(TerminalExceptionCodeApi.paymentIntentNotRetrieved.rawValue, nil, nil)
        }
        return paymentIntent
    }
    
    private func _findSetupIntent(_ setupIntentId: String) throws -> SetupIntent {
        let setupIntent = _setupIntents[setupIntentId]
        guard let setupIntent else {
            throw PlatformError(TerminalExceptionCodeApi.paymentIntentNotRetrieved.rawValue, nil, nil)
        }
        return setupIntent
    }
}

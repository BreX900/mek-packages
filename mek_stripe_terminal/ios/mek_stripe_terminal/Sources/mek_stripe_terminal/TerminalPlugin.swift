import Flutter
import StripeTerminal
import UIKit

public class TerminalPlugin: NSObject, FlutterPlugin, TerminalPlatformApi {
    private static var shared: TerminalPlugin?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        TerminalPlugin.shared = TerminalPlugin(registrar.messenger());
        TerminalPlatformApiSetup.setUp(binaryMessenger: registrar.messenger(), api: TerminalPlugin.shared!);
    }
    
    private let _binaryMessenger: FlutterBinaryMessenger
    private let _handlers: TerminalHandlersApi
    private let _terminalDelegate: TerminalDelegatePlugin
    private let _discoveryDelegate: DiscoveryDelegatePlugin

    init(_ binaryMessenger: FlutterBinaryMessenger) {
        self._binaryMessenger = binaryMessenger
        self._handlers = TerminalHandlersApi.init(binaryMessenger: binaryMessenger)
        self._terminalDelegate = TerminalDelegatePlugin(_handlers)
        self._discoveryDelegate = DiscoveryDelegatePlugin()
        DiscoverReadersStreamHandler.register(with: binaryMessenger, streamHandler: _discoveryDelegate)
        self._readerDelegate = ReaderDelegatePlugin(_handlers)
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        if (Terminal.isInitialized()) { self._clean() }
        
        if (TerminalPlugin.shared != self) { return; }
        
        TerminalPlatformApiSetup.setUp(binaryMessenger: _binaryMessenger, api: nil)
    }
    
    func initialize(shouldPrintLogs: Bool) throws {
        // If a hot restart is performed in flutter the terminal is already initialized but we need to clean it up
        if Terminal.isInitialized() {
            _clean()
            return
        }
        
        Terminal.initWithTokenProvider(self._terminalDelegate, delegate: self._terminalDelegate)
        if (shouldPrintLogs) { Terminal.setLogListener { message in print(message) } }
    }
    
    func clearCachedCredentials() throws -> ClearCachedCredentialsResultApi {
        try Terminal.shared.clearCachedCredentials().get()
        self._clean();
        return ClearCachedCredentialsResultApi(
            isSuccessful: true,
            error: nil
        )
    }

// MARK: - Reader discovery, connection and updates
    private var _readers: [Reader] { get {
        return _discoveryDelegate.readers
    } }
    private let _readerDelegate: ReaderDelegatePlugin
    
    func getConnectionStatus() throws -> ConnectionStatusApi {
        return Terminal.shared.connectionStatus.toApi()
    }
    
    func supportsReadersOfType(
        deviceType: DeviceTypeApi?,
        discoveryConfiguration: any DiscoveryConfigurationApi
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
    
    func applyDiscoverReadersParameters(configuration: any DiscoveryConfigurationApi) throws {
        self._discoveryDelegate.configuration = try configuration.toHost()
    }
    
    func connectReader(
        serialNumber: String,
        configuration: any ConnectionConfigurationApi,
        completion: @escaping (Result<ReaderApi, any Error>) -> Void
    ) {
        handleResult(completion) {
            let configuration = try configuration.toHost(self._readerDelegate)
            guard let configuration else {
                throw PigeonError(code: "mek_stripe_terminal.unimplemented", message: "Unsupported connection configuration", details: nil)
            }
            let reader = try await Terminal.shared.connectReader(
                self._findReader(serialNumber),
                connectionConfig: configuration
            )
            return reader.toApi()
        }
    }
    
    func startEasyConnect(
        operationId: Int64,
        configuration: any EasyConnectConfigurationApi,
        completion: @escaping (Result<ReaderApi, any Error>) -> Void
    ) {
        completion(.failure(PigeonError(code: "", message: "Method not implemented", details: nil)))
        
        // Terminal.shared.easyConnect(configuration.toHost())
    }
    
    func stopEasyConnect(operationId: Int64, completion: @escaping (Result<Void, any Error>) -> Void) {
        completion(.failure(PigeonError(code: "", message: "Method not implemented", details: nil)))
    }
    
    func getConnectedReader() throws -> ReaderApi? {
        return Terminal.shared.connectedReader?.toApi()
    }
    
    func cancelReaderReconnection(completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            try await self._readerDelegate.cancelReconnection()
        }
    }
    
    func listLocations(
        endingBefore: String?,
        limit: Int64?,
        startingAfter: String?,
        completion: @escaping (Result<[LocationApi], any Error>) -> Void
    ) {
        handleResult(completion) {
            let params = ListLocationsParametersBuilder()
                .setEndingBefore(endingBefore)
                .setStartingAfter(startingAfter)
            limit.apply { params.setLimit(UInt($0)) }
            
            return try await Terminal.shared.listLocations(parameters: params.build()).0.map { $0.toApi() }
        }
    }
    
    func installAvailableUpdate() throws {
        Terminal.shared.installAvailableUpdate()
    }
    
    func cancelReaderUpdate(completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            try await self._readerDelegate.cancelUpdate()
        }
    }
    
    func rebootReader(completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            try await Terminal.shared.rebootReader()
        }
    }
    
    func disconnectReader(completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            try await Terminal.shared.disconnectReader()
        }
    }
    
    func setSimulatorConfiguration(configuration: SimulatorConfigurationApi) throws {
        Terminal.shared.simulatorConfiguration.availableReaderUpdate = configuration.update.toHost()
        Terminal.shared.simulatorConfiguration.simulatedCard = configuration.simulatedCard.toHost()
        Terminal.shared.simulatorConfiguration.simulatedTipAmount = configuration.simulatedTipAmount?.toNsNumber()
    }
    
// MARK: - Taking payments
    
    private var _paymentIntents: [String: PaymentIntent] = [:]
    
    func getPaymentStatus() throws -> PaymentStatusApi {
        return Terminal.shared.paymentStatus.toApi()
    }
    
    func createPaymentIntent(
        parameters: PaymentIntentParametersApi,
        completion: @escaping (Result<PaymentIntentApi, any Error>) -> Void
    ) {
        handleResult(completion) {
            let paymentIntent = try await Terminal.shared.createPaymentIntent(parameters.toHost())
            self._paymentIntents[paymentIntent.stripeId!] = paymentIntent
            return paymentIntent.toApi()
        }
    }
    
    func retrievePaymentIntent(
        clientSecret: String,
        completion: @escaping (Result<PaymentIntentApi, any Error>) -> Void
    ) {
        handleResult(completion) {
            let paymentIntent = try await Terminal.shared.retrievePaymentIntent(clientSecret: clientSecret)
            self._paymentIntents[paymentIntent.stripeId!] = paymentIntent
            return paymentIntent.toApi()
        }
    }
    
    private var _processPaymentIntentCancellables: [Int64: Cancelable] = [:]
    
    func startProcessPaymentIntent(
        operationId: Int64,
        paymentIntentId: String,
        requestDynamicCurrencyConversion: Bool,
        surchargeNotice: String?,
        skipTipping: Bool,
        tippingConfiguration: TippingConfigurationApi?,
        shouldUpdatePaymentIntent: Bool,
        customerCancellationEnabled: Bool,
        allowRedisplay: AllowRedisplayApi,
        confirmConfiguration: ConfirmPaymentIntentConfigurationApi,
        completion: @escaping (Result<PaymentIntentApi, any Error>) -> Void
    ) {
        handleError(completion) {
            let paymentIntent = try _findPaymentIntent(paymentIntentId)
            let collectConfig = try CollectPaymentIntentConfigurationBuilder()
                .setSurchargeNotice(surchargeNotice)
                .setRequestDynamicCurrencyConversion(requestDynamicCurrencyConversion)
                .setSkipTipping(skipTipping)
                .setTippingConfiguration(try tippingConfiguration?.toHost())
                .setUpdatePaymentIntent(shouldUpdatePaymentIntent)
                .setCustomerCancellation(customerCancellationEnabled ? .enableIfAvailable : .disableIfAvailable)
                .setAllowRedisplay(allowRedisplay.toHost())
                .build()
            let confirmConfig = try confirmConfiguration.toHost()
                
            self._processPaymentIntentCancellables[operationId] = Terminal.shared.processPaymentIntent(
                paymentIntent,
                collectConfig: collectConfig,
                confirmConfig: confirmConfig,
                completion: { paymentIntent, error in
                self._processPaymentIntentCancellables.removeValue(forKey: operationId)
                if let error = error as? NSError {
                    completion(.failure(error.toPlatformError()))
                    return
                }
                self._paymentIntents[paymentIntent!.stripeId!] = paymentIntent!
                completion(.success(paymentIntent!.toApi()))
            })
        }
    }
    
    func stopProcessPaymentIntent(operationId: Int64, completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            try await self._processPaymentIntentCancellables.removeValue(forKey: operationId)?.cancel()
        }
    }
    
    func cancelPaymentIntent(paymentIntentId: String, completion: @escaping (Result<PaymentIntentApi, any Error>) -> Void) {
        handleResult(completion) {
            let paymentIntent = try self._findPaymentIntent(paymentIntentId)
            let newPaymentIntent = try await Terminal.shared.cancelPaymentIntent(paymentIntent)
            self._paymentIntents.removeValue(forKey: paymentIntentId)
            return newPaymentIntent.toApi()
        }
    }

// MARK: - Saving payment details for later use
   
    private var _setupIntents: [String: SetupIntent] = [:]
    private var _cancelablesCollectSetupIntentPaymentMethod: [Int64: Cancelable] = [:]
    
    func createSetupIntent(
        customerId: String?,
        metadata: [String : String]?,
        onBehalfOf: String?,
        description: String?,
        usage: SetupIntentUsageApi?,
        completion: @escaping (Result<SetupIntentApi, any Error>) -> Void
    ) {
        handleResult(completion) {
            let params = SetupIntentParametersBuilder()
            params.setCustomer(customerId)
            params.setMetadata(metadata)
            params.setOnBehalfOf(onBehalfOf)
            params.setStripeDescription(description)
            usage.apply { params.setUsage($0.toHost()) }
            do {
                let setupIntent = try await Terminal.shared.createSetupIntent(params.build())
                self._setupIntents[setupIntent.stripeId!] = setupIntent
                return setupIntent.toApi()
            } catch let error as NSError {
                throw error.toPlatformError()
            }
        }
    }
    
    func retrieveSetupIntent(clientSecret: String, completion: @escaping (Result<SetupIntentApi, any Error>) -> Void) {
        handleResult(completion) {
            let setupIntent = try await Terminal.shared.retrieveSetupIntent(clientSecret: clientSecret)
            self._setupIntents[setupIntent.stripeId!] = setupIntent
            return setupIntent.toApi()
        }
    }
    
    func startProcessSetupIntent(
        operationId: Int64,
        setupIntentId: String,
        allowRedisplay: AllowRedisplayApi,
        customerCancellationEnabled: Bool,
        completion: @escaping (Result<SetupIntentApi, any Error>) -> Void
    ) {
        handleError(completion) {
            let setupIntent = try self._findSetupIntent(setupIntentId)
            let config = CollectSetupIntentConfigurationBuilder()
                .setCustomerCancellation(customerCancellationEnabled ? .enableIfAvailable : .disableIfAvailable)
            
            self._cancelablesCollectSetupIntentPaymentMethod[operationId] = Terminal.shared.processSetupIntent(
                setupIntent,
                allowRedisplay: allowRedisplay.toHost(),
                collectConfig: try config.build(),
                completion: { setupIntent, error in
                    self._cancelablesCollectSetupIntentPaymentMethod.removeValue(forKey: operationId)
                    if let error = error as? NSError {
                        completion(.failure(error.toPlatformError()))
                        return
                    }
                    self._setupIntents[setupIntent!.stripeId!] = setupIntent!
                    completion(.success(setupIntent!.toApi()))
            })
        }
    }
    
    func stopProcessSetupIntent(operationId: Int64, completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            try await self._cancelablesCollectSetupIntentPaymentMethod.removeValue(forKey: operationId)?.cancel()
        }
    }
    
    func cancelSetupIntent(setupIntentId: String, completion: @escaping (Result<SetupIntentApi, any Error>) -> Void) {
        handleResult(completion) {
            let setupIntent = try self._findSetupIntent(setupIntentId)
            let newSetupIntent = try await Terminal.shared.cancelSetupIntent(setupIntent)
            self._setupIntents.removeValue(forKey: setupIntentId)
            return newSetupIntent.toApi()
        }
    }

// MARK: - Card-present refunds
    private var _cancelablesCollectRefundPaymentMethod: [Int64: Cancelable] = [:]
    
    func startProcessRefund(
        operationId: Int64,
        chargeId: String?,
        paymentIntentId: String?,
        paymentIntentClientSecret: String?,
        amount: Int64,
        currency: String,
        metadata: [String : String]?,
        reverseTransfer: Bool?,
        refundApplicationFee: Bool?,
        customerCancellationEnabled: Bool,
        completion: @escaping (Result<RefundApi, any Error>) -> Void
    ) {
        handleError(completion) {
            let params = chargeId != nil
                ? RefundParametersBuilder(
                    chargeId: chargeId!,
                    amount: amount.toUInt(),
                    currency: currency
                )
                : RefundParametersBuilder(
                    paymentIntentId: paymentIntentId!,
                    clientSecret: paymentIntentClientSecret!,
                    amount: amount.toUInt(),
                    currency: currency
                )
            params.setMetadata(metadata)
            reverseTransfer.apply(params.setReverseTransfer)
            params.setMetadata(metadata)
            
            let config = CollectRefundConfigurationBuilder()
                .setCustomerCancellation(customerCancellationEnabled ? .enableIfAvailable : .disableIfAvailable)
            
            _cancelablesCollectRefundPaymentMethod[operationId] = Terminal.shared.processRefund(
                try params.build(),
                collectConfig: try config.build(),
                completion: { refund, error in
                    self._cancelablesCollectRefundPaymentMethod.removeValue(forKey: operationId)
                    if let error = error {
                        completion(.failure(error.toPlatformError()))
                        return
                    }
                    completion(.success(refund!.toApi()))
            })
        }
    }
    
    func stopProcessRefund(operationId: Int64, completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            try await self._cancelablesCollectRefundPaymentMethod.removeValue(forKey: operationId)?.cancel()
        }
    }

// MARK: - Display information to customers
    
    func setReaderDisplay(cart: CartApi, completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            try await Terminal.shared.setReaderDisplay(cart.toHost())
        }
    }
    
    func clearReaderDisplay(completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            try await Terminal.shared.clearReaderDisplay()
        }
    }
    
    func setTapToPayUXConfiguration(configuration: TapToPayUxConfigurationApi) throws {
        throw PigeonError(code: "", message: "setTapToPayUXConfiguration method not supported on ios device", details: nil);

    }
    
    func isTapToPayAccountLinked(onBehalfOf: String?, completion: @escaping (Result<Bool, any Error>) -> Void) {
        if #available(iOS 16.4, *) {
            Terminal.shared.isTapToPayAccountLinked(onBehalfOf) { linked, error in
                if let error = error {
                    completion(.failure((error as NSError).toPlatformError()))
                } else {
                    completion(.success(linked?.boolValue ?? false))
                }
            }
        } else {
            completion(.success(false))
        }
    }
    
// MARK: - PRIVATE METHODS
    
    private func _clean() {
        if (Terminal.shared.connectedReader != nil) { Terminal.shared.disconnectReader  { error in } }
        
        self._discoveryDelegate.clear()
        
        self._processPaymentIntentCancellables.values.forEach { $0.cancel { error in } }
        self._processPaymentIntentCancellables = [:]
        // self._confirmSetupIntentCancelables.values.forEach { $0.cancel { error in } }
        // self._confirmSetupIntentCancelables = [:]
        self._paymentIntents = [:]

        self._cancelablesCollectSetupIntentPaymentMethod.values.forEach { $0.cancel { error in } }
        self._cancelablesCollectSetupIntentPaymentMethod = [:]
        // self._confirmPaymentIntentCancelables.values.forEach { $0.cancel { error in } }
        // self._confirmPaymentIntentCancelables = [:]
        self._setupIntents = [:]

        self._cancelablesCollectRefundPaymentMethod.values.forEach { $0.cancel { error in } }
        self._cancelablesCollectRefundPaymentMethod = [:]
        // self._confirmRefundCancelables.values.forEach { $0.cancel { error in } }
        // self._confirmRefundCancelables = [:]
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

func handleResult<R>(_ completion: @escaping (Result<R, any Error>) -> Void, callback: @escaping () async throws -> R) {
    Task {
        do {
            let result = try await callback();
            completion(.success(result))
        } catch let error as NSError {
            completion(.failure(error.toPlatformError()))
        }
    }
}

func handleError<R>(_ completion: @escaping (Result<R, any Error>) -> Void, callback: () throws -> Void) {
    do {
        try callback();
    } catch let error as NSError {
        completion(.failure(error.toPlatformError()))
    }
}

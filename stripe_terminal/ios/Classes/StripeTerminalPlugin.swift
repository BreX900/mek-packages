import Flutter
import StripeTerminal
import UIKit

public class StripeTerminalPlugin: NSObject, FlutterPlugin, StripeTerminalPlatformApi, ConnectionTokenProvider {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = StripeTerminalPlugin(registrar.messenger())
        setStripeTerminalPlatformApiHandler(registrar.messenger(), instance)
        instance.onAttachedToEngine()
    }
    
    private let discoverReadersController: DiscoverReadersControllerApi
    private let handlers: StripeTerminalHandlersApi
    private var readers: [Reader] = []
    private let _readerDelegate: ReaderDelegatePlugin
    private let _readerReconnectionDelegate: ReaderReconnectionDelegatePlugin

    init(_ binaryMessenger: FlutterBinaryMessenger) {
        self.handlers = StripeTerminalHandlersApi(binaryMessenger)
        self.discoverReadersController = DiscoverReadersControllerApi(binaryMessenger: binaryMessenger)
        self._readerDelegate = ReaderDelegatePlugin(handlers)
        self._readerReconnectionDelegate = ReaderReconnectionDelegatePlugin(handlers)
    }

    public func onAttachedToEngine() {
        self.setupDiscoverReaders()
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        self.discoverReadersController.removeHandler()
        removeStripeTerminalPlatformApiHandler()
        self.clean()
    }
    
    func onInit() async throws {
        // If a hot restart is performed in flutter the terminal is already initialized but we need to clean it up
        if Terminal.hasTokenProvider() {
            clean()
            return
        }
        
        Terminal.setTokenProvider(self)
        Terminal.shared.delegate = TerminalDelegatePlugin(handlers)
    }

// Reader discovery, connection and updates
    private var _discoverReaderCancelable: Cancelable? = nil

    func onConnectionStatus() async throws -> ConnectionStatusApi {
        return Terminal.shared.connectionStatus.toApi()
    }
    
    func setupDiscoverReaders() {
        discoverReadersController.setHandler({
            sink, discoveryMethod, simulated, locationId -> FlutterError? in
            
            let discoveryMethodHost = discoveryMethod.toHost()
            guard let discoveryMethodHost else {
                return FlutterError(code: "discoveryMethodNotSupported", message: nil, details: nil)
            }
            // Ignore error, the previous stream can no longer receive events
            self._discoverReaderCancelable?.cancel { error in }
            self._discoverReaderCancelable = Terminal.shared.discoverReaders(
                DiscoveryConfiguration(
                    discoveryMethod: discoveryMethodHost,
                    locationId: locationId,
                    simulated: simulated
                ),
                delegate: DiscoveryDelegatePlugin(sink)
            ) { error in
                if let error = error {
                    let platformError = error.toApi()
                    sink.error(platformError.code, platformError.message, platformError.details)
                }
                sink.endOfStream()
            }
            return nil
        }, { discoveryMethod, simulated, locationId -> FlutterError? in
            // Ignore error, flutter stream already closed
            self._discoverReaderCancelable?.cancel { error in }
            return nil
        })
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
                findReader(serialNumber),
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
                findReader(serialNumber),
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
                findReader(serialNumber),
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

    func onConnectedReader() async throws -> ReaderApi? {
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
    
    func onInstallAvailableUpdate() async throws {
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
    
    private var paymentIntents: [String: PaymentIntent] = [:]

    func onRetrievePaymentIntent(
        _ clientSecret: String
    ) async throws -> PaymentIntentApi {
        do {
            let paymentIntent = try await Terminal.shared.retrievePaymentIntent(clientSecret: clientSecret)
            paymentIntents[paymentIntent.stripeId] = paymentIntent
            return paymentIntent.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }

    private var cancelablesCollectPaymentMethod: [Int: Cancelable] = [:]

    func onStartCollectPaymentMethod(
        _ result: Result<PaymentIntentApi>,
        _ operationId: Int,
        _ paymentIntentId: String,
        _: Bool,
        _: Bool
    ) throws {
        let paymentIntent = try findPaymentIntent(paymentIntentId)
        self.cancelablesCollectPaymentMethod[operationId] = Terminal.shared.collectPaymentMethod(paymentIntent) { paymentIntent, error in
            if let error = error as? NSError {
                let platformError = error.toApi()
                result.error(platformError.code, platformError.message, platformError.details)
                return
            }
            self.paymentIntents[paymentIntent!.stripeId] = paymentIntent!
            result.success(paymentIntent!.toApi())
        }
    }

    func onStopCollectPaymentMethod(
        _ operationId: Int
    ) async throws {
        try await cancelablesCollectPaymentMethod.removeValue(forKey: operationId)?.cancel()
    }

    func onProcessPayment(
        _ paymentIntentId: String
    ) async throws -> PaymentIntentApi {
        let paymentIntent = try findPaymentIntent(paymentIntentId)
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
    
// Saving payment details for later use
   
    private var cancelablesReadReusableCard: [Int: Cancelable] = [:]

    func onStartReadReusableCard(
        _ result: Result<PaymentMethodApi>,
        _ id: Int,
        _: String?,
        _: [String: String]?
    ) throws {
        cancelablesReadReusableCard[id] = Terminal.shared.readReusableCard(
            ReadReusableCardParameters(),
            completion: { paymentMethod, error in
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
        _ id: Int
    ) async throws {
        try await cancelablesReadReusableCard.removeValue(forKey: id)?.cancel()
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
    
    public func fetchConnectionToken() async throws -> String {
        return try await handlers.requestConnectionToken()
    }
    
    private func clean() {
        self._discoverReaderCancelable?.cancel { error in }
        
        self.cancelablesCollectPaymentMethod.values.forEach { $0.cancel { error in } }
        self.cancelablesCollectPaymentMethod.removeAll()
        self.cancelablesReadReusableCard.values.forEach { $0.cancel { error in } }
        self.cancelablesReadReusableCard.removeAll()
        
        self.readers = []
        self.paymentIntents = [:]
    }

    private func findReader(_ serialNumber: String) throws -> Reader {
        guard let reader = readers.first(where: { $0.serialNumber == serialNumber }) else {
            throw PlatformError(
                TerminalExceptionCodeApi.readerCommunicationError.rawValue,
                "Reader with provided serial number no longer exists"
            )
        }
        return reader
    }
    
    private func findPaymentIntent(_ paymentIntentId: String) throws -> PaymentIntent {
        let paymentIntent = paymentIntents[paymentIntentId]
        guard let paymentIntent else {
            throw PlatformError(TerminalExceptionCodeApi.paymentIntentNotRetrieved.rawValue, nil, nil)
        }
        return paymentIntent
    }
}

extension Dictionary {
    func containsKey(_ key: Key) -> Bool {
        return contains(where: { entry in entry.key == key })
    }
}

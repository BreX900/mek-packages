import Flutter
import StripeTerminal
import UIKit

public class StripeTerminalPlugin: NSObject, FlutterPlugin, StripeTerminalApi, ConnectionTokenProvider {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = StripeTerminalPlugin(registrar.messenger())
        setStripeTerminalApiHandler(registrar.messenger(), instance)
        instance.onAttachedToEngine()
    }
    
    private let discoverReadersController: DiscoverReadersControllerApi
    private let handlers: StripeTerminalHandlersApi
    private var readers: [Reader] = []

    init(_ binaryMessenger: FlutterBinaryMessenger) {
        self.handlers = StripeTerminalHandlersApi(binaryMessenger)
        self.discoverReadersController = DiscoverReadersControllerApi(binaryMessenger: binaryMessenger)
    }

    public func onAttachedToEngine() {
        self.setupDiscoverReaders()
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        self.discoverReadersController.removeHandler()
        removeStripeTerminalApiHandler()
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

    public func fetchConnectionToken() async throws -> String {
        return try await handlers.requestConnectionToken()
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

    func onConnectionStatus() async throws -> ConnectionStatusApi {
        return Terminal.shared.connectionStatus.toApi()
    }

    func onConnectBluetoothReader(
        _ serialNumber: String,
        _ locationId: String,
        _: Bool
    ) async throws -> StripeReaderApi {
        do {
            let reader = try await Terminal.shared.connectBluetoothReader(
                findReader(serialNumber),
                delegate: ReaderDelegatePlugin(handlers),
                connectionConfig: BluetoothConnectionConfiguration(
                    locationId: locationId
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
    ) async throws -> StripeReaderApi {
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
    ) async throws -> StripeReaderApi {
        do {
            let reader = try await Terminal.shared.connectLocalMobileReader(
                findReader(serialNumber),
                delegate: ReaderDelegatePlugin(handlers),
                connectionConfig: LocalMobileConnectionConfiguration(
                    locationId: locationId
                )
            )
            return reader.toApi()
        } catch let error as NSError {
            throw error.toApi()
        }
    }

    func onConnectedReader() async throws -> StripeReaderApi? {
        return Terminal.shared.connectedReader?.toApi()
    }

    func onInstallAvailableUpdate(_: String) async throws {
        Terminal.shared.installAvailableUpdate()
    }

    func onDisconnectReader() async throws {
        do {
            try await Terminal.shared.disconnectReader()
        } catch let error as NSError {
            throw error.toApi()
        }
    }

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

    private var cancelablesReadReusableCard: [Int: Cancelable] = [:]

    func onStartReadReusableCard(
        _ result: Result<StripePaymentMethodApi>,
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
    
    private var paymentIntents: [String: PaymentIntent] = [:]

    func onRetrievePaymentIntent(
        _ clientSecret: String
    ) async throws -> StripePaymentIntentApi {
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
        _ result: Result<StripePaymentIntentApi>,
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
    ) async throws -> StripePaymentIntentApi {
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
    
    private var _discoverReaderCancelable: Cancelable? = nil
    
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
                if let error = error as? NSError {
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
                StripeTerminalExceptionCodeApi.readerCommunicationError.rawValue,
                "Reader with provided serial number no longer exists"
            )
        }
        return reader
    }
    
    private func findPaymentIntent(_ paymentIntentId: String) throws -> PaymentIntent {
        let paymentIntent = paymentIntents[paymentIntentId]
        guard let paymentIntent else {
            throw PlatformError(StripeTerminalExceptionCodeApi.paymentIntentNotRetrieved.rawValue, nil, nil)
        }
        return paymentIntent
    }
}

extension Dictionary {
    func containsKey(_ key: Key) -> Bool {
        return contains(where: { entry in entry.key == key })
    }
}

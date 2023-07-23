import Flutter
import StripeTerminal
import UIKit

public class StripeTerminalPlugin: NSObject, FlutterPlugin, StripeTerminalApi, ConnectionTokenProvider, TerminalDelegate {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let api = StripeTerminalHandlersApi(registrar.messenger())
        let instance = StripeTerminalPlugin(api)
        setupStripeTerminalApi(registrar.messenger(), instance)
    }

    private let handlers: StripeTerminalHandlersApi
    var readers: [Reader] = []

    init(_ handlers: StripeTerminalHandlersApi) {
        self.handlers = handlers
    }

    func onInit() async throws {
        Terminal.setTokenProvider(self)
        Terminal.shared.delegate = self
    }

    public func fetchConnectionToken() async throws -> String {
        return try await handlers.requestConnectionToken()
    }

    func onListLocations(_ endingBefore: String?, _ limit: Int?, _ startingAfter: String?) async throws -> [LocationApi] {
        do {
            let locations = try await Terminal.shared.listLocations(parameters: ListLocationsParameters(
                limit: limit as NSNumber?,
                endingBefore: endingBefore,
                startingAfter: startingAfter
            ))
            return locations.0.map { $0.toApi() }
        } catch let error as NSError {
            try throwPlatformError(error)
            throw error
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
        let reader = try findReader(serialNumber)

        do {
            let reader = try await Terminal.shared.connectBluetoothReader(
                reader,
                delegate: ReaderDelegate(handlersApi: handlers),
                connectionConfig: BluetoothConnectionConfiguration(
                    locationId: locationId
                )
            )
            return reader.toApi()
        } catch let error as NSError {
            try throwPlatformError(error)
            throw error
        }
    }

    func onConnectInternetReader(
        _ serialNumber: String,
        _ failIfInUse: Bool
    ) async throws -> StripeReaderApi {
        let reader = try findReader(serialNumber)

        do {
            let reader = try await Terminal.shared.connectInternetReader(
                reader,
                connectionConfig: InternetConnectionConfiguration(
                    failIfInUse: failIfInUse
                )
            )
            return reader.toApi()
        } catch let error as NSError {
            try throwPlatformError(error)
            throw error
        }
    }

    func onConnectMobileReader(
        _ serialNumber: String,
        _ locationId: String
    ) async throws -> StripeReaderApi {
        let reader = try findReader(serialNumber)

        do {
            let reader = try await Terminal.shared.connectLocalMobileReader(
                reader,
                delegate: ReaderDelegate(handlersApi: handlers),
                connectionConfig: LocalMobileConnectionConfiguration(
                    locationId: locationId
                )
            )
            return reader.toApi()
        } catch let error as NSError {
            try throwPlatformError(error)
            throw error
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
            try throwPlatformError(error)
        }
    }

    func onSetReaderDisplay(
        _ cart: CartApi
    ) async throws {
        do {
            try await Terminal.shared.setReaderDisplay(cart.toHost())
        } catch let error as NSError {
            try throwPlatformError(error)
        }
    }

    func onClearReaderDisplay() async throws {
        do {
            try await Terminal.shared.clearReaderDisplay()
        } catch let error as NSError {
            try throwPlatformError(error)
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
                    result.error(error.toApi(), error.localizedDescription, nil)
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

    func onRetrievePaymentIntent(
        _ clientSecret: String
    ) async throws -> StripePaymentIntentApi {
        do {
            let paymentIntent = try await Terminal.shared.retrievePaymentIntent(clientSecret: clientSecret)
            return paymentIntent.toApi()
        } catch let error as NSError {
            try throwPlatformError(error)
            throw error
        }
    }

    private var cancelablesCollectPaymentMethod: [Int: Cancelable?] = [:]

    func onStartCollectPaymentMethod(
        _ result: Result<StripePaymentIntentApi>,
        _ id: Int,
        _ clientSecret: String,
        _: Bool,
        _: Bool
    ) throws {
        cancelablesCollectPaymentMethod[id] = nil
        Terminal.shared.retrievePaymentIntent(clientSecret: clientSecret) { paymentIntent, error in
            if let error = error as? NSError {
                result.error(error.toApi(), error.localizedDescription, nil)
                return
            }
            if !self.cancelablesCollectPaymentMethod.containsKey(id) {
                return
            }

            self.cancelablesCollectPaymentMethod[id] = Terminal.shared.collectPaymentMethod(paymentIntent!) { paymentIntent, error in
                if let error = error as? NSError {
                    result.error(error.toApi(), error.localizedDescription, nil)
                    return
                }
                result.success(paymentIntent!.toApi())
            }
        }
    }

    func onStopCollectPaymentMethod(
        _ id: Int
    ) async throws {
        try await cancelablesCollectPaymentMethod.removeValue(forKey: id)??.cancel()
    }

    func onProcessPayment(
        _ clientSecret: String
    ) async throws -> StripePaymentIntentApi {
        do {
            let paymentIntent = try await Terminal.shared.retrievePaymentIntent(clientSecret: clientSecret)
            let (intent, error) = await Terminal.shared.processPayment(paymentIntent)
            if let error = error {
                throw PlatformError(code: error.declineCode!, message: error.localizedDescription, details: nil)
            }

            return intent!.toApi()
        } catch let error as NSError {
            try throwPlatformError(error)
            throw error
        }
    }

    public func terminal(_: Terminal, didReportUnexpectedReaderDisconnect reader: Reader) {
        handlers.unexpectedReaderDisconnect(reader: reader.toApi())
    }

    public func terminal(_: Terminal, didChangePaymentStatus status: PaymentStatus) {
        handlers.paymentStatusChange(paymentStatus: status.toApi())
    }

    public func terminal(_: Terminal, didChangeConnectionStatus status: ConnectionStatus) {
        handlers.connectionStatusChange(connectionStatus: status.toApi())
    }

    private func throwPlatformError(_ error: NSError) throws {
        throw PlatformError(code: error.toApi(), message: error.localizedDescription, details: nil)
    }

    private func findReader(_ serialNumber: String) throws -> Reader {
        let reader = readers.first { reader in
            reader.serialNumber == serialNumber
        }
        guard let reader = reader else {
            throw PlatformError(
                code: StripeTerminalExceptionCodeApi.readerCommunicationError.rawValue,
                message: "Reader with provided serial number no longer exists",
                details: nil
            )
        }
        return reader
    }
}

extension Dictionary {
    func containsKey(_ key: Key) -> Bool {
        return contains(where: { entry in entry.key == key })
    }
}

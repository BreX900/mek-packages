import Flutter
import StripeTerminal
import UIKit

public class StripeTerminalPlugin: NSObject, FlutterPlugin, StripeTerminalApi, ConnectionTokenProvider {

    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let api = StripeTerminalHandlersApi(registrar.messenger())
        let instance = StripeTerminalPlugin(api)
        setupStripeTerminalApi(registrar.messenger(), instance)
    }
    
    private let api: StripeTerminalHandlersApi
    var readers: [Reader] = []

    init(_ api: StripeTerminalHandlersApi) {
        self.api = api
    }
    
    func onInit(_: Result<Void>) throws {
        Terminal.setTokenProvider(self)
    }
    
    public func fetchConnectionToken() async throws -> String {
        return try await self.api.requestConnectionToken()
    }
    
    private func throwPlataformError(_ error: NSError) throws {
//        let terminalError = ErrorCode(_nsError: error)
        throw PlatformError(code: error.toApi(), message: error.localizedDescription, details: nil)
    }
    private func findReader(_ serialNumber: String) throws -> Reader {
        let reader = readers.first { reader in
            return reader.serialNumber == serialNumber
        }
        if reader == nil {
            throw PlatformError(
                code: StripeTerminalExceptionCodeApi.readerCommunicationError.rawValue,
                message: "Reader with provided serial number no longer exists",
                details: nil
            )
        }
        return reader!
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
            try throwPlataformError(error)
        }
    }

    func onConnectionStatus(_ result: Result<ConnectionStatusApi>) async throws -> ConnectionStatusApi {
        return Terminal.shared.connectionStatus.toApi()
    }

    func onConnectBluetoothReader(
        _ serialNumber: String,
        _ locationId: String,
        _ autoReconnectOnUnexpectedDisconnect: Bool
    ) async throws -> StripeReaderApi {
        let reader = try findReader(serialNumber)

        do {
            let reader = try await Terminal.shared.connectBluetoothReader(
                reader,
                delegate: self,
                connectionConfig: BluetoothConnectionConfiguration(
                    locationId: locationId
                )
            );
            return reader.toApi()
        } catch let error as NSError {
            try throwPlataformError(error)
        }
    }

    func onConnectInternetReader(
        _ serialNumber: String,
        _ failIfInUse: Bool
    ) async throws -> StripeReaderApi {
        let reader = try findReader(serialNumber)

        do {
            let reader = try await Terminal.shared.connectInternetReader(reader,
                connectionConfig: InternetConnectionConfiguration(
                    failIfInUse: failIfInUse
                )
            )
            return reader.toApi()
        } catch let error as NSError {
            try throwPlataformError(error)
        }
    }

    func onConnectMobileReader(
        _ serialNumber: String,
        _ locationId: String
    ) async throws -> StripeReaderApi {
        let reader = try findReader(serialNumber)

        do {
            let reader = try await Terminal.shared.connectLocalMobileReader(reader, delegate: self,
                connectionConfig: LocalMobileConnectionConfiguration(
                    locationId: locationId
                )
            )
            return reader.toApi()
        } catch let error as NSError {
            try throwPlataformError(error)
        }
    }

    func onConnectedReader() async throws -> StripeReaderApi? {
        return Terminal.shared.connectedReader?.toApi()
    }

    func onDisconnectReader() async throws -> Void {
        do {
            try await Terminal.shared.disconnectReader()
        } catch let error as NSError {
            try throwPlataformError(error)
        }
    }

    func onSetReaderDisplay(
        _ cart: CartApi
    ) async throws -> Void {
        do {
            try await Terminal.shared.setReaderDisplay(cart.toHost())
        } catch let error as NSError {
            try throwPlataformError(error)
        }
    }

    func onClearReaderDisplay() async throws -> Void {
        do {
            try await Terminal.shared.clearReaderDisplay()
        } catch let error as NSError {
            try throwPlataformError(error)
        }
    }
    
    private var cancelablesReadReusableCard: [Int: Cancelable] = [:]

    func onStartReadReusableCard(
        _ result: Result<StripePaymentMethodApi>,
        _ id: Int,
        _ customer: String?,
        _ metadata: [String: String]?
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
    ) async throws -> Void {
        try await cancelablesReadReusableCard.removeValue(forKey: id)?.cancel()
    }

    func onRetrievePaymentIntent(_ result: Result<StripePaymentIntentApi>, _ clientSecret: String) throws {
        Terminal.shared.retrievePaymentIntent(clientSecret: clientSecret) { intent, error in
            if let error {
                result.error("", error.localizedDescription, nil)
            } else if let intent {
                // TODO: MEGA TODO!!
                let stripePaymentIntent = StripePaymentIntentApi(id: intent.stripeId,
                                                                 amount: Double(intent.amount),
                                                                 amountCapturable: 0, amountReceived: 0, application: nil,
                                                                 applicationFeeAmount: nil, captureMethod: intent.captureMethod.rawValue.description,
                                                                 cancellationReason: nil, canceledAt: nil, clientSecret: clientSecret,
                                                                 confirmationMethod: nil, created: intent.created.hashValue, currency: intent.currency,
                                                                 customer: nil,
                                                                 description: intent.description,
                                                                 invoice: nil, livemode: false, metadata: intent.metadata,
                                                                 onBehalfOf: nil,
                                                                 paymentMethodId: nil,
                                                                 status: PaymentIntentStatusApi.startingFrom(intent.status),
                                                                 review: nil, receiptEmail: nil, setupFutureUsage: nil, transferGroup: nil)

                result.success(stripePaymentIntent)
            }
        }
    }

    func onCollectPaymentMethod(_ result: Result<StripePaymentIntentApi>, _ clientSecret: String, _: Bool, _: Bool) throws {
        // TODO: MISSING
        Terminal.shared.collectPaymentMethod(PaymentIntent()) { intent, error in
            if let error {
                result.error("", error.localizedDescription, nil)
            } else if let intent {
                // TODO: MEGA TODO
                let stripePaymentIntent = StripePaymentIntentApi(id: intent.stripeId,
                                                                 amount: Double(intent.amount),
                                                                 amountCapturable: 0, amountReceived: 0, application: nil,
                                                                 applicationFeeAmount: nil, captureMethod: intent.captureMethod.rawValue.description,
                                                                 cancellationReason: nil, canceledAt: nil, clientSecret: clientSecret,
                                                                 confirmationMethod: nil, created: intent.created.hashValue, currency: intent.currency,
                                                                 customer: nil,
                                                                 description: intent.description,
                                                                 invoice: nil, livemode: false, metadata: intent.metadata,
                                                                 onBehalfOf: nil,
                                                                 paymentMethodId: nil,
                                                                 status: PaymentIntentStatusApi.startingFrom(intent.status),
                                                                 review: nil, receiptEmail: nil, setupFutureUsage: nil, transferGroup: nil)

                result.success(stripePaymentIntent)
            }
        }
    }

    func onProcessPayment(_ result: Result<StripePaymentIntentApi>, _ clientSecret: String) throws {
        // TODO: MISSING INTENT
        Terminal.shared.processPayment(PaymentIntent()) { intent, error in
            if let error {
                result.error("", error.localizedDescription, nil)
            } else if let intent {
                // TODO: MEGA TODO
                let stripePaymentIntent = StripePaymentIntentApi(id: intent.stripeId,
                                                                 amount: Double(intent.amount),
                                                                 amountCapturable: 0, amountReceived: 0, application: nil,
                                                                 applicationFeeAmount: nil, captureMethod: intent.captureMethod.rawValue.description,
                                                                 cancellationReason: nil, canceledAt: nil, clientSecret: clientSecret,
                                                                 confirmationMethod: nil, created: intent.created.hashValue, currency: intent.currency,
                                                                 customer: nil,
                                                                 description: intent.description,
                                                                 invoice: nil, livemode: false, metadata: intent.metadata,
                                                                 onBehalfOf: nil,
                                                                 paymentMethodId: nil,
                                                                 status: PaymentIntentStatusApi.startingFrom(intent.status),
                                                                 review: nil, receiptEmail: nil, setupFutureUsage: nil, transferGroup: nil)

                result.success(stripePaymentIntent)
            }
        }
    }


}

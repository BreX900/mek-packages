import Flutter

struct PlatformError: Error {
    let code: String
    let message: String?
    let details: String?
}

class Result<T> {
    private let result: FlutterResult
    private let serializer: (T) -> Any?

    init(
        _ result: @escaping FlutterResult,
        _ serializer: @escaping (T) -> Any?
    ) {
        self.result = result
        self.serializer = serializer
    }

    func success(
        _ data: T
    ) { result(serializer(data)) }

    func error(
        _ code: String,
        _ message: String,
        _ details: Any?
    ) {
        result(FlutterError(code: code, message: message, details: details))
    }
}

class ControllerSink<T> {
    private let sink: FlutterEventSink
    private let serializer: (T) -> Any?

    init(
        _ sink: @escaping FlutterEventSink,
        _ serializer: @escaping (T) -> Any?
    ) {
        self.sink = sink
        self.serializer = serializer
    }

    func success(
        _ data: T
    ) { sink(serializer(data)) }

    func error(
        _ code: String,
        _ message: String,
        _ details: Any?
    ) {
        sink(FlutterError(code: code, message: message, details: details))
    }

    func endOfStream() { sink(FlutterEndOfEventStream) }
}

class ControllerHandler: NSObject, FlutterStreamHandler {
    private let _onListen: (_ arguments: Any?, _ events: @escaping FlutterEventSink) -> FlutterError?
    private let _onCancel: (_ arguments: Any?) -> FlutterError?

    init(
        _ _onListen: @escaping (_ arguments: Any?, _ events: @escaping FlutterEventSink) -> FlutterError?,
        _ _onCancel: @escaping (_ arguments: Any?) -> FlutterError?
    ) {
        self._onListen = _onListen
        self._onCancel = _onCancel
    }

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? { _onListen(arguments, events) }

    func onCancel(
        withArguments arguments: Any?
    ) -> FlutterError? { _onCancel(arguments) }
}

protocol StripeTerminalApi {
    func onListLocations(
        _ result: Result<[LocationApi]>,
        _ endingBefore: String?,
        _ limit: Int?,
        _ startingAfter: String?
    ) throws

    func onConnectionStatus(
        _ result: Result<ConnectionStatusApi>
    ) throws

    func onConnectBluetoothReader(
        _ result: Result<StripeReaderApi>,
        _ serialNumber: String,
        _ locationId: String,
        _ autoReconnectOnUnexpectedDisconnect: Bool
    ) throws

    func onConnectInternetReader(
        _ result: Result<StripeReaderApi>,
        _ serialNumber: String,
        _ failIfInUse: Bool
    ) throws

    func onConnectMobileReader(
        _ result: Result<StripeReaderApi>,
        _ serialNumber: String,
        _ locationId: String
    ) throws

    func onConnectedReader(
        _ result: Result<StripeReaderApi?>
    ) throws

    func onDisconnectReader(
        _ result: Result<Void>
    ) throws

    func onSetReaderDisplay(
        _ result: Result<Void>,
        _ cart: CartApi
    ) throws

    func onClearReaderDisplay(
        _ result: Result<Void>
    ) throws

    func onReadReusableCard(
        _ result: Result<StripePaymentMethodApi>,
        _ customer: String?,
        _ metadata: [String: String]?
    ) throws

    func onRetrievePaymentIntent(
        _ result: Result<StripePaymentIntentApi>,
        _ clientSecret: String
    ) throws

    func onCollectPaymentMethod(
        _ result: Result<StripePaymentIntentApi>,
        _ clientSecret: String,
        _ moto: Bool,
        _ skipTipping: Bool
    ) throws

    func onProcessPayment(
        _ result: Result<StripePaymentIntentApi>,
        _ clientSecret: String
    ) throws

    func onInit(
        _ result: Result<Void>
    ) throws
}

class DiscoverReadersControllerApi {
    private let channel: FlutterEventChannel

    init(
        binaryMessenger: FlutterBinaryMessenger
    ) {
        channel = FlutterEventChannel(name: "StripeTerminal#discoverReaders", binaryMessenger: binaryMessenger)
    }

    func setHandler(
        _ onListen: @escaping (_ sink: ControllerSink<[StripeReaderApi]>,_ discoveryMethod: DiscoveryMethodApi,_ simulated: Bool,_ locationId: String?) -> FlutterError?,
        _ onCancel: @escaping (_ discoveryMethod: DiscoveryMethodApi,_ simulated: Bool,_ locationId: String?) -> FlutterError?
    ) {
        channel.setStreamHandler(ControllerHandler({ arguments, events in
            let args = arguments as! [Any?]
            let sink = ControllerSink<[StripeReaderApi]>(events) {$0.map { $0.serialize() }}
            return onListen(sink,DiscoveryMethodApi(rawValue: args[0] as! Int)!,args[1] as! Bool,args[2] as? String)
        }, { arguments in
            let args = arguments as! [Any?]
            return onCancel(DiscoveryMethodApi(rawValue: args[0] as! Int)!,args[1] as! Bool,args[2] as? String)
        }))
    }

    func removeHandler() { channel.setStreamHandler(nil) }
}

class OnConnectionStatusChangeControllerApi {
    private let channel: FlutterEventChannel

    init(
        binaryMessenger: FlutterBinaryMessenger
    ) {
        channel = FlutterEventChannel(name: "StripeTerminal#_onConnectionStatusChange", binaryMessenger: binaryMessenger)
    }

    func setHandler(
        _ onListen: @escaping (_ sink: ControllerSink<ConnectionStatusApi>) -> FlutterError?,
        _ onCancel: @escaping () -> FlutterError?
    ) {
        channel.setStreamHandler(ControllerHandler({ arguments, events in
            let args = arguments as! [Any?]
            let sink = ControllerSink<ConnectionStatusApi>(events) {$0.rawValue}
            return onListen(sink)
        }, { arguments in
            let args = arguments as! [Any?]
            return onCancel()
        }))
    }

    func removeHandler() { channel.setStreamHandler(nil) }
}

class OnUnexpectedReaderDisconnectControllerApi {
    private let channel: FlutterEventChannel

    init(
        binaryMessenger: FlutterBinaryMessenger
    ) {
        channel = FlutterEventChannel(name: "StripeTerminal#_onUnexpectedReaderDisconnect", binaryMessenger: binaryMessenger)
    }

    func setHandler(
        _ onListen: @escaping (_ sink: ControllerSink<StripeReaderApi>) -> FlutterError?,
        _ onCancel: @escaping () -> FlutterError?
    ) {
        channel.setStreamHandler(ControllerHandler({ arguments, events in
            let args = arguments as! [Any?]
            let sink = ControllerSink<StripeReaderApi>(events) {$0.serialize()}
            return onListen(sink)
        }, { arguments in
            let args = arguments as! [Any?]
            return onCancel()
        }))
    }

    func removeHandler() { channel.setStreamHandler(nil) }
}

class OnPaymentStatusChangeControllerApi {
    private let channel: FlutterEventChannel

    init(
        binaryMessenger: FlutterBinaryMessenger
    ) {
        channel = FlutterEventChannel(name: "StripeTerminal#_onPaymentStatusChange", binaryMessenger: binaryMessenger)
    }

    func setHandler(
        _ onListen: @escaping (_ sink: ControllerSink<PaymentStatusApi>) -> FlutterError?,
        _ onCancel: @escaping () -> FlutterError?
    ) {
        channel.setStreamHandler(ControllerHandler({ arguments, events in
            let args = arguments as! [Any?]
            let sink = ControllerSink<PaymentStatusApi>(events) {$0.rawValue}
            return onListen(sink)
        }, { arguments in
            let args = arguments as! [Any?]
            return onCancel()
        }))
    }

    func removeHandler() { channel.setStreamHandler(nil) }
}

func setupStripeTerminalApi(
    _ binaryMessenger: FlutterBinaryMessenger,
    _ hostApi: StripeTerminalApi
) {
    let channel = FlutterMethodChannel(name: "StripeTerminal", binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { call, result in
        do {
            let args = call.arguments as! [Any?]
                        
            switch call.method {
            case "listLocations":
                let res = Result<[LocationApi]>(result) { $0.map { $0.serialize() } }
                try hostApi.onListLocations(res, args[0] as? String, args[1] as? Int, args[2] as? String)
            case "connectionStatus":
                let res = Result<ConnectionStatusApi>(result) { $0.rawValue }
                try hostApi.onConnectionStatus(res)
            case "connectBluetoothReader":
                let res = Result<StripeReaderApi>(result) { $0.serialize() }
                try hostApi.onConnectBluetoothReader(res, args[0] as! String, args[1] as! String, args[2] as! Bool)
            case "connectInternetReader":
                let res = Result<StripeReaderApi>(result) { $0.serialize() }
                try hostApi.onConnectInternetReader(res, args[0] as! String, args[1] as! Bool)
            case "connectMobileReader":
                let res = Result<StripeReaderApi>(result) { $0.serialize() }
                try hostApi.onConnectMobileReader(res, args[0] as! String, args[1] as! String)
            case "connectedReader":
                let res = Result<StripeReaderApi?>(result) { $0?.serialize() }
                try hostApi.onConnectedReader(res)
            case "disconnectReader":
                let res = Result<Void>(result) { () }
                try hostApi.onDisconnectReader(res)
            case "setReaderDisplay":
                let res = Result<Void>(result) { () }
                try hostApi.onSetReaderDisplay(res, CartApi.deserialize(args[0] as! [Any?]))
            case "clearReaderDisplay":
                let res = Result<Void>(result) { () }
                try hostApi.onClearReaderDisplay(res)
            case "readReusableCard":
                let res = Result<StripePaymentMethodApi>(result) { $0.serialize() }
                try hostApi.onReadReusableCard(res, args[0] as? String, args[1] != nil ? Dictionary(uniqueKeysWithValues: (args[1] as! [AnyHashable: Any]).map { k, v in (k as! String, v as! String) }) : nil)
            case "retrievePaymentIntent":
                let res = Result<StripePaymentIntentApi>(result) { $0.serialize() }
                try hostApi.onRetrievePaymentIntent(res, args[0] as! String)
            case "collectPaymentMethod":
                let res = Result<StripePaymentIntentApi>(result) { $0.serialize() }
                try hostApi.onCollectPaymentMethod(res, args[0] as! String, args[1] as! Bool, args[2] as! Bool)
            case "processPayment":
                let res = Result<StripePaymentIntentApi>(result) { $0.serialize() }
                try hostApi.onProcessPayment(res, args[0] as! String)
            case "_init":
                let res = Result<Void>(result) { () }
                try hostApi.onInit(res)
            default:
                result(FlutterMethodNotImplemented)
            }
        } catch let error as PlatformError {
            result(FlutterError(code: error.code, message: error.message, details: error.details))
        } catch {
            result(FlutterError(code: "", message: error.localizedDescription, details: nil))
        }
    }
}
class StripeTerminalHandlersApi {
    let channel: FlutterMethodChannel

    init(
        _ binaryMessenger: FlutterBinaryMessenger
    ) {
        channel = FlutterMethodChannel(
            name: "_StripeTerminalHandlers",
            binaryMessenger: binaryMessenger
        )
    }

    func requestConnectionToken() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            channel.invokeMethod("_onRequestConnectionToken", arguments: nil) { result in
                if let result = result as? [AnyHashable?: Any?] {
                    continuation.resume(throwing: PlatformError(
                        code: result["code"] as! String,
                        message: result["message"] as? String,
                        details: result["details"] as? String
                    ))
                } else {
                    continuation.resume(returning: result as! String)
                }
            }
        }
    }
}

struct LocationApi {
    let address: AddressApi?
    let displayName: String?
    let id: String?
    let livemode: Bool?
    let metadata: [String: String]?

    func serialize() -> [Any?] {
        return [
            address?.serialize(),
            displayName,
            id,
            livemode,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata!.map { k, v in (k, v) }) : nil,
        ]
    }
}

struct AddressApi {
    let city: String?
    let country: String?
    let line1: String?
    let line2: String?
    let postalCode: String?
    let state: String?

    func serialize() -> [Any?] {
        return [
            city,
            country,
            line1,
            line2,
            postalCode,
            state,
        ]
    }
}

enum ConnectionStatusApi: Int {
    case notConnected
    case connected
    case connecting
}

enum DiscoveryMethodApi: Int {
    case bluetoothScan
    case internet
    case localMobile
    case handOff
    case embedded
    case usb
}

struct StripeReaderApi {
    let locationStatus: LocationStatusApi
    let batteryLevel: Double
    let deviceType: DeviceTypeApi
    let simulated: Bool
    let availableUpdate: Bool
    let locationId: String?
    let serialNumber: String
    let label: String?

    func serialize() -> [Any?] {
        return [
            locationStatus.rawValue,
            batteryLevel,
            deviceType.rawValue,
            simulated,
            availableUpdate,
            locationId,
            serialNumber,
            label,
        ]
    }
}

enum LocationStatusApi: Int {
    case unknown
    case set
    case notSet
}

enum DeviceTypeApi: Int {
    case chipper1X
    case chipper2X
    case stripeM2
    case cotsDevice
    case verifoneP400
    case wiseCube
    case wisepad3
    case wisepad3s
    case wiseposE
    case wiseposEDevkit
    case etna
    case stripeS700
    case stripeS700Devkit
    case unknown
}

struct CartApi {
    let currency: String
    let tax: Int
    let total: Int
    let lineItems: [CartLineItemApi]

    static func deserialize(
        _ serialized: [Any?]
    ) -> CartApi {
        return CartApi(
            currency: serialized[0] as! String,
            tax: serialized[1] as! Int,
            total: serialized[2] as! Int,
            lineItems: (serialized[3] as! [Any?]).map { CartLineItemApi.deserialize($0 as! [Any?]) }
        )
    }
}

struct CartLineItemApi {
    let description: String
    let quantity: Int
    let amount: Int

    static func deserialize(
        _ serialized: [Any?]
    ) -> CartLineItemApi {
        return CartLineItemApi(
            description: serialized[0] as! String,
            quantity: serialized[1] as! Int,
            amount: serialized[2] as! Int
        )
    }
}

struct StripePaymentMethodApi {
    let id: String
    let cardDetails: CardDetailsApi?
    let customer: String?
    let livemode: Bool
    let metadata: [String: String]?

    func serialize() -> [Any?] {
        return [
            id,
            cardDetails?.serialize(),
            customer,
            livemode,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata!.map { k, v in (k, v) }) : nil,
        ]
    }
}

struct CardDetailsApi {
    let brand: String?
    let country: String?
    let expMonth: Int
    let expYear: Int
    let fingerprint: String?
    let funding: String?
    let last4: String?

    func serialize() -> [Any?] {
        return [
            brand,
            country,
            expMonth,
            expYear,
            fingerprint,
            funding,
            last4,
        ]
    }
}

struct StripePaymentIntentApi {
    let id: String
    let amount: Double
    let amountCapturable: Double
    let amountReceived: Double
    let application: String?
    let applicationFeeAmount: Double?
    let captureMethod: String?
    let cancellationReason: String?
    let canceledAt: Int?
    let clientSecret: String?
    let confirmationMethod: String?
    let created: Int
    let currency: String?
    let customer: String?
    let description: String?
    let invoice: String?
    let livemode: Bool
    let metadata: [String: String]?
    let onBehalfOf: String?
    let paymentMethodId: String?
    let status: PaymentIntentStatusApi?
    let review: String?
    let receiptEmail: String?
    let setupFutureUsage: String?
    let transferGroup: String?

    func serialize() -> [Any?] {
        return [
            id,
            amount,
            amountCapturable,
            amountReceived,
            application,
            applicationFeeAmount,
            captureMethod,
            cancellationReason,
            canceledAt,
            clientSecret,
            confirmationMethod,
            created,
            currency,
            customer,
            description,
            invoice,
            livemode,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata!.map { k, v in (k, v) }) : nil,
            onBehalfOf,
            paymentMethodId,
            status?.rawValue,
            review,
            receiptEmail,
            setupFutureUsage,
            transferGroup,
        ]
    }
}

enum PaymentIntentStatusApi: Int {
    case canceled
    case processing
    case requiresCapture
    case requiresConfirmation
    case requiresPaymentMethod
    case succeeded
}

enum PaymentStatusApi: Int {
    case notReady
    case ready
    case waitingForInput
    case processing
}

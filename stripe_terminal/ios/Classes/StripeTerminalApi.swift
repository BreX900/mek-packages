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
    ) {
        result(serializer(data))
    }

    func error(
        _ code: String,
        _ message: String,
        _ details: Any?
    ) {
        result(FlutterError(code: code, message: message, details: details))
    }
}

protocol StripeTerminalApi {
    func onConnectBluetoothReader(
        _ result: Result<StripeReaderApi>,
        _ readerSerialNumber: String,
        _ locationId: String
    )

    func onConnectInternetReader(
        _ result: Result<StripeReaderApi>,
        _ readerSerialNumber: String,
        _ failIfInUse: Bool
    )

    func onConnectMobileReader(
        _ result: Result<StripeReaderApi>,
        _ readerSerialNumber: String,
        _ locationId: String
    )

    func onDisconnectReader(
        _ result: Result<Unit>
    )

    func onSetReaderDisplay(
        _ result: Result<Unit>,
        _ cart: CartApi
    )

    func onClearReaderDisplay(
        _ result: Result<Unit>
    )

    func onConnectionStatus(
        _ result: Result<ConnectionStatusApi>
    )

    func onConnectedReader(
        _ result: Result<StripeReaderApi?>
    )

    func onReadReusableCardDetail(
        _ result: Result<StripePaymentMethodApi>
    )

    func onRetrievePaymentIntent(
        _ result: Result<StripePaymentIntentApi>,
        _ clientSecret: String
    )

    func onCollectPaymentMethod(
        _ result: Result<StripePaymentIntentApi>,
        _ clientSecret: String,
        _ collectConfiguration: CollectConfigurationApi
    )

    func onProcessPayment(
        _ result: Result<StripePaymentIntentApi>,
        _ clientSecret: String
    )

    func onListLocations(
        _ result: Result<[LocationApi]>
    )

    func onInit(
        _ result: Result<Unit>
    )
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
            case "connectBluetoothReader":
              let res = Result<StripeReaderApi>(result) { $0.serialize() }
              hostApi.onConnectBluetoothReader(res, args[0] as! String, args[1] as! String)
            case "connectInternetReader":
              let res = Result<StripeReaderApi>(result) { $0.serialize() }
              hostApi.onConnectInternetReader(res, args[0] as! String, args[1] as! Bool)
            case "connectMobileReader":
              let res = Result<StripeReaderApi>(result) { $0.serialize() }
              hostApi.onConnectMobileReader(res, args[0] as! String, args[1] as! String)
            case "disconnectReader":
              let res = Result<Unit>(result) { $0.serialize() }
              hostApi.onDisconnectReader(res)
            case "setReaderDisplay":
              let res = Result<Unit>(result) { $0.serialize() }
              hostApi.onSetReaderDisplay(res, CartApi.deserialize(args[0] as! [Any?]))
            case "clearReaderDisplay":
              let res = Result<Unit>(result) { $0.serialize() }
              hostApi.onClearReaderDisplay(res)
            case "connectionStatus":
              let res = Result<ConnectionStatusApi>(result) { $0.serialize() }
              hostApi.onConnectionStatus(res)
            case "connectedReader":
              let res = Result<StripeReaderApi?>(result) { $0.serialize() }
              hostApi.onConnectedReader(res)
            case "readReusableCardDetail":
              let res = Result<StripePaymentMethodApi>(result) { $0.serialize() }
              hostApi.onReadReusableCardDetail(res)
            case "retrievePaymentIntent":
              let res = Result<StripePaymentIntentApi>(result) { $0.serialize() }
              hostApi.onRetrievePaymentIntent(res, args[0] as! String)
            case "collectPaymentMethod":
              let res = Result<StripePaymentIntentApi>(result) { $0.serialize() }
              hostApi.onCollectPaymentMethod(res, args[0] as! String, CollectConfigurationApi.deserialize(args[1] as! [Any?]))
            case "processPayment":
              let res = Result<StripePaymentIntentApi>(result) { $0.serialize() }
              hostApi.onProcessPayment(res, args[0] as! String)
            case "listLocations":
              let res = Result<[LocationApi]>(result) { $0.serialize() }
              hostApi.onListLocations(res)
            case "_init":
              let res = Result<Unit>(result) { $0.serialize() }
              hostApi.onInit(res)
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

enum ConnectionStatusApi: Int {
    case notConnected
    case connected
    case connecting
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

struct DiscoverConfigApi {
    let discoveryMethod: DiscoveryMethodApi
    let simulated: Bool
    let locationId: String?

    static func deserialize(
        _ serialized: [Any?]
    ) -> DiscoverConfigApi {
        return DiscoverConfigApi(
            discoveryMethod: DiscoveryMethodApi(rawValue: serialized[0] as! Int)!,
            simulated: serialized[1] as! Bool,
            locationId: serialized[2] as? String
        )
    }
}

enum DiscoveryMethodApi: Int {
    case bluetoothScan
    case internet
    case localMobile
    case handOff
    case embedded
    case usb
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

struct CollectConfigurationApi {
    let skipTipping: Bool

    static func deserialize(
        _ serialized: [Any?]
    ) -> CollectConfigurationApi {
        return CollectConfigurationApi(
            skipTipping: serialized[0] as! Bool
        )
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

enum PaymentStatusApi: Int {
    case notReady
    case ready
    case waitingForInput
    case processing
}

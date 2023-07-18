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

    func onFetchConnectedReader(
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

    func onStartDiscoverReaders(
        _ result: Result<Unit>,
        _ config: DiscoverConfigApi
    )

    func onStopDiscoverReaders(
        _ result: Result<Unit>
    )
}

func setupStripeTerminalApi(
    _ binaryMessenger: FlutterBinaryMessenger,
    _ hostApi: StripeTerminalApi
) {
    let channel = FlutterMethodChannel(name: "stripe_terminal", binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { call, result in
        do {
            let args = call.arguments as! [Any?]
                        
            switch call.method {
                    case "connectBluetoothReader":
              let res = Result<StripeReaderApi>(result: result) { $0.serialize() }
              hostApi.onConnectBluetoothReader(res, args[0] as! String, args[1] as! String)
            case "connectInternetReader":
              let res = Result<StripeReaderApi>(result: result) { $0.serialize() }
              hostApi.onConnectInternetReader(res, args[0] as! String, args[1] as! Bool)
            case "connectMobileReader":
              let res = Result<StripeReaderApi>(result: result) { $0.serialize() }
              hostApi.onConnectMobileReader(res, args[0] as! String, args[1] as! String)
            case "disconnectReader":
              let res = Result<Unit>(result: result) { $0.serialize() }
              hostApi.onDisconnectReader(res)
            case "setReaderDisplay":
              let res = Result<Unit>(result: result) { $0.serialize() }
              hostApi.onSetReaderDisplay(res, CartApi.deserialize(args[0] as! [Any?]))
            case "clearReaderDisplay":
              let res = Result<Unit>(result: result) { $0.serialize() }
              hostApi.onClearReaderDisplay(res)
            case "connectionStatus":
              let res = Result<ConnectionStatusApi>(result: result) { $0.serialize() }
              hostApi.onConnectionStatus(res)
            case "fetchConnectedReader":
              let res = Result<StripeReaderApi?>(result: result) { $0.serialize() }
              hostApi.onFetchConnectedReader(res)
            case "readReusableCardDetail":
              let res = Result<StripePaymentMethodApi>(result: result) { $0.serialize() }
              hostApi.onReadReusableCardDetail(res)
            case "retrievePaymentIntent":
              let res = Result<StripePaymentIntentApi>(result: result) { $0.serialize() }
              hostApi.onRetrievePaymentIntent(res, args[0] as! String)
            case "collectPaymentMethod":
              let res = Result<StripePaymentIntentApi>(result: result) { $0.serialize() }
              hostApi.onCollectPaymentMethod(res, args[0] as! String, CollectConfigurationApi.deserialize(args[1] as! [Any?]))
            case "processPayment":
              let res = Result<StripePaymentIntentApi>(result: result) { $0.serialize() }
              hostApi.onProcessPayment(res, args[0] as! String)
            case "listLocations":
              let res = Result<[LocationApi]>(result: result) { $0.serialize() }
              hostApi.onListLocations(res)
            case "_init":
              let res = Result<Unit>(result: result) { $0.serialize() }
              hostApi.onInit(res)
            case "_startDiscoverReaders":
              let res = Result<Unit>(result: result) { $0.serialize() }
              hostApi.onStartDiscoverReaders(res, DiscoverConfigApi.deserialize(args[0] as! [Any?]))
            case "_stopDiscoverReaders":
              let res = Result<Unit>(result: result) { $0.serialize() }
              hostApi.onStopDiscoverReaders(res)
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

    static func deserialize(
        _ serialized: [Any?]
    ) -> StripeReaderApi {
        return StripeReaderApi(
            locationStatus: LocationStatusApi(rawValue: serialized[0] as! Int)!,
            batteryLevel: serialized[1] as! Double,
            deviceType: DeviceTypeApi(rawValue: serialized[2] as! Int)!,
            simulated: serialized[3] as! Bool,
            availableUpdate: serialized[4] as! Bool,
            locationId: serialized[5] as? String,
            serialNumber: serialized[6] as! String,
            label: serialized[7] as? String
        )
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

    func serialize() -> [Any?] {
        return [
            currency,
            tax,
            total,
            lineItems.map { $0.serialize() },
        ]
    }

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

    func serialize() -> [Any?] {
        return [
            description,
            quantity,
            amount,
        ]
    }

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

    static func deserialize(
        _ serialized: [Any?]
    ) -> StripePaymentMethodApi {
        return StripePaymentMethodApi(
            id: serialized[0] as! String,
            cardDetails: serialized[1] != nil ? CardDetailsApi.deserialize(serialized[1] as! [Any?]) : nil,
            customer: serialized[2] as? String,
            livemode: serialized[3] as! Bool,
            metadata: serialized[4] != nil ? Dictionary(uniqueKeysWithValues: (serialized[4] as! [AnyHashable: Any]).map { k, v in (k as! String, v as! String) }) : nil
        )
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

    static func deserialize(
        _ serialized: [Any?]
    ) -> CardDetailsApi {
        return CardDetailsApi(
            brand: serialized[0] as? String,
            country: serialized[1] as? String,
            expMonth: serialized[2] as! Int,
            expYear: serialized[3] as! Int,
            fingerprint: serialized[4] as? String,
            funding: serialized[5] as? String,
            last4: serialized[6] as? String
        )
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

    static func deserialize(
        _ serialized: [Any?]
    ) -> StripePaymentIntentApi {
        return StripePaymentIntentApi(
            id: serialized[0] as! String,
            amount: serialized[1] as! Double,
            amountCapturable: serialized[2] as! Double,
            amountReceived: serialized[3] as! Double,
            application: serialized[4] as? String,
            applicationFeeAmount: serialized[5] as? Double,
            captureMethod: serialized[6] as? String,
            cancellationReason: serialized[7] as? String,
            canceledAt: serialized[8] as? Int,
            clientSecret: serialized[9] as? String,
            confirmationMethod: serialized[10] as? String,
            created: serialized[11] as! Int,
            currency: serialized[12] as? String,
            customer: serialized[13] as? String,
            description: serialized[14] as? String,
            invoice: serialized[15] as? String,
            livemode: serialized[16] as! Bool,
            metadata: serialized[17] != nil ? Dictionary(uniqueKeysWithValues: (serialized[17] as! [AnyHashable: Any]).map { k, v in (k as! String, v as! String) }) : nil,
            onBehalfOf: serialized[18] as? String,
            paymentMethodId: serialized[19] as? String,
            status: serialized[20] != nil ? PaymentIntentStatusApi(rawValue: serialized[20] as! Int)! : nil,
            review: serialized[21] as? String,
            receiptEmail: serialized[22] as? String,
            setupFutureUsage: serialized[23] as? String,
            transferGroup: serialized[24] as? String
        )
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

    func serialize() -> [Any?] {
        return [
            skipTipping,
        ]
    }

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

    static func deserialize(
        _ serialized: [Any?]
    ) -> LocationApi {
        return LocationApi(
            address: serialized[0] != nil ? AddressApi.deserialize(serialized[0] as! [Any?]) : nil,
            displayName: serialized[1] as? String,
            id: serialized[2] as? String,
            livemode: serialized[3] as? Bool,
            metadata: serialized[4] != nil ? Dictionary(uniqueKeysWithValues: (serialized[4] as! [AnyHashable: Any]).map { k, v in (k as! String, v as! String) }) : nil
        )
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

    static func deserialize(
        _ serialized: [Any?]
    ) -> AddressApi {
        return AddressApi(
            city: serialized[0] as? String,
            country: serialized[1] as? String,
            line1: serialized[2] as? String,
            line2: serialized[3] as? String,
            postalCode: serialized[4] as? String,
            state: serialized[5] as? String
        )
    }
}

struct DiscoverConfigApi {
    let discoveryMethod: DiscoveryMethodApi
    let simulated: Bool
    let locationId: String?

    func serialize() -> [Any?] {
        return [
            discoveryMethod.rawValue,
            simulated,
            locationId,
        ]
    }

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

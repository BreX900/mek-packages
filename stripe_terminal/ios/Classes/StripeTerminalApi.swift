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
        _ endingBefore: String?,
        _ limit: Int?,
        _ startingAfter: String?
    ) async throws -> [LocationApi]

    func onConnectionStatus() async throws -> ConnectionStatusApi

    func onConnectBluetoothReader(
        _ serialNumber: String,
        _ locationId: String,
        _ autoReconnectOnUnexpectedDisconnect: Bool
    ) async throws -> StripeReaderApi

    func onConnectInternetReader(
        _ serialNumber: String,
        _ failIfInUse: Bool
    ) async throws -> StripeReaderApi

    func onConnectMobileReader(
        _ serialNumber: String,
        _ locationId: String
    ) async throws -> StripeReaderApi

    func onConnectedReader() async throws -> StripeReaderApi?

    func onDisconnectReader() async throws -> Void

    func onInstallAvailableUpdate(
        _ serialNumber: String
    ) async throws -> Void

    func onSetReaderDisplay(
        _ cart: CartApi
    ) async throws -> Void

    func onClearReaderDisplay() async throws -> Void

    func onRetrievePaymentIntent(
        _ clientSecret: String
    ) async throws -> StripePaymentIntentApi

    func onProcessPayment(
        _ clientSecret: String
    ) async throws -> StripePaymentIntentApi

    func onInit() async throws -> Void

    func onStartReadReusableCard(
        _ result: Result<StripePaymentMethodApi>,
        _ id: Int,
        _ customer: String?,
        _ metadata: [String: String]?
    ) throws

    func onStopReadReusableCard(
        _ id: Int
    ) async throws -> Void

    func onStartCollectPaymentMethod(
        _ result: Result<StripePaymentIntentApi>,
        _ id: Int,
        _ clientSecret: String,
        _ moto: Bool,
        _ skipTipping: Bool
    ) throws

    func onStopCollectPaymentMethod(
        _ id: Int
    ) async throws -> Void
}

class DiscoverReadersControllerApi {
    private let channel: FlutterEventChannel

    init(
        binaryMessenger: FlutterBinaryMessenger
    ) {
        channel = FlutterEventChannel(name: "StripeTerminal#_discoverReaders", binaryMessenger: binaryMessenger)
    }

    func setHandler(
        _ onListen: @escaping (_ sink: ControllerSink<[StripeReaderApi]>, _ discoveryMethod: DiscoveryMethodApi, _ simulated: Bool, _ locationId: String?) -> FlutterError?,
        _ onCancel: @escaping (_ discoveryMethod: DiscoveryMethodApi, _ simulated: Bool, _ locationId: String?) -> FlutterError?
    ) {
        channel.setStreamHandler(ControllerHandler({ arguments, events in
            let args = arguments as! [Any?]
            let sink = ControllerSink<[StripeReaderApi]>(events) { $0.map { $0.serialize() } }
            return onListen(sink, DiscoveryMethodApi(rawValue: args[0] as! Int)!, args[1] as! Bool, args[2] as! String?)
        }, { arguments in
            let args = arguments as! [Any?]
            return onCancel(DiscoveryMethodApi(rawValue: args[0] as! Int)!, args[1] as! Bool, args[2] as! String?)
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
        let runAsync = { (function: @escaping () async throws -> Any?) -> Void in
            Task {
                do {
                    let res = try await function()
                    DispatchQueue.main.async { result(res) }
                } catch let error as PlatformError {
                    DispatchQueue.main.async { result(FlutterError(code: error.code, message: error.message, details: error.details)) }
                } catch {
                    DispatchQueue.main.async { result(FlutterError(code: "", message: error.localizedDescription, details: nil)) }
                }
            }
        }
    
        do {
            let args = call.arguments as! [Any?]
                        
            switch call.method {
            case "listLocations":
                runAsync {
                    let res = try await hostApi.onListLocations(args[0] as! String?, args[1] as! Int?, args[2] as! String?)
                    return res.map { $0.serialize() }
                }
            case "connectionStatus":
                runAsync {
                    let res = try await hostApi.onConnectionStatus()
                    return res.rawValue
                }
            case "connectBluetoothReader":
                runAsync {
                    let res = try await hostApi.onConnectBluetoothReader(args[0] as! String, args[1] as! String, args[2] as! Bool)
                    return res.serialize()
                }
            case "connectInternetReader":
                runAsync {
                    let res = try await hostApi.onConnectInternetReader(args[0] as! String, args[1] as! Bool)
                    return res.serialize()
                }
            case "connectMobileReader":
                runAsync {
                    let res = try await hostApi.onConnectMobileReader(args[0] as! String, args[1] as! String)
                    return res.serialize()
                }
            case "connectedReader":
                runAsync {
                    let res = try await hostApi.onConnectedReader()
                    return res?.serialize()
                }
            case "disconnectReader":
                runAsync {
                    try await hostApi.onDisconnectReader()
                    return nil
                }
            case "installAvailableUpdate":
                runAsync {
                    try await hostApi.onInstallAvailableUpdate(args[0] as! String)
                    return nil
                }
            case "setReaderDisplay":
                runAsync {
                    try await hostApi.onSetReaderDisplay(CartApi.deserialize(args[0] as! [Any?]))
                    return nil
                }
            case "clearReaderDisplay":
                runAsync {
                    try await hostApi.onClearReaderDisplay()
                    return nil
                }
            case "retrievePaymentIntent":
                runAsync {
                    let res = try await hostApi.onRetrievePaymentIntent(args[0] as! String)
                    return res.serialize()
                }
            case "processPayment":
                runAsync {
                    let res = try await hostApi.onProcessPayment(args[0] as! String)
                    return res.serialize()
                }
            case "_init":
                runAsync {
                    try await hostApi.onInit()
                    return nil
                }
            case "_startReadReusableCard":
                let res = Result<StripePaymentMethodApi>(result) { $0.serialize() }
                try hostApi.onStartReadReusableCard(res, args[0] as! Int, args[1] as! String?, args[2] != nil ? Dictionary(uniqueKeysWithValues: (args[2] as! [AnyHashable: Any]).map { k, v in (k as! String, v as! String) }) : nil)
            case "_stopReadReusableCard":
                runAsync {
                    try await hostApi.onStopReadReusableCard(args[0] as! Int)
                    return nil
                }
            case "_startCollectPaymentMethod":
                let res = Result<StripePaymentIntentApi>(result) { $0.serialize() }
                try hostApi.onStartCollectPaymentMethod(res, args[0] as! Int, args[1] as! String, args[2] as! Bool, args[3] as! Bool)
            case "_stopCollectPaymentMethod":
                runAsync {
                    try await hostApi.onStopCollectPaymentMethod(args[0] as! Int)
                    return nil
                }
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
            name: "StripeTerminalHandlers",
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

    func unexpectedReaderDisconnect(
        reader: StripeReaderApi
    ) {
        channel.invokeMethod("_onUnexpectedReaderDisconnect", arguments: [reader.serialize()])
    }

    func connectionStatusChange(
        connectionStatus: ConnectionStatusApi
    ) {
        channel.invokeMethod("_onConnectionStatusChange", arguments: [connectionStatus.rawValue])
    }

    func paymentStatusChange(
        paymentStatus: PaymentStatusApi
    ) {
        channel.invokeMethod("_onPaymentStatusChange", arguments: [paymentStatus.rawValue])
    }

    func availableUpdate(
        availableUpdate: Bool
    ) {
        channel.invokeMethod("_onAvailableUpdate", arguments: [availableUpdate])
    }

    func reportReaderSoftwareUpdateProgress(
        progress: Double
    ) {
        channel.invokeMethod("_onReportReaderSoftwareUpdateProgress", arguments: [progress])
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

struct StripePaymentIntentApi {
    let id: String
    let amount: Double
    let amountCapturable: Double
    let amountReceived: Double
    let application: String?
    let applicationFeeAmount: Double?
    let captureMethod: String?
    let cancellationReason: String?
    let canceledAt: Date?
    let clientSecret: String?
    let confirmationMethod: String?
    let created: Date
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
            canceledAt != nil ? canceledAt!.timeIntervalSince1970 * 1000 : nil,
            clientSecret,
            confirmationMethod,
            created.timeIntervalSince1970 * 1000,
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

enum StripeTerminalExceptionCodeApi: String {
    case cancelFailed
    case notConnectedToReader
    case alreadyConnectedToReader
    case bluetoothPermissionDenied
    case processInvalidPaymentIntent
    case invalidClientSecret
    case unsupportedOperation
    case unexpectedOperation
    case unsupportedSdk
    case usbPermissionDenied
    case missingRequiredParameter
    case invalidRequiredParameter
    case invalidTipParameter
    case localMobileLibraryNotIncluded
    case localMobileUnsupportedDevice
    case localMobileUnsupportedAndroidVersion
    case localMobileDeviceTampered
    case localMobileDebugNotSupported
    case offlineModeUnsupportedAndroidVersion
    case canceled
    case locationServicesDisabled
    case bluetoothScanTimedOut
    case bluetoothLowEnergyUnsupported
    case readerSoftwareUpdateFailedBatteryLow
    case readerSoftwareUpdateFailedInterrupted
    case cardInsertNotRead
    case cardSwipeNotRead
    case cardReadTimedOut
    case cardRemoved
    case customerConsentRequired
    case cardLeftInReader
    case usbDiscoveryTimedOut
    case featureNotEnabledOnAccount
    case readerBusy
    case readerCommunicationError
    case bluetoothError
    case bluetoothDisconnected
    case bluetoothReconnectStarted
    case usbDisconnected
    case usbReconnectStarted
    case readerConnectedToAnotherDevice
    case readerSoftwareUpdateFailed
    case readerSoftwareUpdateFailedReaderError
    case readerSoftwareUpdateFailedServerError
    case localMobileNfcDisabled
    case unsupportedReaderVersion
    case unexpectedSdkError
    case declinedByStripeApi
    case declinedByReader
    case requestTimedOut
    case stripeApiConnectionError
    case stripeApiError
    case stripeApiResponseDecodingError
    case connectionTokenProviderError
    case sessionExpired
    case androidApiLevelError
    case amountExceedsMaxOfflineAmount
    case offlinePaymentsDatabaseTooLarge
    case readerConnectionNotAvailableOffline
    case readerConnectionOfflineLocationMismatch
    case noLastSeenAccount
    case invalidOfflineCurrency
    case cardSwipeNotAvailable
    case interacNotSupportedOffline
    case onlinePinNotSupportedOffline
    case offlineAndCardExpired
    case offlineTransactionDeclined
    case offlineCollectAndProcessMismatch
    case offlineTestmodePaymentInLivemode
    case offlineLivemodePaymentInTestmode
    case offlinePaymentIntentNotFound
    case missingEmvData
    case connectionTokenProviderErrorWhileForwarding
    case accountIdMismatchWhileForwarding
    case forceOfflineWithFeatureDisabled
    case notConnectedToInternetAndRequireOnlineSet
}

enum ConnectionStatusApi: Int {
    case notConnected
    case connected
    case connecting
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

enum PaymentIntentStatusApi: Int {
    case canceled
    case processing
    case requiresCapture
    case requiresConfirmation
    case requiresPaymentMethod
    case succeeded
}

enum DiscoveryMethodApi: Int {
    case bluetoothScan
    case internet
    case localMobile
    case handOff
    case embedded
    case usb
}

enum PaymentStatusApi: Int {
    case notReady
    case ready
    case waitingForInput
    case processing
}
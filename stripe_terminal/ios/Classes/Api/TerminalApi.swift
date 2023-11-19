// GENERATED CODE - DO NOT MODIFY BY HAND

import Flutter

class PlatformError: Error {
    let code: String
    let message: String?
    let details: Any?

    init(
        _ code: String,
        _ message: String? = nil,
        _ details: Any? = nil
    ) {
        self.code = code
        self.message = message
        self.details = details
    }

    func toFlutterError() -> FlutterError { FlutterError(code: code, message: message, details: details) }
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
        _ error: PlatformError
    ) {
        result(error.toFlutterError())
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
        _ error: PlatformError
    ) {
        sink(error.toFlutterError())
    }

    func endOfStream() { sink(FlutterEndOfEventStream) }
}

class ControllerHandler: NSObject, FlutterStreamHandler {
    private let _onListen: (_ arguments: Any?, _ events: @escaping FlutterEventSink) -> PlatformError?
    private let _onCancel: (_ arguments: Any?) -> PlatformError?

    init(
        _ _onListen: @escaping (_ arguments: Any?, _ events: @escaping FlutterEventSink) -> PlatformError?,
        _ _onCancel: @escaping (_ arguments: Any?) -> PlatformError?
    ) {
        self._onListen = _onListen
        self._onCancel = _onCancel
    }

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? { _onListen(arguments, events)?.toFlutterError() }

    func onCancel(
        withArguments arguments: Any?
    ) -> FlutterError? { _onCancel(arguments)?.toFlutterError() }
}

protocol TerminalPlatformApi {
    func onInit(
        _ shouldPrintLogs: Bool
    ) async throws -> Void

    func onClearCachedCredentials() throws -> Void

    func onGetConnectionStatus() throws -> ConnectionStatusApi

    func onSupportsReadersOfType(
        _ deviceType: DeviceTypeApi?,
        _ discoveryConfiguration: DiscoveryConfigurationApi
    ) throws -> Bool

    func onConnectBluetoothReader(
        _ serialNumber: String,
        _ locationId: String,
        _ autoReconnectOnUnexpectedDisconnect: Bool
    ) async throws -> ReaderApi

    func onConnectHandoffReader(
        _ serialNumber: String
    ) async throws -> ReaderApi

    func onConnectInternetReader(
        _ serialNumber: String,
        _ failIfInUse: Bool
    ) async throws -> ReaderApi

    func onConnectMobileReader(
        _ serialNumber: String,
        _ locationId: String
    ) async throws -> ReaderApi

    func onConnectUsbReader(
        _ serialNumber: String,
        _ locationId: String,
        _ autoReconnectOnUnexpectedDisconnect: Bool
    ) async throws -> ReaderApi

    func onGetConnectedReader() throws -> ReaderApi?

    func onCancelReaderReconnection() async throws -> Void

    func onListLocations(
        _ endingBefore: String?,
        _ limit: Int?,
        _ startingAfter: String?
    ) async throws -> [LocationApi]

    func onInstallAvailableUpdate() throws -> Void

    func onCancelReaderUpdate() async throws -> Void

    func onDisconnectReader() async throws -> Void

    func onGetPaymentStatus() throws -> PaymentStatusApi

    func onCreatePaymentIntent(
        _ parameters: PaymentIntentParametersApi
    ) async throws -> PaymentIntentApi

    func onRetrievePaymentIntent(
        _ clientSecret: String
    ) async throws -> PaymentIntentApi

    func onStartCollectPaymentMethod(
        _ result: Result<PaymentIntentApi>,
        _ operationId: Int,
        _ paymentIntentId: String,
        _ skipTipping: Bool,
        _ tippingConfiguration: TippingConfigurationApi?,
        _ shouldUpdatePaymentIntent: Bool,
        _ customerCancellationEnabled: Bool
    ) throws

    func onStopCollectPaymentMethod(
        _ operationId: Int
    ) async throws -> Void

    func onConfirmPaymentIntent(
        _ paymentIntentId: String
    ) async throws -> PaymentIntentApi

    func onCancelPaymentIntent(
        _ paymentIntentId: String
    ) async throws -> PaymentIntentApi

    func onCreateSetupIntent(
        _ customerId: String?,
        _ metadata: [String: String]?,
        _ onBehalfOf: String?,
        _ description: String?,
        _ usage: SetupIntentUsageApi?
    ) async throws -> SetupIntentApi

    func onRetrieveSetupIntent(
        _ clientSecret: String
    ) async throws -> SetupIntentApi

    func onStartCollectSetupIntentPaymentMethod(
        _ result: Result<SetupIntentApi>,
        _ operationId: Int,
        _ setupIntentId: String,
        _ customerConsentCollected: Bool,
        _ customerCancellationEnabled: Bool
    ) throws

    func onStopCollectSetupIntentPaymentMethod(
        _ operationId: Int
    ) async throws -> Void

    func onConfirmSetupIntent(
        _ setupIntentId: String
    ) async throws -> SetupIntentApi

    func onCancelSetupIntent(
        _ setupIntentId: String
    ) async throws -> SetupIntentApi

    func onStartCollectRefundPaymentMethod(
        _ result: Result<Void>,
        _ operationId: Int,
        _ chargeId: String,
        _ amount: Int,
        _ currency: String,
        _ metadata: [String: String]?,
        _ reverseTransfer: Bool?,
        _ refundApplicationFee: Bool?,
        _ customerCancellationEnabled: Bool
    ) throws

    func onStopCollectRefundPaymentMethod(
        _ operationId: Int
    ) async throws -> Void

    func onConfirmRefund() async throws -> RefundApi

    func onSetReaderDisplay(
        _ cart: CartApi
    ) async throws -> Void

    func onClearReaderDisplay() async throws -> Void
}

class DiscoverReadersControllerApi {
    private let channel: FlutterEventChannel

    init(
        binaryMessenger: FlutterBinaryMessenger
    ) {
        channel = FlutterEventChannel(name: "mek_stripe_terminal#TerminalPlatform#discoverReaders", binaryMessenger: binaryMessenger)
    }

    func setHandler(
        _ onListen: @escaping (_ sink: ControllerSink<[ReaderApi]>, _ configuration: DiscoveryConfigurationApi) -> PlatformError?,
        _ onCancel: @escaping (_ configuration: DiscoveryConfigurationApi) -> PlatformError?
    ) {
        channel.setStreamHandler(ControllerHandler({ arguments, events in
            let args = arguments as! [Any?]
            let sink = ControllerSink<[ReaderApi]>(events) { $0.map { $0.serialize() } }
            return onListen(sink, deserializeDiscoveryConfigurationApi(args[0] as! [Any?]))
        }, { arguments in
            let args = arguments as! [Any?]
            return onCancel(deserializeDiscoveryConfigurationApi(args[0] as! [Any?]))
        }))
    }

    func removeHandler() { channel.setStreamHandler(nil) }
}

private var channelTerminalPlatformApi: FlutterMethodChannel? = nil

func setTerminalPlatformApiHandler(
    _ binaryMessenger: FlutterBinaryMessenger,
    _ hostApi: TerminalPlatformApi
) {
    channelTerminalPlatformApi = FlutterMethodChannel(name: "mek_stripe_terminal#TerminalPlatform", binaryMessenger: binaryMessenger)
    channelTerminalPlatformApi!.setMethodCallHandler { call, result in
        let runAsync = { (function: @escaping () async throws -> Any?) -> Void in
            Task {
                do {
                    let res = try await function()
                    DispatchQueue.main.async { result(res) }
                } catch let error as PlatformError {
                    DispatchQueue.main.async { result(error.toFlutterError()) }
                } catch {
                    DispatchQueue.main.async { result(FlutterError(code: "", message: error.localizedDescription, details: nil)) }
                }
            }
        }
    
        do {
            let args = call.arguments as! [Any?]
                        
            switch call.method {
            case "init":
                runAsync {
                    try await hostApi.onInit(args[0] as! Bool)
                    return nil
                }
            case "clearCachedCredentials":
                let res = try hostApi.onClearCachedCredentials()
                result(nil)
            case "getConnectionStatus":
                let res = try hostApi.onGetConnectionStatus()
                result(res.rawValue)
            case "supportsReadersOfType":
                let res = try hostApi.onSupportsReadersOfType(!(args[0] is NSNull) ? DeviceTypeApi(rawValue: args[0] as! Int)! : nil, deserializeDiscoveryConfigurationApi(args[1] as! [Any?]))
                result(res)
            case "connectBluetoothReader":
                runAsync {
                    let res = try await hostApi.onConnectBluetoothReader(args[0] as! String, args[1] as! String, args[2] as! Bool)
                    return res.serialize()
                }
            case "connectHandoffReader":
                runAsync {
                    let res = try await hostApi.onConnectHandoffReader(args[0] as! String)
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
            case "connectUsbReader":
                runAsync {
                    let res = try await hostApi.onConnectUsbReader(args[0] as! String, args[1] as! String, args[2] as! Bool)
                    return res.serialize()
                }
            case "getConnectedReader":
                let res = try hostApi.onGetConnectedReader()
                result(res?.serialize())
            case "cancelReaderReconnection":
                runAsync {
                    try await hostApi.onCancelReaderReconnection()
                    return nil
                }
            case "listLocations":
                runAsync {
                    let res = try await hostApi.onListLocations(args[0] as? String, args[1] as? Int, args[2] as? String)
                    return res.map { $0.serialize() }
                }
            case "installAvailableUpdate":
                let res = try hostApi.onInstallAvailableUpdate()
                result(nil)
            case "cancelReaderUpdate":
                runAsync {
                    try await hostApi.onCancelReaderUpdate()
                    return nil
                }
            case "disconnectReader":
                runAsync {
                    try await hostApi.onDisconnectReader()
                    return nil
                }
            case "getPaymentStatus":
                let res = try hostApi.onGetPaymentStatus()
                result(res.rawValue)
            case "createPaymentIntent":
                runAsync {
                    let res = try await hostApi.onCreatePaymentIntent(PaymentIntentParametersApi.deserialize(args[0] as! [Any?]))
                    return res.serialize()
                }
            case "retrievePaymentIntent":
                runAsync {
                    let res = try await hostApi.onRetrievePaymentIntent(args[0] as! String)
                    return res.serialize()
                }
            case "startCollectPaymentMethod":
                let res = Result<PaymentIntentApi>(result) { $0.serialize() }
                try hostApi.onStartCollectPaymentMethod(res, args[0] as! Int, args[1] as! String, args[2] as! Bool, !(args[3] is NSNull) ? TippingConfigurationApi.deserialize(args[3] as! [Any?]) : nil, args[4] as! Bool, args[5] as! Bool)
            case "stopCollectPaymentMethod":
                runAsync {
                    try await hostApi.onStopCollectPaymentMethod(args[0] as! Int)
                    return nil
                }
            case "confirmPaymentIntent":
                runAsync {
                    let res = try await hostApi.onConfirmPaymentIntent(args[0] as! String)
                    return res.serialize()
                }
            case "cancelPaymentIntent":
                runAsync {
                    let res = try await hostApi.onCancelPaymentIntent(args[0] as! String)
                    return res.serialize()
                }
            case "createSetupIntent":
                runAsync {
                    let res = try await hostApi.onCreateSetupIntent(args[0] as? String, !(args[1] is NSNull) ? Dictionary(uniqueKeysWithValues: (args[1] as! [AnyHashable?: Any?]).map { k, v in (k as! String, v as! String) }) : nil, args[2] as? String, args[3] as? String, !(args[4] is NSNull) ? SetupIntentUsageApi(rawValue: args[4] as! Int)! : nil)
                    return res.serialize()
                }
            case "retrieveSetupIntent":
                runAsync {
                    let res = try await hostApi.onRetrieveSetupIntent(args[0] as! String)
                    return res.serialize()
                }
            case "startCollectSetupIntentPaymentMethod":
                let res = Result<SetupIntentApi>(result) { $0.serialize() }
                try hostApi.onStartCollectSetupIntentPaymentMethod(res, args[0] as! Int, args[1] as! String, args[2] as! Bool, args[3] as! Bool)
            case "stopCollectSetupIntentPaymentMethod":
                runAsync {
                    try await hostApi.onStopCollectSetupIntentPaymentMethod(args[0] as! Int)
                    return nil
                }
            case "confirmSetupIntent":
                runAsync {
                    let res = try await hostApi.onConfirmSetupIntent(args[0] as! String)
                    return res.serialize()
                }
            case "cancelSetupIntent":
                runAsync {
                    let res = try await hostApi.onCancelSetupIntent(args[0] as! String)
                    return res.serialize()
                }
            case "startCollectRefundPaymentMethod":
                let res = Result<Void>(result) { nil }
                try hostApi.onStartCollectRefundPaymentMethod(res, args[0] as! Int, args[1] as! String, args[2] as! Int, args[3] as! String, !(args[4] is NSNull) ? Dictionary(uniqueKeysWithValues: (args[4] as! [AnyHashable?: Any?]).map { k, v in (k as! String, v as! String) }) : nil, args[5] as? Bool, args[6] as? Bool, args[7] as! Bool)
            case "stopCollectRefundPaymentMethod":
                runAsync {
                    try await hostApi.onStopCollectRefundPaymentMethod(args[0] as! Int)
                    return nil
                }
            case "confirmRefund":
                runAsync {
                    let res = try await hostApi.onConfirmRefund()
                    return res.serialize()
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
            default:
                result(FlutterMethodNotImplemented)
            }
        } catch let error as PlatformError {
            result(error.toFlutterError())
        } catch {
            result(FlutterError(code: "", message: error.localizedDescription, details: nil))
        }
    }
}

func removeTerminalPlatformApiHandler() {
    channelTerminalPlatformApi?.setMethodCallHandler(nil)
}

class TerminalHandlersApi {
    let channel: FlutterMethodChannel

    init(
        _ binaryMessenger: FlutterBinaryMessenger
    ) {
        channel = FlutterMethodChannel(
            name: "mek_stripe_terminal#TerminalHandlers",
            binaryMessenger: binaryMessenger
        )
    }

    func requestConnectionToken() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.channel.invokeMethod("_onRequestConnectionToken", arguments: []) { result in
                    if let result = result as? FlutterError {
                        continuation.resume(throwing: PlatformError(result.code, result.message, result.details))
                    } else {
                        continuation.resume(returning: result as! String)
                    }
                }
            }
        }
    }

    func unexpectedReaderDisconnect(
        reader: ReaderApi
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

    func readerReportEvent(
        event: ReaderEventApi
    ) {
        channel.invokeMethod("_onReaderReportEvent", arguments: [event.rawValue])
    }

    func readerRequestDisplayMessage(
        message: ReaderDisplayMessageApi
    ) {
        channel.invokeMethod("_onReaderRequestDisplayMessage", arguments: [message.rawValue])
    }

    func readerRequestInput(
        options: [ReaderInputOptionApi]
    ) {
        channel.invokeMethod("_onReaderRequestInput", arguments: [options.map { $0.rawValue }])
    }

    func readerBatteryLevelUpdate(
        batteryLevel: Double,
        batteryStatus: BatteryStatusApi?,
        isCharging: Bool
    ) {
        channel.invokeMethod("_onReaderBatteryLevelUpdate", arguments: [batteryLevel, batteryStatus?.rawValue, isCharging])
    }

    func readerReportLowBatteryWarning() {
        channel.invokeMethod("_onReaderReportLowBatteryWarning", arguments: [])
    }

    func readerReportAvailableUpdate(
        update: ReaderSoftwareUpdateApi
    ) {
        channel.invokeMethod("_onReaderReportAvailableUpdate", arguments: [update.serialize()])
    }

    func readerStartInstallingUpdate(
        update: ReaderSoftwareUpdateApi
    ) {
        channel.invokeMethod("_onReaderStartInstallingUpdate", arguments: [update.serialize()])
    }

    func readerReportSoftwareUpdateProgress(
        progress: Double
    ) {
        channel.invokeMethod("_onReaderReportSoftwareUpdateProgress", arguments: [progress])
    }

    func readerFinishInstallingUpdate(
        update: ReaderSoftwareUpdateApi?,
        exception: TerminalExceptionApi?
    ) {
        channel.invokeMethod("_onReaderFinishInstallingUpdate", arguments: [update?.serialize(), exception?.serialize()])
    }

    func readerReconnectFailed(
        reader: ReaderApi
    ) {
        channel.invokeMethod("_onReaderReconnectFailed", arguments: [reader.serialize()])
    }

    func readerReconnectStarted(
        reader: ReaderApi
    ) {
        channel.invokeMethod("_onReaderReconnectStarted", arguments: [reader.serialize()])
    }

    func readerReconnectSucceeded(
        reader: ReaderApi
    ) {
        channel.invokeMethod("_onReaderReconnectSucceeded", arguments: [reader.serialize()])
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

struct AmountDetailsApi {
    let tip: TipApi?

    func serialize() -> [Any?] {
        return [
            tip?.serialize(),
        ]
    }
}

enum BatteryStatusApi: Int {
    case critical
    case low
    case nominal
}

enum CaptureMethodApi: Int {
    case automatic
    case manual
}

enum CardBrandApi: Int {
    case amex
    case dinersClub
    case discover
    case jcb
    case masterCard
    case unionPay
    case visa
    case interac
    case eftposAu
}

struct CardDetailsApi {
    let brand: CardBrandApi?
    let country: String?
    let expMonth: Int
    let expYear: Int
    let funding: CardFundingTypeApi?
    let last4: String?

    func serialize() -> [Any?] {
        return [
            brand?.rawValue,
            country,
            expMonth,
            expYear,
            funding?.rawValue,
            last4,
        ]
    }
}

enum CardFundingTypeApi: Int {
    case credit
    case debit
    case prepaid
}

struct CardNetworksApi {
    let available: [CardBrandApi]
    let preferred: String?

    func serialize() -> [Any?] {
        return [
            available.map { $0.rawValue },
            preferred,
        ]
    }
}

enum CardPresentCaptureMethodApi: Int {
    case manualPreferred
}

struct CardPresentDetailsApi {
    let brand: CardBrandApi?
    let country: String?
    let expMonth: Int
    let expYear: Int
    let funding: CardFundingTypeApi?
    let last4: String?
    let cardholderName: String?
    let emvAuthData: String?
    let generatedCard: String?
    let incrementalAuthorizationStatus: IncrementalAuthorizationStatusApi?
    let networks: CardNetworksApi?
    let receipt: ReceiptDetailsApi?

    func serialize() -> [Any?] {
        return [
            brand?.rawValue,
            country,
            expMonth,
            expYear,
            funding?.rawValue,
            last4,
            cardholderName,
            emvAuthData,
            generatedCard,
            incrementalAuthorizationStatus?.rawValue,
            networks?.serialize(),
            receipt?.serialize(),
        ]
    }
}

struct CardPresentParametersApi {
    let captureMethod: CardPresentCaptureMethodApi?
    let requestExtendedAuthorization: Bool?
    let requestIncrementalAuthorizationSupport: Bool?
    let requestedPriority: CardPresentRoutingApi?

    static func deserialize(
        _ serialized: [Any?]
    ) -> CardPresentParametersApi {
        return CardPresentParametersApi(
            captureMethod: !(serialized[0] is NSNull) ? CardPresentCaptureMethodApi(rawValue: serialized[0] as! Int)! : nil,
            requestExtendedAuthorization: serialized[1] as? Bool,
            requestIncrementalAuthorizationSupport: serialized[2] as? Bool,
            requestedPriority: !(serialized[3] is NSNull) ? CardPresentRoutingApi(rawValue: serialized[3] as! Int)! : nil
        )
    }
}

enum CardPresentRoutingApi: Int {
    case domestic
    case international
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

struct ChargeApi {
    let amount: Int
    let currency: String
    let status: ChargeStatusApi
    let paymentMethodDetails: PaymentMethodDetailsApi?
    let description: String
    let id: String
    let metadata: [String: String]
    let statementDescriptorSuffix: String?
    let calculatedStatementDescriptor: String?
    let authorizationCode: String?

    func serialize() -> [Any?] {
        return [
            amount,
            currency,
            status.rawValue,
            paymentMethodDetails?.serialize(),
            description,
            id,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
            statementDescriptorSuffix,
            calculatedStatementDescriptor,
            authorizationCode,
        ]
    }
}

enum ChargeStatusApi: Int {
    case succeeded
    case pending
    case failed
}

enum ConfirmationMethodApi: Int {
    case automatic
    case manual
}

enum ConnectionStatusApi: Int {
    case notConnected
    case connected
    case connecting
}

enum DeviceTypeApi: Int {
    case chipper1X
    case chipper2X
    case stripeM2
    case cotsDevice
    case verifoneP400
    case wiseCube
    case wisePad3
    case wisePad3s
    case wisePosE
    case wisePosEDevkit
    case etna
    case stripeS700
    case stripeS700Devkit
    case appleBuiltIn
}

protocol DiscoveryConfigurationApi {}

func deserializeDiscoveryConfigurationApi(
    _ serialized: [Any?]
) -> DiscoveryConfigurationApi {
    switch serialized[0] as! String {
    case "BluetoothDiscoveryConfiguration":
        return BluetoothDiscoveryConfigurationApi.deserialize(Array(serialized.dropFirst()))
    case "BluetoothProximityDiscoveryConfiguration":
        return BluetoothProximityDiscoveryConfigurationApi.deserialize(Array(serialized.dropFirst()))
    case "HandoffDiscoveryConfiguration":
        return HandoffDiscoveryConfigurationApi.deserialize(Array(serialized.dropFirst()))
    case "InternetDiscoveryConfiguration":
        return InternetDiscoveryConfigurationApi.deserialize(Array(serialized.dropFirst()))
    case "LocalMobileDiscoveryConfiguration":
        return LocalMobileDiscoveryConfigurationApi.deserialize(Array(serialized.dropFirst()))
    case "UsbDiscoveryConfiguration":
        return UsbDiscoveryConfigurationApi.deserialize(Array(serialized.dropFirst()))
    default:
        fatalError()
    }
}

struct BluetoothDiscoveryConfigurationApi: DiscoveryConfigurationApi {
    let isSimulated: Bool
    let timeout: Int?

    static func deserialize(
        _ serialized: [Any?]
    ) -> BluetoothDiscoveryConfigurationApi {
        return BluetoothDiscoveryConfigurationApi(
            isSimulated: serialized[0] as! Bool,
            timeout: serialized[1] as? Int
        )
    }
}

struct BluetoothProximityDiscoveryConfigurationApi: DiscoveryConfigurationApi {
    let isSimulated: Bool

    static func deserialize(
        _ serialized: [Any?]
    ) -> BluetoothProximityDiscoveryConfigurationApi {
        return BluetoothProximityDiscoveryConfigurationApi(
            isSimulated: serialized[0] as! Bool
        )
    }
}

struct HandoffDiscoveryConfigurationApi: DiscoveryConfigurationApi {
    static func deserialize(
        _ serialized: [Any?]
    ) -> HandoffDiscoveryConfigurationApi {
        return HandoffDiscoveryConfigurationApi(
        
        )
    }
}

struct InternetDiscoveryConfigurationApi: DiscoveryConfigurationApi {
    let isSimulated: Bool
    let locationId: String?

    static func deserialize(
        _ serialized: [Any?]
    ) -> InternetDiscoveryConfigurationApi {
        return InternetDiscoveryConfigurationApi(
            isSimulated: serialized[0] as! Bool,
            locationId: serialized[1] as? String
        )
    }
}

struct LocalMobileDiscoveryConfigurationApi: DiscoveryConfigurationApi {
    let isSimulated: Bool

    static func deserialize(
        _ serialized: [Any?]
    ) -> LocalMobileDiscoveryConfigurationApi {
        return LocalMobileDiscoveryConfigurationApi(
            isSimulated: serialized[0] as! Bool
        )
    }
}

struct UsbDiscoveryConfigurationApi: DiscoveryConfigurationApi {
    let isSimulated: Bool
    let timeout: Int?

    static func deserialize(
        _ serialized: [Any?]
    ) -> UsbDiscoveryConfigurationApi {
        return UsbDiscoveryConfigurationApi(
            isSimulated: serialized[0] as! Bool,
            timeout: serialized[1] as? Int
        )
    }
}

enum IncrementalAuthorizationStatusApi: Int {
    case notSupported
    case supported
}

struct LocationApi {
    let address: AddressApi?
    let displayName: String?
    let id: String?
    let livemode: Bool?
    let metadata: [String: String]

    func serialize() -> [Any?] {
        return [
            address?.serialize(),
            displayName,
            id,
            livemode,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
        ]
    }
}

enum LocationStatusApi: Int {
    case set
    case notSet
}

struct PaymentIntentApi {
    let id: String
    let created: Date
    let status: PaymentIntentStatusApi
    let amount: Double
    let captureMethod: CaptureMethodApi
    let currency: String
    let metadata: [String: String]
    let charges: [ChargeApi]
    let paymentMethod: PaymentMethodApi?
    let paymentMethodId: String?
    let amountDetails: AmountDetailsApi?
    let amountTip: Double?
    let statementDescriptor: String?
    let statementDescriptorSuffix: String?
    let amountCapturable: Double?
    let amountReceived: Double?
    let applicationId: String?
    let applicationFeeAmount: Double?
    let cancellationReason: String?
    let canceledAt: Date?
    let clientSecret: String?
    let confirmationMethod: ConfirmationMethodApi?
    let customerId: String?
    let description: String?
    let invoiceId: String?
    let onBehalfOf: String?
    let reviewId: String?
    let receiptEmail: String?
    let setupFutureUsage: PaymentIntentUsageApi?
    let transferGroup: String?

    func serialize() -> [Any?] {
        return [
            id,
            Int(created.timeIntervalSince1970 * 1000),
            status.rawValue,
            amount,
            captureMethod.rawValue,
            currency,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
            charges.map { $0.serialize() },
            paymentMethod?.serialize(),
            paymentMethodId,
            amountDetails?.serialize(),
            amountTip,
            statementDescriptor,
            statementDescriptorSuffix,
            amountCapturable,
            amountReceived,
            applicationId,
            applicationFeeAmount,
            cancellationReason,
            canceledAt != nil ? Int(canceledAt!.timeIntervalSince1970 * 1000) : nil,
            clientSecret,
            confirmationMethod?.rawValue,
            customerId,
            description,
            invoiceId,
            onBehalfOf,
            reviewId,
            receiptEmail,
            setupFutureUsage?.rawValue,
            transferGroup,
        ]
    }
}

struct PaymentIntentParametersApi {
    let amount: Int
    let currency: String
    let captureMethod: CaptureMethodApi
    let paymentMethodTypes: [PaymentMethodTypeApi]
    let metadata: [String: String]
    let description: String?
    let statementDescriptor: String?
    let statementDescriptorSuffix: String?
    let receiptEmail: String?
    let customerId: String?
    let applicationFeeAmount: Int?
    let transferDataDestination: String?
    let transferGroup: String?
    let onBehalfOf: String?
    let setupFutureUsage: PaymentIntentUsageApi?
    let paymentMethodOptionsParameters: PaymentMethodOptionsParametersApi?

    static func deserialize(
        _ serialized: [Any?]
    ) -> PaymentIntentParametersApi {
        return PaymentIntentParametersApi(
            amount: serialized[0] as! Int,
            currency: serialized[1] as! String,
            captureMethod: CaptureMethodApi(rawValue: serialized[2] as! Int)!,
            paymentMethodTypes: (serialized[3] as! [Any?]).map { PaymentMethodTypeApi(rawValue: $0 as! Int)! },
            metadata: Dictionary(uniqueKeysWithValues: (serialized[4] as! [AnyHashable?: Any?]).map { k, v in (k as! String, v as! String) }),
            description: serialized[5] as? String,
            statementDescriptor: serialized[6] as? String,
            statementDescriptorSuffix: serialized[7] as? String,
            receiptEmail: serialized[8] as? String,
            customerId: serialized[9] as? String,
            applicationFeeAmount: serialized[10] as? Int,
            transferDataDestination: serialized[11] as? String,
            transferGroup: serialized[12] as? String,
            onBehalfOf: serialized[13] as? String,
            setupFutureUsage: !(serialized[14] is NSNull) ? PaymentIntentUsageApi(rawValue: serialized[14] as! Int)! : nil,
            paymentMethodOptionsParameters: !(serialized[15] is NSNull) ? PaymentMethodOptionsParametersApi.deserialize(serialized[15] as! [Any?]) : nil
        )
    }
}

enum PaymentIntentStatusApi: Int {
    case canceled
    case processing
    case requiresCapture
    case requiresConfirmation
    case requiresPaymentMethod
    case requiresAction
    case succeeded
}

enum PaymentIntentUsageApi: Int {
    case onSession
    case offSession
}

struct PaymentMethodApi {
    let id: String
    let card: CardDetailsApi?
    let cardPresent: CardPresentDetailsApi?
    let interacPresent: CardPresentDetailsApi?
    let customerId: String?
    let metadata: [String: String]

    func serialize() -> [Any?] {
        return [
            id,
            card?.serialize(),
            cardPresent?.serialize(),
            interacPresent?.serialize(),
            customerId,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
        ]
    }
}

struct PaymentMethodDetailsApi {
    let cardPresent: CardPresentDetailsApi?
    let interacPresent: CardPresentDetailsApi?

    func serialize() -> [Any?] {
        return [
            cardPresent?.serialize(),
            interacPresent?.serialize(),
        ]
    }
}

struct PaymentMethodOptionsParametersApi {
    let cardPresentParameters: CardPresentParametersApi

    static func deserialize(
        _ serialized: [Any?]
    ) -> PaymentMethodOptionsParametersApi {
        return PaymentMethodOptionsParametersApi(
            cardPresentParameters: CardPresentParametersApi.deserialize(serialized[0] as! [Any?])
        )
    }
}

enum PaymentMethodTypeApi: Int {
    case cardPresent
    case card
    case interactPresent
}

enum PaymentStatusApi: Int {
    case notReady
    case ready
    case waitingForInput
    case processing
}

struct ReaderApi {
    let locationStatus: LocationStatusApi?
    let deviceType: DeviceTypeApi?
    let simulated: Bool
    let locationId: String?
    let location: LocationApi?
    let serialNumber: String
    let availableUpdate: Bool
    let batteryLevel: Double
    let label: String?

    func serialize() -> [Any?] {
        return [
            locationStatus?.rawValue,
            deviceType?.rawValue,
            simulated,
            locationId,
            location?.serialize(),
            serialNumber,
            availableUpdate,
            batteryLevel,
            label,
        ]
    }
}

enum ReaderDisplayMessageApi: Int {
    case checkMobileDevice
    case retryCard
    case insertCard
    case insertOrSwipeCard
    case swipeCard
    case removeCard
    case multipleContactlessCardsDetected
    case tryAnotherReadMethod
    case tryAnotherCard
    case cardRemovedTooEarly
}

enum ReaderEventApi: Int {
    case cardInserted
    case cardRemoved
}

enum ReaderInputOptionApi: Int {
    case insertCard
    case swipeCard
    case tapCard
    case manualEntry
}

struct ReaderSoftwareUpdateApi {
    let components: [UpdateComponentApi]
    let keyProfileName: String?
    let onlyInstallRequiredUpdates: Bool
    let requiredAt: Date
    let settingsVersion: String?
    let timeEstimate: UpdateTimeEstimateApi
    let version: String

    func serialize() -> [Any?] {
        return [
            components.map { $0.rawValue },
            keyProfileName,
            onlyInstallRequiredUpdates,
            Int(requiredAt.timeIntervalSince1970 * 1000),
            settingsVersion,
            timeEstimate.rawValue,
            version,
        ]
    }
}

struct ReceiptDetailsApi {
    let accountType: String?
    let applicationPreferredName: String
    let authorizationCode: String?
    let authorizationResponseCode: String
    let applicationCryptogram: String
    let dedicatedFileName: String
    let transactionStatusInformation: String
    let terminalVerificationResults: String

    func serialize() -> [Any?] {
        return [
            accountType,
            applicationPreferredName,
            authorizationCode,
            authorizationResponseCode,
            applicationCryptogram,
            dedicatedFileName,
            transactionStatusInformation,
            terminalVerificationResults,
        ]
    }
}

struct RefundApi {
    let id: String
    let amount: Int
    let chargeId: String
    let created: Date
    let currency: String
    let metadata: [String: String]
    let reason: String?
    let status: RefundStatusApi?
    let paymentMethodDetails: PaymentMethodDetailsApi?
    let failureReason: String?

    func serialize() -> [Any?] {
        return [
            id,
            amount,
            chargeId,
            Int(created.timeIntervalSince1970 * 1000),
            currency,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
            reason,
            status?.rawValue,
            paymentMethodDetails?.serialize(),
            failureReason,
        ]
    }
}

enum RefundStatusApi: Int {
    case succeeded
    case pending
    case failed
}

struct SetupAttemptApi {
    let id: String
    let applicationId: String?
    let created: Date
    let customerId: String?
    let onBehalfOf: String?
    let paymentMethodId: String?
    let paymentMethodDetails: SetupAttemptPaymentMethodDetailsApi?
    let setupIntentId: String
    let status: SetupAttemptStatusApi

    func serialize() -> [Any?] {
        return [
            id,
            applicationId,
            Int(created.timeIntervalSince1970 * 1000),
            customerId,
            onBehalfOf,
            paymentMethodId,
            paymentMethodDetails?.serialize(),
            setupIntentId,
            status.rawValue,
        ]
    }
}

struct SetupAttemptCardPresentDetailsApi {
    let emvAuthData: String
    let generatedCard: String

    func serialize() -> [Any?] {
        return [
            emvAuthData,
            generatedCard,
        ]
    }
}

struct SetupAttemptPaymentMethodDetailsApi {
    let cardPresent: SetupAttemptCardPresentDetailsApi?
    let interacPresent: SetupAttemptCardPresentDetailsApi?

    func serialize() -> [Any?] {
        return [
            cardPresent?.serialize(),
            interacPresent?.serialize(),
        ]
    }
}

enum SetupAttemptStatusApi: Int {
    case requiresConfirmation
    case requiresAction
    case processing
    case succeeded
    case failed
    case abandoned
}

struct SetupIntentApi {
    let id: String
    let created: Date
    let customerId: String?
    let metadata: [String: String]
    let usage: SetupIntentUsageApi
    let status: SetupIntentStatusApi
    let latestAttempt: SetupAttemptApi?

    func serialize() -> [Any?] {
        return [
            id,
            Int(created.timeIntervalSince1970 * 1000),
            customerId,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
            usage.rawValue,
            status.rawValue,
            latestAttempt?.serialize(),
        ]
    }
}

enum SetupIntentStatusApi: Int {
    case requiresPaymentMethod
    case requiresConfirmation
    case requiresAction
    case processing
    case succeeded
    case cancelled
}

enum SetupIntentUsageApi: Int {
    case onSession
    case offSession
}

struct TerminalExceptionApi {
    let code: TerminalExceptionCodeApi
    let message: String
    let stackTrace: String?
    let paymentIntent: PaymentIntentApi?
    let apiError: Any?

    func serialize() -> [Any?] {
        return [
            code.rawValue,
            message,
            stackTrace,
            paymentIntent?.serialize(),
            apiError,
        ]
    }
}

enum TerminalExceptionCodeApi: Int {
    case unknown
    case readerNotRecovered
    case paymentIntentNotRecovered
    case setupIntentNotRecovered
    case cancelFailed
    case notConnectedToReader
    case alreadyConnectedToReader
    case bluetoothDisabled
    case bluetoothPermissionDenied
    case confirmInvalidPaymentIntent
    case invalidClientSecret
    case invalidReaderForUpdate
    case unsupportedOperation
    case unexpectedOperation
    case unsupportedSdk
    case featureNotAvailableWithConnectedReader
    case usbPermissionDenied
    case usbDiscoveryTimedOut
    case invalidParameter
    case invalidRequiredParameter
    case invalidTipParameter
    case localMobileUnsupportedDevice
    case localMobileUnsupportedOperatingSystemVersion
    case localMobileDeviceTampered
    case localMobileDebugNotSupported
    case offlineModeUnsupportedOperatingSystemVersion
    case canceled
    case locationServicesDisabled
    case bluetoothScanTimedOut
    case bluetoothLowEnergyUnsupported
    case readerSoftwareUpdateFailedBatteryLow
    case readerSoftwareUpdateFailedInterrupted
    case readerSoftwareUpdateFailedExpiredUpdate
    case bluetoothConnectionFailedBatteryCriticallyLow
    case cardInsertNotRead
    case cardSwipeNotRead
    case cardReadTimedOut
    case cardRemoved
    case customerConsentRequired
    case cardLeftInReader
    case featureNotEnabledOnAccount
    case passcodeNotEnabled
    case commandNotAllowedDuringCall
    case invalidAmount
    case invalidCurrency
    case appleBuiltInReaderTOSAcceptanceRequiresiCloudSignIn
    case appleBuiltInReaderTOSAcceptanceCanceled
    case appleBuiltInReaderFailedToPrepare
    case appleBuiltInReaderDeviceBanned
    case appleBuiltInReaderTOSNotYetAccepted
    case appleBuiltInReaderTOSAcceptanceFailed
    case appleBuiltInReaderMerchantBlocked
    case appleBuiltInReaderInvalidMerchant
    case readerBusy
    case incompatibleReader
    case readerCommunicationError
    case unknownReaderIpAddress
    case internetConnectTimeOut
    case connectFailedReaderIsInUse
    case readerNotAccessibleInBackground
    case bluetoothError
    case bluetoothConnectTimedOut
    case bluetoothDisconnected
    case bluetoothPeerRemovedPairingInformation
    case bluetoothAlreadyPairedWithAnotherDevice
    case bluetoothReconnectStarted
    case usbDisconnected
    case usbReconnectStarted
    case readerConnectedToAnotherDevice
    case readerSoftwareUpdateFailed
    case readerSoftwareUpdateFailedReaderError
    case readerSoftwareUpdateFailedServerError
    case nfcDisabled
    case unsupportedReaderVersion
    case unexpectedSdkError
    case unexpectedReaderError
    case encryptionKeyFailure
    case encryptionKeyStillInitializing
    case declinedByStripeApi
    case declinedByReader
    case notConnectedToInternet
    case requestTimedOut
    case stripeApiConnectionError
    case stripeApiError
    case stripeApiResponseDecodingError
    case internalNetworkError
    case connectionTokenProviderError
    case sessionExpired
    case unsupportedMobileDeviceConfiguration
    case commandNotAllowed
    case amountExceedsMaxOfflineAmount
    case offlinePaymentsDatabaseTooLarge
    case readerConnectionNotAvailableOffline
    case readerConnectionOfflineLocationMismatch
    case readerConnectionOfflineNeedsUpdate
    case locationConnectionNotAvailableOffline
    case noLastSeenAccount
    case invalidOfflineCurrency
    case refundFailed
    case cardSwipeNotAvailable
    case interacNotSupportedOffline
    case onlinePinNotSupportedOffline
    case offlineAndCardExpired
    case offlineTransactionDeclined
    case offlineCollectAndConfirmMismatch
    case forwardingTestModePaymentInLiveMode
    case forwardingLiveModePaymentInTestMode
    case offlinePaymentIntentNotFound
    case updatePaymentIntentUnavailableWhileOffline
    case updatePaymentIntentUnavailableWhileOfflineModeEnabled
    case missingEmvData
    case connectionTokenProviderErrorWhileForwarding
    case connectionTokenProviderTimedOut
    case accountIdMismatchWhileForwarding
    case offlineBehaviorForceOfflineWithFeatureDisabled
    case notConnectedToInternetAndOfflineBehaviorRequireOnline
    case testCardInLiveMode
    case collectInputsApplicationError
    case collectInputsTimedOut
    case collectInputsUnsupported
}

struct TipApi {
    let amount: Int?

    func serialize() -> [Any?] {
        return [
            amount,
        ]
    }
}

struct TippingConfigurationApi {
    let eligibleAmount: Int

    static func deserialize(
        _ serialized: [Any?]
    ) -> TippingConfigurationApi {
        return TippingConfigurationApi(
            eligibleAmount: serialized[0] as! Int
        )
    }
}

enum UpdateComponentApi: Int {
    case incremental
    case firmware
    case config
    case keys
}

enum UpdateTimeEstimateApi: Int {
    case lessThanOneMinute
    case oneToTwoMinutes
    case twoToFiveMinutes
    case fiveToFifteenMinutes
}

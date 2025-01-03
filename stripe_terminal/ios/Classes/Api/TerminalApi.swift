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

    func onConnectReader(
        _ serialNumber: String,
        _ configuration: ConnectionConfigurationApi
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

    func onRebootReader() async throws -> Void

    func onDisconnectReader() async throws -> Void

    func onSetSimulatorConfiguration(
        _ configuration: SimulatorConfigurationApi
    ) throws -> Void

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
        _ requestDynamicCurrencyConversion: Bool,
        _ surchargeNotice: String?,
        _ skipTipping: Bool,
        _ tippingConfiguration: TippingConfigurationApi?,
        _ shouldUpdatePaymentIntent: Bool,
        _ customerCancellationEnabled: Bool
    ) throws

    func onStopCollectPaymentMethod(
        _ operationId: Int
    ) async throws -> Void

    func onStartConfirmPaymentIntent(
        _ result: Result<PaymentIntentApi>,
        _ operationId: Int,
        _ paymentIntentId: String
    ) throws

    func onStopConfirmPaymentIntent(
        _ operationId: Int
    ) async throws -> Void

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
        _ allowRedisplay: AllowRedisplayApi,
        _ customerCancellationEnabled: Bool
    ) throws

    func onStopCollectSetupIntentPaymentMethod(
        _ operationId: Int
    ) async throws -> Void

    func onStartConfirmSetupIntent(
        _ result: Result<SetupIntentApi>,
        _ operationId: Int,
        _ setupIntentId: String
    ) throws

    func onStopConfirmSetupIntent(
        _ operationId: Int
    ) async throws -> Void

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

    func onStartConfirmRefund(
        _ result: Result<RefundApi>,
        _ operationId: Int
    ) throws

    func onStopConfirmRefund(
        _ operationId: Int
    ) async throws -> Void

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
            case "connectReader":
                runAsync {
                    let res = try await hostApi.onConnectReader(args[0] as! String, deserializeConnectionConfigurationApi(args[1] as! [Any?]))
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
            case "rebootReader":
                runAsync {
                    try await hostApi.onRebootReader()
                    return nil
                }
            case "disconnectReader":
                runAsync {
                    try await hostApi.onDisconnectReader()
                    return nil
                }
            case "setSimulatorConfiguration":
                let res = try hostApi.onSetSimulatorConfiguration(SimulatorConfigurationApi.deserialize(args[0] as! [Any?]))
                result(nil)
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
                try hostApi.onStartCollectPaymentMethod(res, args[0] as! Int, args[1] as! String, args[2] as! Bool, args[3] as? String, args[4] as! Bool, !(args[5] is NSNull) ? TippingConfigurationApi.deserialize(args[5] as! [Any?]) : nil, args[6] as! Bool, args[7] as! Bool)
            case "stopCollectPaymentMethod":
                runAsync {
                    try await hostApi.onStopCollectPaymentMethod(args[0] as! Int)
                    return nil
                }
            case "startConfirmPaymentIntent":
                let res = Result<PaymentIntentApi>(result) { $0.serialize() }
                try hostApi.onStartConfirmPaymentIntent(res, args[0] as! Int, args[1] as! String)
            case "stopConfirmPaymentIntent":
                runAsync {
                    try await hostApi.onStopConfirmPaymentIntent(args[0] as! Int)
                    return nil
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
                try hostApi.onStartCollectSetupIntentPaymentMethod(res, args[0] as! Int, args[1] as! String, AllowRedisplayApi(rawValue: args[2] as! Int)!, args[3] as! Bool)
            case "stopCollectSetupIntentPaymentMethod":
                runAsync {
                    try await hostApi.onStopCollectSetupIntentPaymentMethod(args[0] as! Int)
                    return nil
                }
            case "startConfirmSetupIntent":
                let res = Result<SetupIntentApi>(result) { $0.serialize() }
                try hostApi.onStartConfirmSetupIntent(res, args[0] as! Int, args[1] as! String)
            case "stopConfirmSetupIntent":
                runAsync {
                    try await hostApi.onStopConfirmSetupIntent(args[0] as! Int)
                    return nil
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
            case "startConfirmRefund":
                let res = Result<RefundApi>(result) { $0.serialize() }
                try hostApi.onStartConfirmRefund(res, args[0] as! Int)
            case "stopConfirmRefund":
                runAsync {
                    try await hostApi.onStopConfirmRefund(args[0] as! Int)
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

    func readerReconnectFailed(
        reader: ReaderApi
    ) {
        channel.invokeMethod("_onReaderReconnectFailed", arguments: [reader.serialize()])
    }

    func readerReconnectStarted(
        reader: ReaderApi,
        reason: DisconnectReasonApi
    ) {
        channel.invokeMethod("_onReaderReconnectStarted", arguments: [reader.serialize(), reason.rawValue])
    }

    func readerReconnectSucceeded(
        reader: ReaderApi
    ) {
        channel.invokeMethod("_onReaderReconnectSucceeded", arguments: [reader.serialize()])
    }

    func disconnect(
        reason: DisconnectReasonApi
    ) {
        channel.invokeMethod("_onDisconnect", arguments: [reason.rawValue])
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

enum AllowRedisplayApi: Int {
    case always
    case limited
    case unspecified
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
    let cardholderName: String?
    let country: String?
    let emvAuthData: String?
    let expMonth: Int
    let expYear: Int
    let funding: CardFundingTypeApi?
    let generatedCard: String?
    let incrementalAuthorizationStatus: IncrementalAuthorizationStatusApi?
    let last4: String?
    let networks: CardNetworksApi?
    let receipt: ReceiptDetailsApi?

    func serialize() -> [Any?] {
        return [
            brand?.rawValue,
            cardholderName,
            country,
            emvAuthData,
            expMonth,
            expYear,
            funding?.rawValue,
            generatedCard,
            incrementalAuthorizationStatus?.rawValue,
            last4,
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
    let lineItems: [CartLineItemApi]
    let tax: Int
    let total: Int

    static func deserialize(
        _ serialized: [Any?]
    ) -> CartApi {
        return CartApi(
            currency: serialized[0] as! String,
            lineItems: (serialized[1] as! [Any?]).map { CartLineItemApi.deserialize($0 as! [Any?]) },
            tax: serialized[2] as! Int,
            total: serialized[3] as! Int
        )
    }
}

struct CartLineItemApi {
    let amount: Int
    let description: String
    let quantity: Int

    static func deserialize(
        _ serialized: [Any?]
    ) -> CartLineItemApi {
        return CartLineItemApi(
            amount: serialized[0] as! Int,
            description: serialized[1] as! String,
            quantity: serialized[2] as! Int
        )
    }
}

struct ChargeApi {
    let amount: Int
    let authorizationCode: String?
    let calculatedStatementDescriptor: String?
    let currency: String
    let description: String?
    let id: String
    let metadata: [String: String]
    let paymentMethodDetails: PaymentMethodDetailsApi?
    let statementDescriptorSuffix: String?
    let status: ChargeStatusApi

    func serialize() -> [Any?] {
        return [
            amount,
            authorizationCode,
            calculatedStatementDescriptor,
            currency,
            description,
            id,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
            paymentMethodDetails?.serialize(),
            statementDescriptorSuffix,
            status.rawValue,
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

protocol ConnectionConfigurationApi {}

func deserializeConnectionConfigurationApi(
    _ serialized: [Any?]
) -> ConnectionConfigurationApi {
    switch serialized[0] as! String {
    case "BluetoothConnectionConfiguration":
        return BluetoothConnectionConfigurationApi.deserialize(Array(serialized.dropFirst()))
    case "HandoffConnectionConfiguration":
        return HandoffConnectionConfigurationApi.deserialize(Array(serialized.dropFirst()))
    case "InternetConnectionConfiguration":
        return InternetConnectionConfigurationApi.deserialize(Array(serialized.dropFirst()))
    case "TapToPayConnectionConfiguration":
        return TapToPayConnectionConfigurationApi.deserialize(Array(serialized.dropFirst()))
    case "UsbConnectionConfiguration":
        return UsbConnectionConfigurationApi.deserialize(Array(serialized.dropFirst()))
    default:
        fatalError()
    }
}

struct BluetoothConnectionConfigurationApi: ConnectionConfigurationApi {
    let autoReconnectOnUnexpectedDisconnect: Bool
    let locationId: String

    static func deserialize(
        _ serialized: [Any?]
    ) -> BluetoothConnectionConfigurationApi {
        return BluetoothConnectionConfigurationApi(
            autoReconnectOnUnexpectedDisconnect: serialized[0] as! Bool,
            locationId: serialized[1] as! String
        )
    }
}

struct HandoffConnectionConfigurationApi: ConnectionConfigurationApi {
    static func deserialize(
        _ serialized: [Any?]
    ) -> HandoffConnectionConfigurationApi {
        return HandoffConnectionConfigurationApi(
        
        )
    }
}

struct InternetConnectionConfigurationApi: ConnectionConfigurationApi {
    let failIfInUse: Bool

    static func deserialize(
        _ serialized: [Any?]
    ) -> InternetConnectionConfigurationApi {
        return InternetConnectionConfigurationApi(
            failIfInUse: serialized[0] as! Bool
        )
    }
}

struct TapToPayConnectionConfigurationApi: ConnectionConfigurationApi {
    let autoReconnectOnUnexpectedDisconnect: Bool
    let locationId: String

    static func deserialize(
        _ serialized: [Any?]
    ) -> TapToPayConnectionConfigurationApi {
        return TapToPayConnectionConfigurationApi(
            autoReconnectOnUnexpectedDisconnect: serialized[0] as! Bool,
            locationId: serialized[1] as! String
        )
    }
}

struct UsbConnectionConfigurationApi: ConnectionConfigurationApi {
    let autoReconnectOnUnexpectedDisconnect: Bool
    let locationId: String

    static func deserialize(
        _ serialized: [Any?]
    ) -> UsbConnectionConfigurationApi {
        return UsbConnectionConfigurationApi(
            autoReconnectOnUnexpectedDisconnect: serialized[0] as! Bool,
            locationId: serialized[1] as! String
        )
    }
}

enum ConnectionStatusApi: Int {
    case notConnected
    case connected
    case connecting
    case discovering
}

enum DeviceTypeApi: Int {
    case chipper1X
    case chipper2X
    case stripeM2
    case tapToPay
    case verifoneP400
    case wiseCube
    case wisePad3
    case wisePad3s
    case wisePosE
    case wisePosEDevkit
    case etna
    case stripeS700
    case stripeS700Devkit
    case stripeS710
    case stripeS710Devkit
}

enum DisconnectReasonApi: Int {
    case unknown
    case disconnectRequested
    case rebootRequested
    case securityReboot
    case criticallyLowBattery
    case poweredOff
    case bluetoothDisabled
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
    case "TapToPayDiscoveryConfiguration":
        return TapToPayDiscoveryConfigurationApi.deserialize(Array(serialized.dropFirst()))
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
    let timeout: Int?

    static func deserialize(
        _ serialized: [Any?]
    ) -> InternetDiscoveryConfigurationApi {
        return InternetDiscoveryConfigurationApi(
            isSimulated: serialized[0] as! Bool,
            locationId: serialized[1] as? String,
            timeout: serialized[2] as? Int
        )
    }
}

struct TapToPayDiscoveryConfigurationApi: DiscoveryConfigurationApi {
    let isSimulated: Bool

    static func deserialize(
        _ serialized: [Any?]
    ) -> TapToPayDiscoveryConfigurationApi {
        return TapToPayDiscoveryConfigurationApi(
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
    let amount: Double
    let amountCapturable: Double?
    let amountDetails: AmountDetailsApi?
    let amountReceived: Double?
    let amountTip: Double?
    let applicationFeeAmount: Double?
    let applicationId: String?
    let canceledAt: Date?
    let cancellationReason: String?
    let captureMethod: CaptureMethodApi
    let charges: [ChargeApi]
    let clientSecret: String?
    let confirmationMethod: ConfirmationMethodApi?
    let created: Date
    let currency: String
    let customerId: String?
    let description: String?
    let id: String
    let invoiceId: String?
    let metadata: [String: String]
    let onBehalfOf: String?
    let paymentMethod: PaymentMethodApi?
    let paymentMethodId: String?
    let receiptEmail: String?
    let reviewId: String?
    let setupFutureUsage: PaymentIntentUsageApi?
    let statementDescriptor: String?
    let statementDescriptorSuffix: String?
    let status: PaymentIntentStatusApi
    let transferGroup: String?

    func serialize() -> [Any?] {
        return [
            amount,
            amountCapturable,
            amountDetails?.serialize(),
            amountReceived,
            amountTip,
            applicationFeeAmount,
            applicationId,
            canceledAt != nil ? Int(canceledAt!.timeIntervalSince1970 * 1000) : nil,
            cancellationReason,
            captureMethod.rawValue,
            charges.map { $0.serialize() },
            clientSecret,
            confirmationMethod?.rawValue,
            Int(created.timeIntervalSince1970 * 1000),
            currency,
            customerId,
            description,
            id,
            invoiceId,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
            onBehalfOf,
            paymentMethod?.serialize(),
            paymentMethodId,
            receiptEmail,
            reviewId,
            setupFutureUsage?.rawValue,
            statementDescriptor,
            statementDescriptorSuffix,
            status.rawValue,
            transferGroup,
        ]
    }
}

struct PaymentIntentParametersApi {
    let amount: Int
    let applicationFeeAmount: Int?
    let captureMethod: CaptureMethodApi
    let currency: String
    let customerId: String?
    let description: String?
    let metadata: [String: String]
    let onBehalfOf: String?
    let paymentMethodOptionsParameters: PaymentMethodOptionsParametersApi?
    let paymentMethodTypes: [PaymentMethodTypeApi]
    let receiptEmail: String?
    let setupFutureUsage: PaymentIntentUsageApi?
    let statementDescriptor: String?
    let statementDescriptorSuffix: String?
    let transferDataDestination: String?
    let transferGroup: String?

    static func deserialize(
        _ serialized: [Any?]
    ) -> PaymentIntentParametersApi {
        return PaymentIntentParametersApi(
            amount: serialized[0] as! Int,
            applicationFeeAmount: serialized[1] as? Int,
            captureMethod: CaptureMethodApi(rawValue: serialized[2] as! Int)!,
            currency: serialized[3] as! String,
            customerId: serialized[4] as? String,
            description: serialized[5] as? String,
            metadata: Dictionary(uniqueKeysWithValues: (serialized[6] as! [AnyHashable?: Any?]).map { k, v in (k as! String, v as! String) }),
            onBehalfOf: serialized[7] as? String,
            paymentMethodOptionsParameters: !(serialized[8] is NSNull) ? PaymentMethodOptionsParametersApi.deserialize(serialized[8] as! [Any?]) : nil,
            paymentMethodTypes: (serialized[9] as! [Any?]).map { PaymentMethodTypeApi(rawValue: $0 as! Int)! },
            receiptEmail: serialized[10] as? String,
            setupFutureUsage: !(serialized[11] is NSNull) ? PaymentIntentUsageApi(rawValue: serialized[11] as! Int)! : nil,
            statementDescriptor: serialized[12] as? String,
            statementDescriptorSuffix: serialized[13] as? String,
            transferDataDestination: serialized[14] as? String,
            transferGroup: serialized[15] as? String
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
    let card: CardDetailsApi?
    let cardPresent: CardPresentDetailsApi?
    let customerId: String?
    let id: String
    let interacPresent: CardPresentDetailsApi?
    let metadata: [String: String]

    func serialize() -> [Any?] {
        return [
            card?.serialize(),
            cardPresent?.serialize(),
            customerId,
            id,
            interacPresent?.serialize(),
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
    let availableUpdate: Bool
    let batteryLevel: Double
    let deviceType: DeviceTypeApi?
    let label: String?
    let location: LocationApi?
    let locationId: String?
    let locationStatus: LocationStatusApi?
    let serialNumber: String
    let simulated: Bool

    func serialize() -> [Any?] {
        return [
            availableUpdate,
            batteryLevel,
            deviceType?.rawValue,
            label,
            location?.serialize(),
            locationId,
            locationStatus?.rawValue,
            serialNumber,
            simulated,
        ]
    }
}

protocol ReaderDelegateAbstractApi {}

func deserializeReaderDelegateAbstractApi(
    _ serialized: [Any?]
) -> ReaderDelegateAbstractApi {
    switch serialized[0] as! String {
    case "MobileReaderDelegate":
        return MobileReaderDelegateApi.deserialize(Array(serialized.dropFirst()))
    case "HandoffReaderDelegate":
        return HandoffReaderDelegateApi.deserialize(Array(serialized.dropFirst()))
    case "InternetReaderDelegate":
        return InternetReaderDelegateApi.deserialize(Array(serialized.dropFirst()))
    case "TapToPayReaderDelegate":
        return TapToPayReaderDelegateApi.deserialize(Array(serialized.dropFirst()))
    default:
        fatalError()
    }
}

struct MobileReaderDelegateApi: ReaderDelegateAbstractApi {
    static func deserialize(
        _ serialized: [Any?]
    ) -> MobileReaderDelegateApi {
        return MobileReaderDelegateApi(
        
        )
    }
}

struct HandoffReaderDelegateApi: ReaderDelegateAbstractApi {
    static func deserialize(
        _ serialized: [Any?]
    ) -> HandoffReaderDelegateApi {
        return HandoffReaderDelegateApi(
        
        )
    }
}

struct InternetReaderDelegateApi: ReaderDelegateAbstractApi {
    static func deserialize(
        _ serialized: [Any?]
    ) -> InternetReaderDelegateApi {
        return InternetReaderDelegateApi(
        
        )
    }
}

struct TapToPayReaderDelegateApi: ReaderDelegateAbstractApi {
    static func deserialize(
        _ serialized: [Any?]
    ) -> TapToPayReaderDelegateApi {
        return TapToPayReaderDelegateApi(
        
        )
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
    let applicationCryptogram: String?
    let applicationPreferredName: String?
    let authorizationCode: String?
    let authorizationResponseCode: String
    let dedicatedFileName: String?
    let terminalVerificationResults: String?
    let transactionStatusInformation: String?

    func serialize() -> [Any?] {
        return [
            accountType,
            applicationCryptogram,
            applicationPreferredName,
            authorizationCode,
            authorizationResponseCode,
            dedicatedFileName,
            terminalVerificationResults,
            transactionStatusInformation,
        ]
    }
}

struct RefundApi {
    let amount: Int
    let chargeId: String
    let created: Date
    let currency: String
    let failureReason: String?
    let id: String
    let metadata: [String: String]
    let paymentMethodDetails: PaymentMethodDetailsApi?
    let reason: String?
    let status: RefundStatusApi?

    func serialize() -> [Any?] {
        return [
            amount,
            chargeId,
            Int(created.timeIntervalSince1970 * 1000),
            currency,
            failureReason,
            id,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
            paymentMethodDetails?.serialize(),
            reason,
            status?.rawValue,
        ]
    }
}

enum RefundStatusApi: Int {
    case succeeded
    case pending
    case failed
}

struct SetupAttemptApi {
    let applicationId: String?
    let created: Date
    let customerId: String?
    let id: String
    let onBehalfOf: String?
    let paymentMethodDetails: SetupAttemptPaymentMethodDetailsApi?
    let paymentMethodId: String?
    let setupIntentId: String
    let status: SetupAttemptStatusApi

    func serialize() -> [Any?] {
        return [
            applicationId,
            Int(created.timeIntervalSince1970 * 1000),
            customerId,
            id,
            onBehalfOf,
            paymentMethodDetails?.serialize(),
            paymentMethodId,
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
    let created: Date
    let customerId: String?
    let id: String
    let latestAttempt: SetupAttemptApi?
    let metadata: [String: String]
    let status: SetupIntentStatusApi
    let usage: SetupIntentUsageApi

    func serialize() -> [Any?] {
        return [
            Int(created.timeIntervalSince1970 * 1000),
            customerId,
            id,
            latestAttempt?.serialize(),
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
            status.rawValue,
            usage.rawValue,
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

enum SimulateReaderUpdateApi: Int {
    case available
    case none
    case required
    case random
}

struct SimulatedCardApi {
    let testCardNumber: String?
    let type: SimulatedCardTypeApi?

    static func deserialize(
        _ serialized: [Any?]
    ) -> SimulatedCardApi {
        return SimulatedCardApi(
            testCardNumber: serialized[0] as? String,
            type: !(serialized[1] is NSNull) ? SimulatedCardTypeApi(rawValue: serialized[1] as! Int)! : nil
        )
    }
}

enum SimulatedCardTypeApi: Int {
    case visa
    case visaDebit
    case visaUsCommonDebit
    case mastercard
    case masterDebit
    case mastercardPrepaid
    case amex
    case amex2
    case discover
    case discover2
    case diners
    case diners14Digit
    case jbc
    case unionPay
    case interac
    case eftposAuDebit
    case eftposAuVisaDebit
    case eftposAuDebitMastercard
    case chargeDeclined
    case chargeDeclinedInsufficientFunds
    case chargeDeclinedLostCard
    case chargeDeclinedStolenCard
    case chargeDeclinedExpiredCard
    case chargeDeclinedProcessingError
    case onlinePinCvm
    case onlinePinScaRetry
    case offlinePinCvm
    case offlinePinScaRetry
}

struct SimulatorConfigurationApi {
    let simulatedCard: SimulatedCardApi
    let simulatedTipAmount: Int?
    let update: SimulateReaderUpdateApi

    static func deserialize(
        _ serialized: [Any?]
    ) -> SimulatorConfigurationApi {
        return SimulatorConfigurationApi(
            simulatedCard: SimulatedCardApi.deserialize(serialized[0] as! [Any?]),
            simulatedTipAmount: serialized[1] as? Int,
            update: SimulateReaderUpdateApi(rawValue: serialized[2] as! Int)!
        )
    }
}

struct TerminalExceptionApi {
    let apiError: Any?
    let code: TerminalExceptionCodeApi
    let message: String
    let paymentIntent: PaymentIntentApi?
    let stackTrace: String?

    func serialize() -> [Any?] {
        return [
            apiError,
            code.rawValue,
            message,
            paymentIntent?.serialize(),
            stackTrace,
        ]
    }
}

enum TerminalExceptionCodeApi: Int {
    case unknown
    case readerNotRecovered
    case paymentIntentNotRecovered
    case setupIntentNotRecovered
    case cancelFailed
    case cancelFailedUnavailable
    case notConnectedToReader
    case alreadyConnectedToReader
    case bluetoothDisabled
    case bluetoothPermissionDenied
    case confirmInvalidPaymentIntent
    case confirmInvalidSetupIntent
    case invalidClientSecret
    case invalidReaderForUpdate
    case unsupportedOperation
    case unexpectedOperation
    case unsupportedSdk
    case featureNotAvailableWithConnectedReader
    case usbPermissionDenied
    case usbDiscoveryTimedOut
    case invalidParameter
    case requestDynamicCurrencyConversionRequiresUpdatePaymentIntent
    case dynamicCurrencyConversionNotAvailable
    case invalidRequiredParameter
    case invalidTipParameter
    case tapToPayUnsupportedDevice
    case tapToPayUnsupportedOperatingSystemVersion
    case tapToPayDeviceTampered
    case tapToPayDebugNotSupported
    case tapToPayInsecureEnvironment
    case offlineModeUnsupportedOperatingSystemVersion
    case canceled
    case locationServicesDisabled
    case bluetoothScanTimedOut
    case bluetoothLowEnergyUnsupported
    case readerSoftwareUpdateFailedBatteryLow
    case readerSoftwareUpdateFailedInterrupted
    case readerSoftwareUpdateFailedExpiredUpdate
    case readerBatteryCriticallyLow
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
    case tapToPayReaderTOSAcceptanceRequiresiCloudSignIn
    case tapToPayReaderTOSAcceptanceCanceled
    case tapToPayReaderFailedToPrepare
    case tapToPayReaderDeviceBanned
    case tapToPayReaderTOSNotYetAccepted
    case tapToPayReaderTOSAcceptanceFailed
    case tapToPayReaderMerchantBlocked
    case tapToPayReaderInvalidMerchant
    case tapToPayReaderAccountDeactivated
    case readerMissingEncryptionKeys
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
    case commandInvalidAllowRedisplay
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
    case mobileWalletNotSupportedOnSetupIntents
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
    case canceledDueToIntegrationError
    case collectInputsUnsupported
    case readerSettingsError
    case invalidSurchargeParameter
    case readerCommunicationSslError
    case allowRedisplayInvalid
    case surchargingNotAvailable
    case surchargeNoticeRequiresUpdatePaymentIntent
    case surchargeUnavailableWithDynamicCurrencyConversion
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

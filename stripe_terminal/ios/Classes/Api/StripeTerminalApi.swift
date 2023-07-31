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
        _ message: String? = nil,
        _ details: Any? = nil
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
        _ message: String? = nil,
        _ details: Any? = nil
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

protocol StripeTerminalPlatformApi {
    func onInit() async throws -> Void

    func onConnectionStatus() async throws -> ConnectionStatusApi

    func onSupportsReadersOfType(
        _ deviceType: DeviceTypeApi,
        _ discoveryMethod: DiscoveryMethodApi,
        _ simulated: Bool
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

    func onConnectedReader() async throws -> ReaderApi?

    func onCancelReaderReconnection() async throws -> Void

    func onListLocations(
        _ endingBefore: String?,
        _ limit: Int?,
        _ startingAfter: String?
    ) async throws -> [LocationApi]

    func onInstallAvailableUpdate() async throws -> Void

    func onCancelReaderUpdate() async throws -> Void

    func onDisconnectReader() async throws -> Void

    func onRetrievePaymentIntent(
        _ clientSecret: String
    ) async throws -> PaymentIntentApi

    func onStartCollectPaymentMethod(
        _ result: Result<PaymentIntentApi>,
        _ operationId: Int,
        _ paymentIntentId: String,
        _ moto: Bool,
        _ skipTipping: Bool
    ) throws

    func onStopCollectPaymentMethod(
        _ operationId: Int
    ) async throws -> Void

    func onProcessPayment(
        _ paymentIntentId: String
    ) async throws -> PaymentIntentApi

    func onStartReadReusableCard(
        _ result: Result<PaymentMethodApi>,
        _ operationId: Int,
        _ customer: String?,
        _ metadata: [String: String]?
    ) throws

    func onStopReadReusableCard(
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
        channel = FlutterEventChannel(name: "StripeTerminalPlatform#discoverReaders", binaryMessenger: binaryMessenger)
    }

    func setHandler(
        _ onListen: @escaping (_ sink: ControllerSink<[ReaderApi]>, _ discoveryMethod: DiscoveryMethodApi, _ simulated: Bool, _ locationId: String?) -> FlutterError?,
        _ onCancel: @escaping (_ discoveryMethod: DiscoveryMethodApi, _ simulated: Bool, _ locationId: String?) -> FlutterError?
    ) {
        channel.setStreamHandler(ControllerHandler({ arguments, events in
            let args = arguments as! [Any?]
            let sink = ControllerSink<[ReaderApi]>(events) { $0.map { $0.serialize() } }
            return onListen(sink, DiscoveryMethodApi(rawValue: args[0] as! Int)!, args[1] as! Bool, args[2] as? String)
        }, { arguments in
            let args = arguments as! [Any?]
            return onCancel(DiscoveryMethodApi(rawValue: args[0] as! Int)!, args[1] as! Bool, args[2] as? String)
        }))
    }

    func removeHandler() { channel.setStreamHandler(nil) }
}

private var channelStripeTerminalPlatformApi: FlutterMethodChannel? = nil

func setStripeTerminalPlatformApiHandler(
    _ binaryMessenger: FlutterBinaryMessenger,
    _ hostApi: StripeTerminalPlatformApi
) {
    channelStripeTerminalPlatformApi = FlutterMethodChannel(name: "StripeTerminalPlatform", binaryMessenger: binaryMessenger)
    channelStripeTerminalPlatformApi!.setMethodCallHandler { call, result in
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
            case "init":
                runAsync {
                    try await hostApi.onInit()
                    return nil
                }
            case "connectionStatus":
                runAsync {
                    let res = try await hostApi.onConnectionStatus()
                    return res.rawValue
                }
            case "supportsReadersOfType":
                let res = try hostApi.onSupportsReadersOfType(DeviceTypeApi(rawValue: args[0] as! Int)!, DiscoveryMethodApi(rawValue: args[1] as! Int)!, args[2] as! Bool)
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
            case "connectedReader":
                runAsync {
                    let res = try await hostApi.onConnectedReader()
                    return res?.serialize()
                }
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
                runAsync {
                    try await hostApi.onInstallAvailableUpdate()
                    return nil
                }
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
            case "retrievePaymentIntent":
                runAsync {
                    let res = try await hostApi.onRetrievePaymentIntent(args[0] as! String)
                    return res.serialize()
                }
            case "startCollectPaymentMethod":
                let res = Result<PaymentIntentApi>(result) { $0.serialize() }
                try hostApi.onStartCollectPaymentMethod(res, args[0] as! Int, args[1] as! String, args[2] as! Bool, args[3] as! Bool)
            case "stopCollectPaymentMethod":
                runAsync {
                    try await hostApi.onStopCollectPaymentMethod(args[0] as! Int)
                    return nil
                }
            case "processPayment":
                runAsync {
                    let res = try await hostApi.onProcessPayment(args[0] as! String)
                    return res.serialize()
                }
            case "startReadReusableCard":
                let res = Result<PaymentMethodApi>(result) { $0.serialize() }
                try hostApi.onStartReadReusableCard(res, args[0] as! Int, args[1] as? String, args[2] != nil ? Dictionary(uniqueKeysWithValues: (args[2] as! [AnyHashable?: Any?]).map { k, v in (k as! String, v as! String) }) : nil)
            case "stopReadReusableCard":
                runAsync {
                    try await hostApi.onStopReadReusableCard(args[0] as! Int)
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
            result(FlutterError(code: error.code, message: error.message, details: error.details))
        } catch {
            result(FlutterError(code: "", message: error.localizedDescription, details: nil))
        }
    }
}

func removeStripeTerminalPlatformApiHandler() {
    channelStripeTerminalPlatformApi?.setMethodCallHandler(nil)
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
            channel.invokeMethod("_onRequestConnectionToken", arguments: []) { result in
                if let result = result as? FlutterError {
                    continuation.resume(throwing: PlatformError(result.code, result.message, result.details))
                } else {
                    continuation.resume(returning: result as! String)
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

    func readerReconnectFailed() {
        channel.invokeMethod("_onReaderReconnectFailed", arguments: [])
    }

    func readerReconnectStarted() {
        channel.invokeMethod("_onReaderReconnectStarted", arguments: [])
    }

    func readerReconnectSucceeded() {
        channel.invokeMethod("_onReaderReconnectSucceeded", arguments: [])
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

enum BatteryStatusApi: Int {
    case critical
    case low
    case nominal
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
    let fingerprint: String?
    let funding: CardFundingTypeApi?
    let last4: String?

    func serialize() -> [Any?] {
        return [
            brand?.rawValue,
            country,
            expMonth,
            expYear,
            fingerprint,
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

enum DiscoveryMethodApi: Int {
    case bluetoothScan
    case bluetoothProximity
    case internet
    case localMobile
    case handOff
    case embedded
    case usb
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
    let metadata: [String: String]
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
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
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

struct PaymentMethodApi {
    let id: String
    let cardDetails: CardDetailsApi?
    let customer: String?
    let livemode: Bool
    let metadata: [String: String]

    func serialize() -> [Any?] {
        return [
            id,
            cardDetails?.serialize(),
            customer,
            livemode,
            metadata != nil ? Dictionary(uniqueKeysWithValues: metadata.map { k, v in (k, v) }) : nil,
        ]
    }
}

enum PaymentStatusApi: Int {
    case notReady
    case ready
    case waitingForInput
    case processing
}

struct ReaderApi {
    let locationStatus: LocationStatusApi?
    let batteryLevel: Double
    let deviceType: DeviceTypeApi?
    let simulated: Bool
    let availableUpdate: Bool
    let locationId: String?
    let serialNumber: String
    let label: String?

    func serialize() -> [Any?] {
        return [
            locationStatus?.rawValue,
            batteryLevel,
            deviceType?.rawValue,
            simulated,
            availableUpdate,
            locationId,
            serialNumber,
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
            requiredAt.timeIntervalSince1970 * 1000,
            settingsVersion,
            timeEstimate.rawValue,
            version,
        ]
    }
}

struct TerminalExceptionApi {
    let rawCode: String
    let message: String?
    let details: String?

    func serialize() -> [Any?] {
        return [
            rawCode,
            message,
            details,
        ]
    }
}

enum TerminalExceptionCodeApi: String {
    case paymentIntentNotRetrieved
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

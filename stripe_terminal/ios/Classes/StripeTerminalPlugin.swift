
import Flutter
import UIKit

public class StripeTerminalPlugin: NSObject, FlutterPlugin, StripeTerminalHostApi {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let api = StripeTerminalFlutterApi(registrar.messenger())
        let instance = StripeTerminalPlugin(api)
        setupStripeTerminalApi(registrar.messenger(), instance)
    }

    private let api: StripeTerminalFlutterApi

    init(_ api: StripeTerminalFlutterApi) {
        self.api = api
    }

    func onConnectBluetoothReader(result _: Result<StripeReaderApi>, readerSerialNumber _: String, locationId _: String?) {}
}

func setupStripeTerminalApi(_ binaryMessenger: FlutterBinaryMessenger, _ api: StripeTerminalHostApi) {
    let channel = FlutterMethodChannel(name: "stripe_terminal", binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { call, result in
        guard let args = call.arguments as? [Any?] else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }

        switch call.method {
        case "connectBluetoothReader":
            let res = Result<StripeReaderApi>(result: result) { $0.serialize() }
            api.onConnectBluetoothReader(result: res, readerSerialNumber: args[0] as! String, locationId: args[1] as? String)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

enum PlatformException {
    static func of(_ code: String, _ message: String?, _ details: Any?) -> FlutterError {
        return FlutterError(code: code, message: message, details: details)
    }
}

// class Result<T> {
//    private let result: FlutterResult
//    private let serializer: (T) -> Any?
//
//    init(result: @escaping FlutterResult, serializer: @escaping (T) -> Any?) {
//        self.result = result
//        self.serializer = serializer
//    }
//
//    func success(_ data: T) {
//        result(serializer(data))
//    }
//
//    func error(_ errorCode: String, _ errorMessage: String, _ errorDetails: Any?) {
//        result(FlutterError(code: errorCode, message: errorMessage, details: errorDetails))
//    }
// }

class StripeTerminalFlutterApi {
    private let channel: FlutterMethodChannel

    init(_ binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "stripe_terminal", binaryMessenger: binaryMessenger)
    }

    func requestConnectionToken() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            channel.invokeMethod("_onRequestConnectionToken", arguments: nil) { result in
                if let resultString = result as? String {
                    continuation.resume(returning: resultString)
                } else {
                    let unknownError = NSError(domain: "com.example.app", code: -1, userInfo: nil)
                    continuation.resume(throwing: unknownError)
                }
            }
        }
    }
}

// protocol StripeTerminalHostApi {
//    func onConnectBluetoothReader(result: Result<StripeReaderApi>, readerSerialNumber: String, locationId: String?);
// }
//
// class StripeReaderApi {
//    let locationStatus: LocationStatusApi
//    let batteryLevel: Double
//    let deviceType: DeviceTypeApi
//    let simulated: Bool
//    let availableUpdate: Bool
//    let locationId: String?
//    let serialNumber: String
//    let label: String?
//
//    init(locationStatus: LocationStatusApi, batteryLevel: Double, deviceType: DeviceTypeApi, simulated: Bool, availableUpdate: Bool, locationId: String?, serialNumber: String, label: String?) {
//        self.locationStatus = locationStatus
//        self.batteryLevel = batteryLevel
//        self.deviceType = deviceType
//        self.simulated = simulated
//        self.availableUpdate = availableUpdate
//        self.locationId = locationId
//        self.serialNumber = serialNumber
//        self.label = label
//    }
//
//    func serialize() -> [Any?] {
//        return [
//            locationStatus.rawValue,
//            batteryLevel,
//            deviceType.rawValue,
//            simulated,
//            availableUpdate,
//            locationId,
//            serialNumber,
//            label,
//        ]
//    }
//
//    static func deserialize(_ serialized: [Any?]) -> StripeReaderApi {
//        return StripeReaderApi(
//            locationStatus: LocationStatusApi(rawValue: serialized[0] as! Int)!,
//            batteryLevel: serialized[1] as! Double,
//            deviceType: DeviceTypeApi(rawValue: serialized[2] as! Int)!,
//            simulated: serialized[3] as! Bool,
//            availableUpdate: serialized[4] as! Bool,
//            locationId: serialized[5] as? String,
//            serialNumber: serialized[6] as! String,
//            label: serialized[7] as? String
//        )
//    }
// }
//
// enum LocationStatusApi: Int {
//    case UNKNOWN, SET, NOT_SET
// }
//
// enum DeviceTypeApi: Int {
//    case CHIPPER1_X, CHIPPER2_X, STRIPE_M2, COTS_DEVICE, VERIFONE_P400, WISE_CUBE, WISEPAD3, WISEPAD3S, WISEPOS_E, WISEPOS_E_DEVKIT, ETNA, STRIPE_S700, STRIPE_S700_DEVKIT, UNKNOWN
// }


import Flutter
import UIKit

public class StripeTerminalPlugin: StripeTerminalApi, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "stripe_terminal", binaryMessenger: registrar.messenger())
    let instance = StripeTerminalPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

class PlatformException: Error {
    let code: String
    let details: Any?

    init(code: String, message: String?, details: Any?) {
        super.init()
        self.code = code
        self.details = details
    }
}

struct Result<T> {
    private let result: FlutterResult
    private let serializer: (T) -> Any?

    func success(_ data: T) {
        result(serializer(data))
    }

    func error(_ errorCode: String, _ errorMessage: String, _ errorDetails: Any?) {
        result(FlutterError(code: errorCode, message: errorMessage, details: errorDetails))
    }
}

class StripeReaderApi {
    let locationStatus: LocationStatusApi
    let batteryLevel: Double
    let deviceType: DeviceTypeApi
    let simulated: Bool
    let availableUpdate: Bool
    let locationId: String?
    let serialNumber: String
    let label: String?

    init(locationStatus: LocationStatusApi, batteryLevel: Double, deviceType: DeviceTypeApi, simulated: Bool, availableUpdate: Bool, locationId: String?, serialNumber: String, label: String?) {
        self.locationStatus = locationStatus
        self.batteryLevel = batteryLevel
        self.deviceType = deviceType
        self.simulated = simulated
        self.availableUpdate = availableUpdate
        self.locationId = locationId
        self.serialNumber = serialNumber
        self.label = label
    }

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

    static func deserialize(_ serialized: [Any?]) -> StripeReaderApi {
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
    case UNKNOWN, SET, NOT_SET
}

enum DeviceTypeApi: Int {
    case CHIPPER1_X, CHIPPER2_X, STRIPE_M2, COTS_DEVICE, VERIFONE_P400, WISE_CUBE, WISEPAD3, WISEPAD3S, WISEPOS_E, WISEPOS_E_DEVKIT, ETNA, STRIPE_S700, STRIPE_S700_DEVKIT, UNKNOWN
}

class StripeTerminalApi: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "stripe_terminal", binaryMessenger: registrar.messenger())
        let instance = StripeTerminalApi()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [Any?] else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }

        switch call.method {
        case "connectBluetoothReader":
            let res = Result<StripeReaderApi>(result: result) { $0.serialize() }
            onConnectBluetoothReader(result: res, readerSerialNumber: args[0] as! String, locationId: args[1] as? String)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func onConnectBluetoothReader(result: Result<StripeReaderApi>, readerSerialNumber: String, locationId: String?) {
        // Implement your logic for connecting a Bluetooth reader here and use the 'result' object to send the result back to Flutter
        // For example:
        // let reader = StripeReaderApi(...)
        // result.success(reader)
    }

    func asyncTask<T>(_ task: @escaping (@escaping (T) -> Void, @escaping (Error) -> Void) -> Void) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            task(
                { result in
                    continuation.resume(returning: result)
                },
                { error in
                    continuation.resume(throwing: error)
                }
            )
        }
    }
    
    func requestConnectionToken() async throws -> String {
        return try await asyncTask { resolve, reject in
            channel.invokeMethod("_onRequestConnectionToken", arguments: nil) { (result: Any?, error: Error?) in
                if let error = error {
                    reject(error)
                } else if let resultString = result as? String {
                    resolve(resultString)
                } else {
                    let unknownError = NSError(domain: "com.example.app", code: -1, userInfo: nil)
                    reject(unknownError)
                }
            }
        }
    }
}

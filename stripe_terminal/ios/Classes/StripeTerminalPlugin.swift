
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

//class StripeTerminalFlutterApi {
//    private let channel: FlutterMethodChannel
//
//    init(_ binaryMessenger: FlutterBinaryMessenger) {
//        channel = FlutterMethodChannel(
//            name: "stripe_terminal",
//            binaryMessenger: binaryMessenger)
//    }
//
//    func requestConnectionToken() async throws -> String {
//        return try await withCheckedThrowingContinuation { continuation in
//            channel.invokeMethod("_onRequestConnectionToken", arguments: nil) { result in
//                if let result = result as? [AnyHashable: Any?] {
//                    continuation.resume(throwing: PlataformError(
//                        code: result["code"] as! String,
//                        message: result["message"] as? String,
//                        details: result["details"] as? String
//                    ))
//                } else {
//                    continuation.resume(returning: nil)
//                    
//                }
//            }
//        }
//    }
//}

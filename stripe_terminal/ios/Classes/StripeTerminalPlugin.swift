
import Flutter
import UIKit

public class StripeTerminalPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let api = StripeTerminalHandlersApi(registrar.messenger())
        let instance = StripeTerminalPlugin(api)
        // Todo: Implement this protocol StripeTerminalApi
        // setupStripeTerminalApi(registrar.messenger(), instance)
    }
 
    private let api: StripeTerminalHandlersApi

    init(_ api: StripeTerminalHandlersApi) {
        self.api = api
    }
}

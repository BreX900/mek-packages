import ProximityReader
import UIKit

class ProximityReaderPlugin : ProximityReaderPlatformApi {
    private let _viewController: UIViewController?
    
    init(_ viewController: UIViewController?) {
        self._viewController = viewController
    }
    
    func isAccountLinked(token: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        handleResult(completion) {
            guard #available(iOS 16.4, *) else {
                throw createUnsupportedOperatingSystem("16.4");
            }
            
            let paymentToken = PaymentCardReader.Token(rawValue: token)
            let reader = PaymentCardReader()
            return try await reader.isAccountLinked(using: paymentToken)
        }
    }
    
    func linkAccount(token: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            guard #available(iOS 15.4, *) else {
                throw createUnsupportedOperatingSystem("15.4");
            }
            
            let readerToken = PaymentCardReader.Token(rawValue: token)
            let reader = PaymentCardReader()
            try await reader.linkAccount(using: readerToken)
        }
    }
    
    func presentHowToTap(completion: @escaping (Result<Void, any Error>) -> Void) {
        handleResult(completion) {
            guard let viewController = self._viewController else {
                throw createPigeonError(".state_error", "UIViewController is nil");
            }
            
            guard #available(iOS 18.0, *) else {
                throw createUnsupportedOperatingSystem("18.0");
            }
            
            let discovery = ProximityReaderDiscovery()
            let content = try await discovery.content(for: .payment(.howToTap))
            try await discovery.presentContent(content, from: viewController)
        }
    }
}

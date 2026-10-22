import Foundation
import StripeTerminal

class TerminalDelegatePlugin: NSObject, ConnectionTokenProvider, TerminalDelegate {
    private let handlers: TerminalHandlersApi

    init(_ handlers: TerminalHandlersApi) {
        self.handlers = handlers
    }
    
    func fetchConnectionToken(_ completion: @escaping (String?, (any Error)?) -> Void) {
        DispatchQueue.main.async {
            self.handlers.requestConnectionToken { result in
                switch result {
                    case .success(let token):
                        completion(token, nil)

                    case .failure(let error):
                        completion(nil, error)
                    }
            }
        }
    }

    public func terminal(_: Terminal, didChangePaymentStatus status: PaymentStatus) {
        DispatchQueue.main.async {
            self.handlers.paymentStatusChange(
                status: status.toApi(),
                completion: logUnexpectedResultError
            )
        }
    }

    public func terminal(_: Terminal, didChangeConnectionStatus status: ConnectionStatus) {
        DispatchQueue.main.async {
            self.handlers.connectionStatusChange(
                status: status.toApi(),
                completion: logUnexpectedResultError
            )
        }
    }

}

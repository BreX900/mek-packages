import Foundation
import StripeTerminal

class TerminalDelegatePlugin: NSObject, ConnectionTokenProvider, TerminalDelegate {
    private let handlers: StripeTerminalHandlersApi

    init(_ handlers: StripeTerminalHandlersApi) {
        self.handlers = handlers
    }
    
    public func fetchConnectionToken() async throws -> String {
        return try await self.handlers.requestConnectionToken()
    }
    
    public func terminal(_: Terminal, didReportUnexpectedReaderDisconnect reader: Reader) {
        DispatchQueue.main.async {
            self.handlers.unexpectedReaderDisconnect(reader: reader.toApi())
        }
    }

    public func terminal(_: Terminal, didChangePaymentStatus status: PaymentStatus) {
        DispatchQueue.main.async {
            self.handlers.paymentStatusChange(paymentStatus: status.toApi())
        }
    }

    public func terminal(_: Terminal, didChangeConnectionStatus status: ConnectionStatus) {
        DispatchQueue.main.async {
            self.handlers.connectionStatusChange(connectionStatus: status.toApi())
        }
    }
}

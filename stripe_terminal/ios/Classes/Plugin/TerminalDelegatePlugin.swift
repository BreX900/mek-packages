import Foundation
import StripeTerminal

class TerminalDelegatePlugin: NSObject, TerminalDelegate {
    private let handlers: StripeTerminalHandlersApi

    init(_ handlers: StripeTerminalHandlersApi) {
        self.handlers = handlers
    }
    
    public func terminal(_: Terminal, didReportUnexpectedReaderDisconnect reader: Reader) {
        handlers.unexpectedReaderDisconnect(reader: reader.toApi())
    }

    public func terminal(_: Terminal, didChangePaymentStatus status: PaymentStatus) {
        handlers.paymentStatusChange(paymentStatus: status.toApi())
    }

    public func terminal(_: Terminal, didChangeConnectionStatus status: ConnectionStatus) {
        handlers.connectionStatusChange(connectionStatus: status.toApi())
    }
}

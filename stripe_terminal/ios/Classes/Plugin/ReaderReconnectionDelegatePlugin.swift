import Foundation
import StripeTerminal

class ReaderReconnectionDelegatePlugin: NSObject, ReconnectionDelegate {
    private let _handlers: StripeTerminalHandlersApi
    var cancelable: Cancelable?

    init(_ handlers: StripeTerminalHandlersApi) {
        self._handlers = handlers
    }

    func terminal(_ terminal: Terminal, didStartReaderReconnect cancelable: Cancelable) {
        self.cancelable = cancelable
        DispatchQueue.main.async {
            self._handlers.readerReconnectStarted()
        }
    }
    
    func terminalDidFailReaderReconnect(_ terminal: Terminal) {
        self.cancelable = nil
        DispatchQueue.main.async {
            self._handlers.readerReconnectFailed()
        }
    }
    
    func terminalDidSucceedReaderReconnect(_ terminal: Terminal) {
        self.cancelable = nil
        DispatchQueue.main.async {
            self._handlers.readerReconnectSucceeded()
        }
    }
}

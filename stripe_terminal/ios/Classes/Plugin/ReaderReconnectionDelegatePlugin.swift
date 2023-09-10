import Foundation
import StripeTerminal

class ReaderReconnectionDelegatePlugin: NSObject, ReconnectionDelegate {
    private let _handlers: StripeTerminalHandlersApi
    var cancelable: Cancelable?

    init(_ handlers: StripeTerminalHandlersApi) {
        self._handlers = handlers
    }

    func reader(_ reader: Reader, didStartReconnect cancelable: Cancelable) {
        self.cancelable = cancelable
        DispatchQueue.main.async {
            self._handlers.readerReconnectStarted(reader: reader.toApi())
        }
    }
    
    func readerDidFailReconnect(_ reader: Reader) {
        self.cancelable = nil
        DispatchQueue.main.async {
            self._handlers.readerReconnectFailed(reader: reader.toApi())
        }
    }
    
    func readerDidSucceedReconnect(_ reader: Reader) {
        self.cancelable = nil
        DispatchQueue.main.async {
            self._handlers.readerReconnectSucceeded(reader: reader.toApi())
        }
    }
}

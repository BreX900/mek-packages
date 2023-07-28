import Foundation
import StripeTerminal

class DiscoveryDelegatePlugin: NSObject, DiscoveryDelegate {
    let sink: ControllerSink<[StripeReaderApi]>
    
    init(_ sink: ControllerSink<[StripeReaderApi]>) {
        self.sink = sink
    }
    
    func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        print("Discovered readers!")
        sink.success(readers.map { $0.toApi() })
    }
}

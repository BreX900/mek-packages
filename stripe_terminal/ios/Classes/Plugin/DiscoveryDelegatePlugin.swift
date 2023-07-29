import Foundation
import StripeTerminal

class DiscoveryDelegatePlugin: NSObject, DiscoveryDelegate {
    let sink: ControllerSink<[ReaderApi]>
    
    init(_ sink: ControllerSink<[ReaderApi]>) {
        self.sink = sink
    }
    
    func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        print("Discovered readers!")
        sink.success(readers.map { $0.toApi() })
    }
}

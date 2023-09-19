import Foundation
import StripeTerminal
import Flutter

class DiscoveryDelegatePlugin: NSObject, DiscoveryDelegate {
    private var _sink: ControllerSink<[ReaderApi]>?
    private var _cancelable: Cancelable? = nil
    private var _readers: [Reader] = []
    
    var readers: [Reader] { get {
        return _readers
    } }
    
    func clear() {
        self._cancel()
        self._readers = []
    }
    
    func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        DispatchQueue.main.async {
            self._sink?.success(readers.map { $0.toApi() })
        }
    }

    func onListen(
        _ sink: ControllerSink<[ReaderApi]>,
        _ discoveryMethod: DiscoveryMethodApi,
        _ simulated: Bool,
        _ locationId: String?
    ) -> FlutterError? {
        self._cancel()
        
        let discoveryMethodHost = discoveryMethod.toHost()
        guard let discoveryMethodHost else {
            return FlutterError(code: "discoveryMethodNotSupported", message: nil, details: nil)
        }
         
        self._cancelable = Terminal.shared.discoverReaders(
            DiscoveryConfiguration(
                discoveryMethod: discoveryMethodHost,
                locationId: locationId,
                simulated: simulated
            ),
            delegate: self
        ) { error in
            self._cancelable = nil
            DispatchQueue.main.async {
                if let error = error {
                    let platformError = error.toApi()
                    self._sink?.error(platformError.code, platformError.message, platformError.details)
                }
                
                self._sink?.endOfStream()
                self._sink = nil
            }
        }
        self._sink = sink
        return nil
    }
    
    func onCancel(
        _ discoveryMethod: DiscoveryMethodApi,
        _ simulated: Bool,
        _ locationId: String?
    ) -> FlutterError? {
        self._cancel()
        return nil
    }
    
    private func _cancel() {
        self._sink = nil
        // Ignore error, the previous stream can no longer receive events
        self._cancelable?.cancel { error in }
        self._cancelable = nil
    }
}

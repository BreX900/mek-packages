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
            self._readers = readers
            self._sink?.success(readers.map { $0.toApi() })
        }
    }

    func onListen(
        _ sink: ControllerSink<[ReaderApi]>,
        _ configuration: DiscoveryConfigurationApi
    ) -> PlatformError? {
        self._cancel()
        
        let configurationHost = try! configuration.toHost()
        guard let configurationHost else {
            return createApiException(
                TerminalExceptionCodeApi.unknown,
                "DiscoveryConfiguration not supported"
            ).toPlatformError()
        }
         
        self._cancelable = Terminal.shared.discoverReaders(
            configurationHost,
            delegate: self
        ) { error in
            self._cancelable = nil
            DispatchQueue.main.async {
                if let error = error as? NSError {
                    let exception = error.toApi()
                    if (exception.code == TerminalExceptionCodeApi.canceled) {return}
                    self._sink?.error(exception.toPlatformError())
                }
                
                self._sink?.endOfStream()
                self._sink = nil
            }
        }
        self._sink = sink
        return nil
    }
    
    func onCancel(_ configuration: DiscoveryConfigurationApi) -> PlatformError? {
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

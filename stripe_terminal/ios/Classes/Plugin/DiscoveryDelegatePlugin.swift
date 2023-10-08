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
    ) -> FlutterError? {
        self._cancel()
        
        let configurationHost = try! configuration.toHost()
        guard let configurationHost else {
            let exception = createApiException(TerminalExceptionCodeApi.unknown, "DiscoveryConfiguration not supported").toPlatformError()
            return FlutterError(code: exception.code, message: exception.message, details: exception.details)
        }
         
        self._cancelable = Terminal.shared.discoverReaders(
            configurationHost,
            delegate: self
        ) { error in
            self._cancelable = nil
            DispatchQueue.main.async {
                if let error = error as? NSError {
                    let platformError = error.toPlatformError()
                    self._sink?.error(platformError.code, platformError.message, platformError.details)
                }
                
                self._sink?.endOfStream()
                self._sink = nil
            }
        }
        self._sink = sink
        return nil
    }
    
    func onCancel(_ configuration: DiscoveryConfigurationApi) -> FlutterError? {
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

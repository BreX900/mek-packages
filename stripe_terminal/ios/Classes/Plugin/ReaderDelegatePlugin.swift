import Foundation
import StripeTerminal

class ReaderDelegatePlugin: NSObject, ReaderDelegate, MobileReaderDelegate, InternetReaderDelegate, TapToPayReaderDelegate {
    
    private let _handlers: TerminalHandlersApi
    var cancellableUpdate: Cancelable?

    init(_ handlers: TerminalHandlersApi) {
        self._handlers = handlers
    }
    
    // ReaderDelegate methods
    
    func reader(_ reader: Reader, didDisconnect reason: DisconnectReason) {
        self._handlers.disconnect(reason: reason.toApi())
    }
    
    func reader(_ reader: Reader, didStartReconnect cancelable: Cancelable, disconnectReason: DisconnectReason) {
        self._handlers.readerReconnectStarted(reader: reader.toApi(), reason: disconnectReason.toApi())
    }
    
    func readerDidSucceedReconnect(_ reader: Reader) {
        self._handlers.readerReconnectSucceeded(reader: reader.toApi())
    }
    
    // MobileReaderDelegate methods
    
    func reader(_ reader: Reader, didReportAvailableUpdate update: ReaderSoftwareUpdate) {
        DispatchQueue.main.async {
            self._handlers.readerReportAvailableUpdate(update: update.toApi())
        }
    }
    
    func reader(_ reader: Reader, didStartInstallingUpdate update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        cancellableUpdate = cancelable
        DispatchQueue.main.async {
            self._handlers.readerStartInstallingUpdate(update: update.toApi())
        }
    }
    
    func reader(_ reader: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
        DispatchQueue.main.async {
            self._handlers.readerReportSoftwareUpdateProgress(progress: Double(progress))
        }
    }
    
    func reader(_ reader: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error: (any Error)?) {
        cancellableUpdate = nil
        let exception = (error as? NSError)?.toApi()
        DispatchQueue.main.async {
            self._handlers.readerFinishInstallingUpdate(
                update: update?.toApi(),
                exception: exception
            )
        }
    }
    
    func reader(_ reader: Reader, didRequestReaderInput inputOptions: ReaderInputOptions = []) {
        DispatchQueue.main.async {
            self._handlers.readerRequestInput(options: inputOptions.toApi())
        }
    }
    
    func reader(_ reader: Reader, didRequestReaderDisplayMessage displayMessage: ReaderDisplayMessage) {
        DispatchQueue.main.async {
            self._handlers.readerRequestDisplayMessage(message: displayMessage.toApi())
        }
    }
        
    func reader(_ reader: Reader, didReportReaderEvent event: ReaderEvent, info: Dictionary<AnyHashable, Any>?) {
        DispatchQueue.main.async {
            self._handlers.readerReportEvent(event: event.toApi())
        }
    }
    
    func reader(_ reader: Reader, didReportBatteryLevel batteryLevel: Float, status: BatteryStatus, isCharging: Bool) {
        DispatchQueue.main.async {
            self._handlers.readerBatteryLevelUpdate(
                batteryLevel: Double(batteryLevel),
                batteryStatus: status.toApi(),
                isCharging: isCharging
            )
        }
    }
    
    func readerDidReportLowBatteryWarning(_ reader: Reader) {
        DispatchQueue.main.async {
            self._handlers.readerReportLowBatteryWarning()
        }
    }
    
    // TapToPayReaderDelegate methods
    
    func tapToPayReader(_ reader: Reader, didStartInstallingUpdate update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        self.reader(reader, didStartInstallingUpdate: update, cancelable: cancelable)
    }
    
    func tapToPayReader(_ reader: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
        self.reader(reader, didReportReaderSoftwareUpdateProgress: progress)
    }
    
    func tapToPayReader(_ reader: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error: (any Error)?) {
        self.reader(reader, didFinishInstallingUpdate: update, error: error)
    }
    
    func tapToPayReader(_ reader: Reader, didRequestReaderInput inputOptions: ReaderInputOptions = []) {
        self.reader(reader, didRequestReaderInput: inputOptions)
    }
    
    func tapToPayReader(_ reader: Reader, didRequestReaderDisplayMessage displayMessage: ReaderDisplayMessage) {
        self.reader(reader, didRequestReaderDisplayMessage: displayMessage)
    }
    
    func tapToPayReaderDidAcceptTermsOfService(_ reader: Reader) {
        // TODO: Implement this method
    }
}

import Foundation
import StripeTerminal

class ReaderDelegatePlugin: NSObject, BluetoothReaderDelegate, LocalMobileReaderDelegate {
    private let _handlers: StripeTerminalHandlersApi
    var cancellableUpdate: Cancelable?

    init(_ handlers: StripeTerminalHandlersApi) {
        self._handlers = handlers
    }
    
    func reader(_ reader: Reader, didReportReaderEvent event: ReaderEvent, info: [AnyHashable : Any]?) {
        DispatchQueue.main.async {
            self._handlers.readerReportEvent(event: event.toApi())
        }
    }
    
    func localMobileReaderDidAcceptTermsOfService(_ reader: Reader) {
        // TODO: Implement this method
    }
    
    func reader(_ reader: Reader, didRequestReaderDisplayMessage message: ReaderDisplayMessage) {
        DispatchQueue.main.async {
            self._handlers.readerRequestDisplayMessage(message: message.toApi())
        }
    }

    func localMobileReader(_ reader: Reader, didRequestReaderDisplayMessage message: ReaderDisplayMessage) {
        self.reader(reader, didRequestReaderDisplayMessage: message)
    }
    
    func reader(_ reader: Reader, didRequestReaderInput options: ReaderInputOptions = []) {
        DispatchQueue.main.async {
            self._handlers.readerRequestInput(options: options.toApi())
        }
    }
    
    func localMobileReader(_ reader: Reader, didRequestReaderInput options: ReaderInputOptions = []) {
        self.reader(reader, didRequestReaderInput: options)
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

    func reader(_: Reader, didReportAvailableUpdate update: ReaderSoftwareUpdate) {
        DispatchQueue.main.async {
            self._handlers.readerReportAvailableUpdate(update: update.toApi())
        }
    }

    func reader(_: Reader, didStartInstallingUpdate update: ReaderSoftwareUpdate, cancelable c: Cancelable?) {
        cancellableUpdate = c
        DispatchQueue.main.async {
            self._handlers.readerStartInstallingUpdate(update: update.toApi())
        }
    }
    
    func localMobileReader(_ reader: Reader, didStartInstallingUpdate update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        self.reader(reader, didStartInstallingUpdate: update, cancelable: cancelable)
    }

    func reader(_: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
        DispatchQueue.main.async {
            self._handlers.readerReportSoftwareUpdateProgress(progress: Double(progress))
        }
    }
    
    func localMobileReader(_ reader: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
        self.reader(reader, didReportReaderSoftwareUpdateProgress: progress)
    }

    func reader(_: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error e: Error?) {
        cancellableUpdate = nil
        let exception = (e as? NSError)?.toApi()
        DispatchQueue.main.async {
            self._handlers.readerFinishInstallingUpdate(
                update: update?.toApi(),
                exception: exception
            )
        }
    }

    func localMobileReader(_ reader: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error: Error?) {
        self.reader(reader, didFinishInstallingUpdate: update, error: error)
    }
}

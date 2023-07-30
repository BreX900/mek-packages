import Foundation
import StripeTerminal

class ReaderDelegatePlugin: NSObject, BluetoothReaderDelegate, LocalMobileReaderDelegate {
    private let _handlers: StripeTerminalHandlersApi
    var cancellableUpdate: Cancelable?

    init(_ handlers: StripeTerminalHandlersApi) {
        self._handlers = handlers
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
        let exception = e?.toApi()
        DispatchQueue.main.async {
            self._handlers.readerFinishInstallingUpdate(
                update: update?.toApi(),
                exception: exception != nil
                ? TerminalExceptionApi(code: exception!.code, message: exception!.message, details: "\(exception!.details ?? "")")
                    : nil
            )
        }
    }

    func localMobileReader(_ reader: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error: Error?) {
        self.reader(reader, didFinishInstallingUpdate: update, error: error)
    }

    func reader(_: Reader, didRequestReaderInput _: ReaderInputOptions = []) {
        // TODO: Implement this method
    }

    func reader(_: Reader, didRequestReaderDisplayMessage _: ReaderDisplayMessage) {
        // TODO: Implement this method
    }

    func localMobileReader(_: Reader, didRequestReaderInput _: ReaderInputOptions = []) {
        // TODO: Implement this method
    }

    func localMobileReader(_: Reader, didRequestReaderDisplayMessage _: ReaderDisplayMessage) {
        // TODO: Implement this method
    }
}

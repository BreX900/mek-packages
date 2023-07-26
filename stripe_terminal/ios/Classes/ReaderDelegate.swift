import Foundation
import StripeTerminal

class ReaderDelegate: NSObject, BluetoothReaderDelegate, LocalMobileReaderDelegate {
    let handlers: StripeTerminalHandlersApi

    init(handlersApi: StripeTerminalHandlersApi) {
        handlers = handlersApi
    }

    func reader(_: Reader, didReportAvailableUpdate _: ReaderSoftwareUpdate) {
        DispatchQueue.main.async {
            self.handlers.availableUpdate(availableUpdate: true)
        }
    }

    func reader(_: Reader, didStartInstallingUpdate _: ReaderSoftwareUpdate, cancelable _: Cancelable?) {
        DispatchQueue.main.async {
            self.handlers.reportReaderSoftwareUpdateProgress(progress: 0.0)
        }
    }

    func reader(_: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
        DispatchQueue.main.async {
            self.handlers.reportReaderSoftwareUpdateProgress(progress: Double(progress))
        }
    }

    func reader(_: Reader, didFinishInstallingUpdate _: ReaderSoftwareUpdate?, error _: Error?) {
        DispatchQueue.main.async {
            self.handlers.reportReaderSoftwareUpdateProgress(progress: 1.0)
        }
    }

    func localMobileReader(_: Reader, didStartInstallingUpdate _: ReaderSoftwareUpdate, cancelable _: Cancelable?) {
        DispatchQueue.main.async {
            self.handlers.reportReaderSoftwareUpdateProgress(progress: 0.0)
        }
    }

    func localMobileReader(_: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
        DispatchQueue.main.async {
            self.handlers.reportReaderSoftwareUpdateProgress(progress: Double(progress))
        }
    }

    func localMobileReader(_: Reader, didFinishInstallingUpdate _: ReaderSoftwareUpdate?, error _: Error?) {
        DispatchQueue.main.async {
            self.handlers.reportReaderSoftwareUpdateProgress(progress: 1.0)
        }
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

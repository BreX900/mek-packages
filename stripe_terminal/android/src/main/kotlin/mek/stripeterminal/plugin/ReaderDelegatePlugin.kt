package mek.stripeterminal.plugin

import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.HandoffReaderListener
import com.stripe.stripeterminal.external.callable.InternetReaderListener
import com.stripe.stripeterminal.external.callable.MobileReaderListener
import com.stripe.stripeterminal.external.callable.TapToPayReaderListener
import com.stripe.stripeterminal.external.models.BatteryStatus
import com.stripe.stripeterminal.external.models.DisconnectReason
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.ReaderDisplayMessage
import com.stripe.stripeterminal.external.models.ReaderEvent
import com.stripe.stripeterminal.external.models.ReaderInputOptions
import com.stripe.stripeterminal.external.models.ReaderSoftwareUpdate
import com.stripe.stripeterminal.external.models.TerminalException
import mek.stripeterminal.api.TerminalHandlersApi
import mek.stripeterminal.mappings.toApi
import mek.stripeterminal.runOnMainThread
import com.stripe.stripeterminal.external.callable.Callback

class ReaderDelegatePlugin(private val _handlers: TerminalHandlersApi) :
    MobileReaderListener, HandoffReaderListener, InternetReaderListener, TapToPayReaderListener {
    private var cancelableReconnect: Cancelable? = null
    private var cancelableUpdate: Cancelable? = null

    fun cancelReconnect(callback: Callback) {
        cancelableReconnect?.cancel(callback)
        if (cancelableReconnect == null) callback.onSuccess();
        cancelableReconnect = null
    }

    fun cancelUpdate(callback: Callback) {
        cancelableUpdate?.cancel(callback)
        if (cancelableUpdate == null) callback.onSuccess();
        cancelableUpdate = null
    }

    // ReaderListenable

    override fun onReportReaderEvent(event: ReaderEvent) = runOnMainThread {
        _handlers.readerReportEvent(event.toApi())
    }

    // ReaderReconnectionListener

    override fun onReaderReconnectStarted(reader: Reader, cancelReconnect: Cancelable, reason: DisconnectReason) =
        runOnMainThread {
            this.cancelableReconnect = cancelReconnect
            _handlers.readerReconnectStarted(reader.toApi(), reason.toApi())
        }

    override fun onReaderReconnectFailed(reader: Reader) = runOnMainThread {
        cancelableReconnect = null
        _handlers.readerReconnectFailed(reader.toApi())
    }

    override fun onReaderReconnectSucceeded(reader: Reader) = runOnMainThread {
        cancelableReconnect = null
        _handlers.readerReconnectSucceeded(reader.toApi())
    }
    // ReaderDisconnectListener

    override fun onDisconnect(reason: DisconnectReason) = runOnMainThread {
        _handlers.disconnect(reason.toApi())
    }

    // MobileReaderListener

    override fun onRequestReaderDisplayMessage(message: ReaderDisplayMessage) = runOnMainThread {
        _handlers.readerRequestDisplayMessage(message.toApi())
    }

    override fun onRequestReaderInput(options: ReaderInputOptions) = runOnMainThread {
        _handlers.readerRequestInput(options.options.mapNotNull { it.toApi() })
    }

    override fun onBatteryLevelUpdate(
        batteryLevel: Float,
        batteryStatus: BatteryStatus,
        isCharging: Boolean
    ) = runOnMainThread {
        _handlers.readerBatteryLevelUpdate(
            batteryLevel = batteryLevel.toDouble(),
            batteryStatus = batteryStatus.toApi(),
            isCharging = isCharging
        )
    }

    override fun onReportLowBatteryWarning() = runOnMainThread {
        _handlers.readerReportLowBatteryWarning()
    }

    override fun onReportAvailableUpdate(update: ReaderSoftwareUpdate) = runOnMainThread {
        _handlers.readerReportAvailableUpdate(update.toApi())
    }

    override fun onStartInstallingUpdate(update: ReaderSoftwareUpdate, cancelable: Cancelable?) =
        runOnMainThread {
            this.cancelableUpdate = cancelable
            _handlers.readerStartInstallingUpdate(update.toApi())
        }

    override fun onReportReaderSoftwareUpdateProgress(progress: Float) = runOnMainThread {
        _handlers.readerReportSoftwareUpdateProgress(progress.toDouble())
    }

    override fun onFinishInstallingUpdate(update: ReaderSoftwareUpdate?, e: TerminalException?) =
        runOnMainThread {
            cancelableUpdate = null
            _handlers.readerFinishInstallingUpdate(update?.toApi(), e?.toApi())
        }
}

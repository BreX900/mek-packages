package mek.stripeterminal.plugin

import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.HandoffReaderListener
import com.stripe.stripeterminal.external.callable.ReaderListener
import com.stripe.stripeterminal.external.models.BatteryStatus
import com.stripe.stripeterminal.external.models.ReaderDisplayMessage
import com.stripe.stripeterminal.external.models.ReaderEvent
import com.stripe.stripeterminal.external.models.ReaderInputOptions
import com.stripe.stripeterminal.external.models.ReaderSoftwareUpdate
import com.stripe.stripeterminal.external.models.TerminalException
import mek.stripeterminal.api.TerminalHandlersApi
import mek.stripeterminal.api.toApi
import mek.stripeterminal.runOnMainThread

class ReaderDelegatePlugin(private val _handlers: TerminalHandlersApi) :
    ReaderListener, HandoffReaderListener {
    var cancelUpdate: Cancelable? = null

    override fun onReportReaderEvent(event: ReaderEvent) =
        runOnMainThread {
            _handlers.readerReportEvent(event.toApi())
        }

    override fun onRequestReaderDisplayMessage(message: ReaderDisplayMessage) =
        runOnMainThread {
            _handlers.readerRequestDisplayMessage(message.toApi())
        }

    override fun onRequestReaderInput(options: ReaderInputOptions) =
        runOnMainThread {
            _handlers.readerRequestInput(options.options.mapNotNull { it.toApi() })
        }

    override fun onBatteryLevelUpdate(
        batteryLevel: Float,
        batteryStatus: BatteryStatus,
        isCharging: Boolean,
    ) = runOnMainThread {
        _handlers.readerBatteryLevelUpdate(
            batteryLevel = batteryLevel.toDouble(),
            batteryStatus = batteryStatus.toApi(),
            isCharging = isCharging,
        )
    }

    override fun onReportLowBatteryWarning() =
        runOnMainThread {
            _handlers.readerReportLowBatteryWarning()
        }

    override fun onReportAvailableUpdate(update: ReaderSoftwareUpdate) =
        runOnMainThread {
            _handlers.readerReportAvailableUpdate(update.toApi())
        }

    override fun onStartInstallingUpdate(
        update: ReaderSoftwareUpdate,
        cancelable: Cancelable?,
    ) = runOnMainThread {
        this.cancelUpdate = cancelable
        _handlers.readerStartInstallingUpdate(update.toApi())
    }

    override fun onReportReaderSoftwareUpdateProgress(progress: Float) =
        runOnMainThread {
            _handlers.readerReportSoftwareUpdateProgress(progress.toDouble())
        }

    override fun onFinishInstallingUpdate(
        update: ReaderSoftwareUpdate?,
        e: TerminalException?,
    ) = runOnMainThread {
        cancelUpdate = null
        _handlers.readerFinishInstallingUpdate(update?.toApi(), e?.toApi())
    }
}

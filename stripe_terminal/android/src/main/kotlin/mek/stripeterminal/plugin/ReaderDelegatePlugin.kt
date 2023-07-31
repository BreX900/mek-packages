package mek.stripeterminal.plugin

import android.app.Activity
import com.stripe.stripeterminal.external.callable.BluetoothReaderListener
import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.HandoffReaderListener
import com.stripe.stripeterminal.external.callable.ReaderReconnectionListener
import com.stripe.stripeterminal.external.callable.UsbReaderListener
import com.stripe.stripeterminal.external.models.BatteryStatus
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.ReaderDisplayMessage
import com.stripe.stripeterminal.external.models.ReaderEvent
import com.stripe.stripeterminal.external.models.ReaderInputOptions
import com.stripe.stripeterminal.external.models.ReaderSoftwareUpdate
import com.stripe.stripeterminal.external.models.TerminalException
import mek.stripeterminal.api.StripeTerminalHandlersApi
import mek.stripeterminal.api.toApi

class ReaderDelegatePlugin(private val _handlers: StripeTerminalHandlersApi) :
    BluetoothReaderListener, HandoffReaderListener, UsbReaderListener {
    var activity: Activity? = null
    var cancelUpdate: Cancelable? = null

    override fun onReportReaderEvent(event: ReaderEvent) {
        activity?.runOnUiThread {
            _handlers.readerReportEvent(event.toApi())
        }
    }

    override fun onRequestReaderDisplayMessage(message: ReaderDisplayMessage) {
        activity?.runOnUiThread {
            _handlers.readerRequestDisplayMessage(message.toApi())
        }
    }

    override fun onRequestReaderInput(options: ReaderInputOptions) {
        activity?.runOnUiThread {
            _handlers.readerRequestInput(options.options.mapNotNull { it.toApi() })
        }
    }

    override fun onBatteryLevelUpdate(
        batteryLevel: Float,
        batteryStatus: BatteryStatus,
        isCharging: Boolean
    ) {
        activity?.runOnUiThread {
            _handlers.readerBatteryLevelUpdate(
                batteryLevel = batteryLevel.toDouble(),
                batteryStatus = batteryStatus.toApi(),
                isCharging = isCharging,
            )
        }
    }

    override fun onReportLowBatteryWarning() {
        activity?.runOnUiThread {
            _handlers.readerReportLowBatteryWarning()
        }
    }

    override fun onReportAvailableUpdate(update: ReaderSoftwareUpdate) {
        activity?.runOnUiThread {
            _handlers.readerReportAvailableUpdate(update.toApi())
        }
    }

    override fun onStartInstallingUpdate(update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        this.cancelUpdate = cancelable
        activity?.runOnUiThread {

            _handlers.readerStartInstallingUpdate(update.toApi())
        }
    }

    override fun onReportReaderSoftwareUpdateProgress(progress: Float) {
        activity?.runOnUiThread {
            _handlers.readerReportSoftwareUpdateProgress(progress.toDouble())
        }
    }

    override fun onFinishInstallingUpdate(update: ReaderSoftwareUpdate?, e: TerminalException?) {
        cancelUpdate = null
        activity?.runOnUiThread {
            _handlers.readerFinishInstallingUpdate(update?.toApi(), e?.toApi())
        }
    }
}

class ReaderReconnectionListenerPlugin(private val _handlers: StripeTerminalHandlersApi) :
    ReaderReconnectionListener {
    var activity: Activity? = null
    var cancelReconnect: Cancelable? = null

    override fun onReaderReconnectStarted(reader: Reader, cancelReconnect: Cancelable) {
        this.cancelReconnect = cancelReconnect;
        activity?.runOnUiThread {
            _handlers.readerReconnectStarted()
        }
    }

    override fun onReaderReconnectFailed(reader: Reader) {
        cancelReconnect = null
        activity?.runOnUiThread {
            _handlers.readerReconnectFailed()
        }
    }

    override fun onReaderReconnectSucceeded(reader: Reader) {
        cancelReconnect = null
        activity?.runOnUiThread {
            _handlers.readerReconnectSucceeded()
        }
    }
}
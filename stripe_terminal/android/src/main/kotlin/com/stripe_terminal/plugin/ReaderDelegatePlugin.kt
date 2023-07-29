package com.stripe_terminal.plugin

import com.stripe.stripeterminal.external.callable.BluetoothReaderListener
import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.models.ReaderSoftwareUpdate
import com.stripe.stripeterminal.external.models.TerminalException
import com.stripe_terminal.api.StripeTerminalHandlersApi

class ReaderDelegatePlugin(private val handlers: StripeTerminalHandlersApi): BluetoothReaderListener {
    override fun onReportAvailableUpdate(update: ReaderSoftwareUpdate) {
        handlers.availableUpdate(true)
    }

    override fun onStartInstallingUpdate(update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        handlers.reportReaderSoftwareUpdateProgress(0.0)
    }

    override fun onReportReaderSoftwareUpdateProgress(progress: Float) {
        handlers.reportReaderSoftwareUpdateProgress(progress.toDouble())
    }

    override fun onFinishInstallingUpdate(update: ReaderSoftwareUpdate?, e: TerminalException?) {
        handlers.reportReaderSoftwareUpdateProgress(1.0)
    }
}
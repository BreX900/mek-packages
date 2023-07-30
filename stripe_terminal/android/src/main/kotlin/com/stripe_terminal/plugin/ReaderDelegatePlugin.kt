package com.stripe_terminal.plugin

import com.stripe.stripeterminal.external.callable.BluetoothReaderListener
import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.HandoffReaderListener
import com.stripe.stripeterminal.external.callable.ReaderReconnectionListener
import com.stripe.stripeterminal.external.callable.UsbReaderListener
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.ReaderSoftwareUpdate
import com.stripe.stripeterminal.external.models.TerminalException
import com.stripe_terminal.api.StripeTerminalHandlersApi
import com.stripe_terminal.api.toApi

class ReaderDelegatePlugin(private val _handlers: StripeTerminalHandlersApi ) :
    BluetoothReaderListener, HandoffReaderListener, UsbReaderListener {
    var cancelUpdate: Cancelable? = null


    override fun onReportAvailableUpdate(update: ReaderSoftwareUpdate) {
        _handlers.readerReportAvailableUpdate(update.toApi())
    }

    override fun onStartInstallingUpdate(update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        this.cancelUpdate = cancelable
        _handlers.readerStartInstallingUpdate(update.toApi())
    }

    override fun onReportReaderSoftwareUpdateProgress(progress: Float) {
        _handlers.readerReportSoftwareUpdateProgress(progress.toDouble())
    }

    override fun onFinishInstallingUpdate(update: ReaderSoftwareUpdate?, e: TerminalException?) {
        cancelUpdate = null
        _handlers.readerFinishInstallingUpdate(update?.toApi(), e?.toApi())
    }
}

class ReaderReconnectionListenerPlugin(private val _handlers: StripeTerminalHandlersApi) :
    ReaderReconnectionListener {
    var cancelReconnect: Cancelable? = null

    override fun onReaderReconnectStarted(reader: Reader, cancelReconnect: Cancelable) {
        this.cancelReconnect = cancelReconnect;
        _handlers.readerReconnectStarted()
    }

    override fun onReaderReconnectFailed(reader: Reader) {
        cancelReconnect = null
        _handlers.readerReconnectFailed()
    }

    override fun onReaderReconnectSucceeded(reader: Reader) {
        cancelReconnect = null
        _handlers.readerReconnectSucceeded()
    }
}
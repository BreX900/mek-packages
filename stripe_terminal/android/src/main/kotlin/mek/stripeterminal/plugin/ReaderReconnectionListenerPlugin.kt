package mek.stripeterminal.plugin

import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.ReaderReconnectionListener
import com.stripe.stripeterminal.external.models.Reader
import mek.stripeterminal.api.TerminalHandlersApi
import mek.stripeterminal.api.toApi
import mek.stripeterminal.runOnMainThread

class ReaderReconnectionListenerPlugin(private val _handlers: TerminalHandlersApi) :
    ReaderReconnectionListener {
    var cancelReconnect: Cancelable? = null

    override fun onReaderReconnectStarted(
        reader: Reader,
        cancelReconnect: Cancelable,
    ) = runOnMainThread {
        this.cancelReconnect = cancelReconnect
        _handlers.readerReconnectStarted(reader.toApi())
    }

    override fun onReaderReconnectFailed(reader: Reader) =
        runOnMainThread {
            cancelReconnect = null
            _handlers.readerReconnectFailed(reader.toApi())
        }

    override fun onReaderReconnectSucceeded(reader: Reader) =
        runOnMainThread {
            cancelReconnect = null
            _handlers.readerReconnectSucceeded(reader.toApi())
        }
}

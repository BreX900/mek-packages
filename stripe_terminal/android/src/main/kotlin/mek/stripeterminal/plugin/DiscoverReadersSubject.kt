package mek.stripeterminal.plugin

import android.annotation.SuppressLint
import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.external.callable.Callback
import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.DiscoveryListener
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.TerminalException
import mek.stripeterminal.EmptyCallback
import mek.stripeterminal.api.ControllerSink
import mek.stripeterminal.api.DiscoveryConfigurationApi
import mek.stripeterminal.api.ReaderApi
import mek.stripeterminal.api.toApi
import mek.stripeterminal.api.toHost
import mek.stripeterminal.runOnMainThread

class DiscoverReadersSubject {
    private var _cancelable: Cancelable? = null
    private var _readers: List<Reader> = arrayListOf()

    val readers: List<Reader> get() = _readers

    fun clear() {
        cancel()
        _readers = arrayListOf()
    }

    @SuppressLint("MissingPermission")
    fun onListen(sink: ControllerSink<List<ReaderApi>>, configuration: DiscoveryConfigurationApi) {
        val hostConfiguration = configuration.toHost()
        if (hostConfiguration == null) {
            sink.error("", "Discovery method not supported", null)
            sink.endOfStream()
            return
        }

        // Ignore error, the previous stream can no longer receive events
        cancel()

        _cancelable = Terminal.getInstance().discoverReaders(
            config = hostConfiguration,
            discoveryListener = object : DiscoveryListener {
                override fun onUpdateDiscoveredReaders(readers: List<Reader>) {
                    _readers = readers
                    runOnMainThread { sink.success(readers.map { it.toApi() }) }
                }
            },
            callback = object : TerminalErrorHandler(sink::error), Callback {
                override fun onFailure(e: TerminalException) = runOnMainThread {
                    if (_cancelable == null) return@runOnMainThread
                    _cancelable = null
                    super.onFailure(e)
                    sink.endOfStream()
                }

                override fun onSuccess() = runOnMainThread { sink.endOfStream() }
            },
        )
    }

    fun onCancel() = cancel()

    private fun cancel() {
        val cancelable = _cancelable
        _cancelable = null
        // Ignore error, flutter stream already closed
        cancelable?.cancel(EmptyCallback())
    }
}
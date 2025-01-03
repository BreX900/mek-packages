package mek.stripeterminal.plugin

import android.annotation.SuppressLint
import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.external.callable.Callback
import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.DiscoveryListener
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.TerminalErrorCode
import com.stripe.stripeterminal.external.models.TerminalException
import mek.stripeterminal.EmptyCallback
import mek.stripeterminal.api.ControllerSink
import mek.stripeterminal.api.DiscoveryConfigurationApi
import mek.stripeterminal.api.ReaderApi
import mek.stripeterminal.api.TerminalExceptionCodeApi
import mek.stripeterminal.createApiError
import mek.stripeterminal.mappings.toApi
import mek.stripeterminal.mappings.toHost
import mek.stripeterminal.mappings.toPlatformError
import mek.stripeterminal.runOnMainThread

class DiscoverReadersSubject {
    private var cancelable: Cancelable? = null
    private var _readers: List<Reader> = arrayListOf()

    val readers: List<Reader>
        get() = _readers

    fun clear() {
        cancel()
        _readers = arrayListOf()
    }

    @SuppressLint("MissingPermission")
    fun onListen(sink: ControllerSink<List<ReaderApi>>, configuration: DiscoveryConfigurationApi) {
        val hostConfiguration = configuration.toHost()
        if (hostConfiguration == null) {
            sink.error(
                createApiError(TerminalExceptionCodeApi.UNKNOWN, "Discovery method not supported")
                    .toPlatformError()
            )
            sink.endOfStream()
            return
        }

        // Ignore error, the previous stream can no longer receive events
        cancel()

        cancelable =
            Terminal.getInstance()
                .discoverReaders(
                    config = hostConfiguration,
                    discoveryListener =
                    object : DiscoveryListener {
                        override fun onUpdateDiscoveredReaders(readers: List<Reader>) {
                            _readers = readers
                            runOnMainThread { sink.success(readers.map { it.toApi() }) }
                        }
                    },
                    callback =
                    object : Callback {
                        override fun onFailure(e: TerminalException) = runOnMainThread {
                            if (e.errorCode == TerminalErrorCode.CANCELED) {
                                return@runOnMainThread
                            }

                            cancelable = null
                            sink.error(e.toPlatformError())
                            sink.endOfStream()
                        }

                        override fun onSuccess() = runOnMainThread { sink.endOfStream() }
                    }
                )
    }

    fun onCancel() = cancel()

    private fun cancel() {
        val cancelable = cancelable
        this.cancelable = null
        // Ignore error, flutter stream already closed
        cancelable?.cancel(EmptyCallback())
    }
}

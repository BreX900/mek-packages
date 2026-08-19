package mek.stripeterminal.plugin

import DiscoverReadersStreamHandler
import android.annotation.SuppressLint
import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.external.callable.Callback
import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.DiscoveryListener
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.TerminalErrorCode
import com.stripe.stripeterminal.external.models.TerminalException
import mek.stripeterminal.EmptyCallback
import PigeonEventSink
import ReaderApi
import TerminalExceptionCodeApi
import com.stripe.stripeterminal.external.models.DiscoveryConfiguration
import mek.stripeterminal.addError
import mek.stripeterminal.mappings.createApiException
import mek.stripeterminal.mappings.createError
import mek.stripeterminal.mappings.mapExceptionToApi
import mek.stripeterminal.mappings.toApi
import mek.stripeterminal.runOnMainThread

class DiscoverReadersStreamController : DiscoverReadersStreamHandler() {
    private var cancelable: Cancelable? = null
    private var _readers: List<Reader> = arrayListOf()
    var configuration: DiscoveryConfiguration? = null

    val readers: List<Reader>
        get() = _readers

    fun clear() {
        cancel()
        _readers = arrayListOf()
    }

    @SuppressLint("MissingPermission")
    override fun onListen(p0: Any?, sink: PigeonEventSink<List<ReaderApi>>) {
        val configuration = this.configuration
        if (configuration == null) {
            val exception = createApiException(TerminalExceptionCodeApi.UNKNOWN, "Discovery method not supported");
            sink.addError(createError(exception))
            sink.endOfStream()
            return
        }

        // Ignore events, stream is closed by Flutter
        cancel()

        cancelable =
            Terminal.getInstance()
                .discoverReaders(
                    config = configuration,
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
                                    // Ignore events, stream is closed by Flutter
                                    return@runOnMainThread
                                }

                                sink.addError(createError(mapExceptionToApi(e)))
                                sink.endOfStream()
                                clean()
                            }

                            override fun onSuccess() = runOnMainThread { sink.endOfStream() }
                        }
                )
    }

    override fun onCancel(p0: Any?) = cancel()

    private fun cancel() {
        val cancelable = cancelable
        clean()
        // Ignore error, flutter stream already closed
        cancelable?.cancel(EmptyCallback())
    }

    private fun clean() {
        this.cancelable = null
        this.configuration = null
    }
}

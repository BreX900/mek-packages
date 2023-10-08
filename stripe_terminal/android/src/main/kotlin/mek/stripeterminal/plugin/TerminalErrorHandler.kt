package mek.stripeterminal.plugin

import com.stripe.stripeterminal.external.callable.ErrorCallback
import com.stripe.stripeterminal.external.models.TerminalException
import mek.stripeterminal.api.toApi
import mek.stripeterminal.runOnMainThread

abstract class TerminalErrorHandler(private val handler: (c: String, m: String?, d: Any?) -> Unit) : ErrorCallback {
    override fun onFailure(e: TerminalException) {
        val exception = e.toApi()
        runOnMainThread { handler(exception.rawCode, exception.message, exception.details) }
    }
}
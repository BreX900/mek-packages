package mek.stripeterminal.plugin

import com.stripe.stripeterminal.external.callable.ErrorCallback
import com.stripe.stripeterminal.external.models.TerminalException
import mek.stripeterminal.api.PlatformError
import mek.stripeterminal.mappings.toPlatformError
import mek.stripeterminal.runOnMainThread

abstract class TerminalErrorHandler(private val handler: (error: PlatformError) -> Unit) :
    ErrorCallback {
    override fun onFailure(e: TerminalException) {
        val error = e.toPlatformError()
        runOnMainThread { handler(error) }
    }
}

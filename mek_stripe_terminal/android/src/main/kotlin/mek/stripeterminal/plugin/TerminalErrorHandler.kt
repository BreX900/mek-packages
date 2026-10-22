package mek.stripeterminal.plugin

import com.stripe.stripeterminal.external.callable.ErrorCallback
import com.stripe.stripeterminal.external.models.TerminalException
import mek.stripeterminal.mappings.mapExceptionToError
import mek.stripeterminal.mappings.mapExceptionToApi
import mek.stripeterminal.runOnMainThread

abstract class TerminalErrorHandler<T>(private val callback: (result: Result<T>) -> Unit) :
    ErrorCallback {
    override fun onFailure(e: TerminalException) {
        val error = mapExceptionToError(mapExceptionToApi(e))
        runOnMainThread { callback(Result.failure(error)) }
    }
}

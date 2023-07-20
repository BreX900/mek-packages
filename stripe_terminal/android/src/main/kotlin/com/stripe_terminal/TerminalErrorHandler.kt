package com.stripe_terminal

import com.stripe.stripeterminal.external.callable.ErrorCallback
import com.stripe.stripeterminal.external.models.TerminalException
import com.stripe_terminal.api.Result

abstract class TerminalErrorHandler(private val handler: (c: String, m: String, d: String) -> Unit) : ErrorCallback {
    override fun onFailure(e: TerminalException) {
        var message = "${e.errorCode}: ${e.errorMessage}";
        if (e.message != null) message += "\nMessage: ${e.message}"
        if (e.paymentIntent != null) message += "\nPaymentIntent: ${e.paymentIntent}"
        if (e.apiError != null) message += "\nApiError: ${e.apiError}"
        if (e.cause != null) message += "\nCause: ${e.cause}"
        handler(e.errorCode.name, message, e.stackTraceToString())
    }
}
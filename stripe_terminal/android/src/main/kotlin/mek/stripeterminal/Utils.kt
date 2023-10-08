package mek.stripeterminal

import android.os.Handler
import android.os.Looper
import mek.stripeterminal.api.TerminalExceptionApi
import mek.stripeterminal.api.TerminalExceptionCodeApi

private val mainThread = Handler(Looper.getMainLooper())

fun runOnMainThread(body: () -> Unit) {
    mainThread.post(body)
}

fun microsecondsToSeconds(value: Long): Int {
    return (value * 1000000).toInt()
}

fun createApiException(code: TerminalExceptionCodeApi, message: String? = null): TerminalExceptionApi {
    return TerminalExceptionApi(
        code = code,
        message = message ?: "",
        stackTrace = null,
        paymentIntent = null,
        apiError = null,
    )
}
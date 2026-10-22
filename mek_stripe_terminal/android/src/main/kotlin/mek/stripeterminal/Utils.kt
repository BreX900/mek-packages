package mek.stripeterminal

import FlutterError
import PigeonEventSink
import TerminalExceptionApi
import TerminalExceptionCodeApi
import android.os.Handler
import android.os.Looper

private val mainThread = Handler(Looper.getMainLooper())

fun runOnMainThread(body: () -> Unit) {
    mainThread.post(body)
}

fun <T>PigeonEventSink<T>.addError(error: FlutterError) {
    this.error(error.code, error.message, error.details)
}
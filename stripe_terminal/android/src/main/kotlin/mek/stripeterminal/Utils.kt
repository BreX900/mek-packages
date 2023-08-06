package mek.stripeterminal

import android.os.Handler
import android.os.Looper

private val mainThread = Handler(Looper.getMainLooper())

fun runOnMainThread(body: () -> Unit) {
    mainThread.post(body)
}

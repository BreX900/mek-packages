package mek.stripeterminal.plugin

import TerminalHandlersApi
import com.stripe.stripeterminal.external.callable.ConnectionTokenCallback
import com.stripe.stripeterminal.external.callable.ConnectionTokenProvider
import com.stripe.stripeterminal.external.callable.TerminalListener
import com.stripe.stripeterminal.external.models.ConnectionStatus
import com.stripe.stripeterminal.external.models.ConnectionTokenException
import com.stripe.stripeterminal.external.models.PaymentStatus
import mek.stripeterminal.mappings.toApi
import mek.stripeterminal.runOnMainThread

class TerminalDelegatePlugin(private val _handlers: TerminalHandlersApi) :
    ConnectionTokenProvider, TerminalListener {
    override fun fetchConnectionToken(callback: ConnectionTokenCallback) = runOnMainThread {
        _handlers.requestConnectionToken{ result -> result.fold(
            onSuccess = { token ->
                callback.onSuccess(token)
            },
            onFailure = { failure ->
                callback.onFailure(ConnectionTokenException(failure.message!!, failure.cause)) }
            );
        }
    }

    // region Terminal listeners
    override fun onConnectionStatusChange(status: ConnectionStatus) = runOnMainThread {
        _handlers.connectionStatusChange(status.toApi()) {}
    }

    override fun onPaymentStatusChange(status: PaymentStatus) = runOnMainThread {
        _handlers.paymentStatusChange(status.toApi()) {}
    }
    // endregion
}

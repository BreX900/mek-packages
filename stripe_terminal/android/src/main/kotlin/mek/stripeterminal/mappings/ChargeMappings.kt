package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.Charge
import com.stripe.stripeterminal.external.models.PaymentMethodDetails
import mek.stripeterminal.api.ChargeApi
import mek.stripeterminal.api.ChargeStatusApi
import mek.stripeterminal.api.PaymentMethodDetailsApi
import mek.stripeterminal.api.toApi
import mek.stripeterminal.toHashMap

fun Charge.toApi(): ChargeApi {
    return ChargeApi(
        amount = amount,
        currency = currency!!,
        status =
            when (status) {
                "pending" -> ChargeStatusApi.PENDING
                "failed" -> ChargeStatusApi.FAILED
                "succeeded" -> ChargeStatusApi.SUCCEEDED
                else -> throw Error("Unsupported $status")
            },
        paymentMethodDetails = paymentMethodDetails?.toApi(),
        description = description!!,
        id = id,
        metadata = metadata?.toHashMap() ?: hashMapOf(),
        statementDescriptorSuffix = statementDescriptorSuffix,
        calculatedStatementDescriptor = calculatedStatementDescriptor,
        authorizationCode = authorizationCode,
    )
}

fun PaymentMethodDetails.toApi(): PaymentMethodDetailsApi {
    return PaymentMethodDetailsApi(
        cardPresent = cardPresentDetails?.toApi(),
        interacPresent = interacPresentDetails?.toApi(),
    )
}

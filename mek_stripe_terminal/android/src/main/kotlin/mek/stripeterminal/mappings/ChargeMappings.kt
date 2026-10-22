package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.Charge
import com.stripe.stripeterminal.external.models.PaymentMethodDetails
import ChargeApi
import ChargeStatusApi
import PaymentMethodDetailsApi
import mek.stripeterminal.toHashMap

fun Charge.toApi(): ChargeApi {
    return ChargeApi(
        amount = amount,
        currency = currency!!,
        status = when (status) {
            "pending" -> ChargeStatusApi.PENDING
            "failed" -> ChargeStatusApi.FAILED
            "succeeded" -> ChargeStatusApi.SUCCEEDED
            else -> throw Error("Unsupported $status")
        },
        paymentMethodDetails = paymentMethodDetails?.toApi(),
        descriptionX = description,
        id = id,
        metadata = metadata?.toHashMap() ?: hashMapOf(),
        statementDescriptorSuffix = statementDescriptorSuffix,
        calculatedStatementDescriptor = calculatedStatementDescriptor,
        authorizationCode = authorizationCode
    )
}

fun PaymentMethodDetails.toApi(): PaymentMethodDetailsApi {
    return PaymentMethodDetailsApi(
        cardPresent = cardPresentDetails?.toApi(),
        interactPresent = interacPresentDetails?.toApi()
    )
}

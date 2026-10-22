package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.PaymentMethod
import PaymentMethodApi
import mek.stripeterminal.toHashMap

fun PaymentMethod.toApi(): PaymentMethodApi {
    return PaymentMethodApi(
        id = id,
        card = cardDetails?.toApi(),
        cardPresent = cardPresentDetails?.toApi(),
        interactPresent = interacPresentDetails?.toApi(),
        customerId = customer,
        metadata = metadata?.toHashMap() ?: hashMapOf()
    )
}

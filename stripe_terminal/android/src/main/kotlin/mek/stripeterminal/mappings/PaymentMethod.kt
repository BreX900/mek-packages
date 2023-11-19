package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.PaymentMethod
import mek.stripeterminal.api.PaymentMethodApi
import mek.stripeterminal.api.toApi
import mek.stripeterminal.toHashMap

fun PaymentMethod.toApi(): PaymentMethodApi {
    return PaymentMethodApi(
        id = id,
        card = cardDetails?.toApi(),
        cardPresent = cardPresentDetails?.toApi(),
        interacPresent = interacPresentDetails?.toApi(),
        customerId = customer,
        metadata = metadata?.toHashMap() ?: hashMapOf(),
    )
}

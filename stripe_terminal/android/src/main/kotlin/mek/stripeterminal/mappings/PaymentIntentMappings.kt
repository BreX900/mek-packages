package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.AmountDetails
import mek.stripeterminal.api.AmountDetailsApi

fun AmountDetails.toApi(): AmountDetailsApi {
    return AmountDetailsApi(
        tip = tip?.toApi(),
    )
}

package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.Tip
import mek.stripeterminal.api.TipApi

fun Tip.toApi(): TipApi {
    return TipApi(
        amount = amount,
    )
}

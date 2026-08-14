package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.Tip
import com.stripe.stripeterminal.external.models.TippingConfiguration
import mek.stripeterminal.api.TipApi
import mek.stripeterminal.api.TippingConfigurationApi

fun Tip.toApi(): TipApi {
    return TipApi(
        amount = amount
    )
}

// PARAMS

fun TippingConfigurationApi.toHost(): TippingConfiguration {
    return TippingConfiguration.Builder().setEligibleAmount(eligibleAmount).build()
}

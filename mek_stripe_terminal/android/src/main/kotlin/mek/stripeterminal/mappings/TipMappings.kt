package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.Tip
import com.stripe.stripeterminal.external.models.TippingConfiguration
import TipApi
import TippingConfigurationApi

fun Tip.toApi(): TipApi {
    return TipApi(
        amount = amount
    )
}

// PARAMS

fun TippingConfigurationApi.toHost(): TippingConfiguration {
    return TippingConfiguration.Builder().setEligibleAmount(eligibleAmount).build()
}

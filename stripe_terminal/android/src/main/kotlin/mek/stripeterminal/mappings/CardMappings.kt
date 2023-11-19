package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.CardDetails
import mek.stripeterminal.api.CardDetailsApi
import mek.stripeterminal.api.cardBrandToApi
import mek.stripeterminal.api.fundingToApi

fun CardDetails.toApi(): CardDetailsApi {
    return CardDetailsApi(
        brand = cardBrandToApi(brand),
        country = country,
        expMonth = expMonth.toLong(),
        expYear = expYear.toLong(),
        funding = fundingToApi(funding),
        last4 = last4,
    )
}

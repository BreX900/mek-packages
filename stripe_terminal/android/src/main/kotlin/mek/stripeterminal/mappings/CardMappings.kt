package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.CardDetails
import com.stripe.stripeterminal.external.models.CardNetworks
import com.stripe.stripeterminal.external.models.CardPresentCaptureMethod
import com.stripe.stripeterminal.external.models.CardPresentDetails
import com.stripe.stripeterminal.external.models.CardPresentParameters
import com.stripe.stripeterminal.external.models.CardPresentRoutingOptionParameters
import com.stripe.stripeterminal.external.models.IncrementalAuthorizationStatus
import com.stripe.stripeterminal.external.models.ReceiptDetails
import com.stripe.stripeterminal.external.models.RoutingPriority
import mek.stripeterminal.api.CardBrandApi
import mek.stripeterminal.api.CardDetailsApi
import mek.stripeterminal.api.CardFundingTypeApi
import mek.stripeterminal.api.CardNetworksApi
import mek.stripeterminal.api.CardPresentCaptureMethodApi
import mek.stripeterminal.api.CardPresentDetailsApi
import mek.stripeterminal.api.CardPresentParametersApi
import mek.stripeterminal.api.CardPresentRoutingApi
import mek.stripeterminal.api.IncrementalAuthorizationStatusApi
import mek.stripeterminal.api.ReceiptDetailsApi

fun CardDetails.toApi(): CardDetailsApi {
    return CardDetailsApi(
        brand = cardBrandToApi(brand),
        country = country,
        expMonth = expMonth.toLong(),
        expYear = expYear.toLong(),
        funding = fundingToApi(funding),
        last4 = last4
    )
}

fun cardBrandToApi(value: String?): CardBrandApi? {
    return when (value) {
        "amex" -> CardBrandApi.AMEX
        "diners" -> CardBrandApi.DINERS_CLUB
        "discover" -> CardBrandApi.DISCOVER
        "jcb" -> CardBrandApi.JCB
        "mastercard" -> CardBrandApi.MASTER_CARD
        "unionpay" -> CardBrandApi.UNION_PAY
        "visa" -> CardBrandApi.VISA
        "unknown" -> null
        else -> null
    }
}

fun fundingToApi(value: String?): CardFundingTypeApi? {
    return when (value) {
        "credit" -> CardFundingTypeApi.CREDIT
        "debit" -> CardFundingTypeApi.DEBIT
        "prepaid" -> CardFundingTypeApi.PREPAID
        "unknown" -> null
        else -> null
    }
}

fun CardPresentDetails.toApi(): CardPresentDetailsApi {
    return CardPresentDetailsApi(
        brand = cardBrandToApi(brand),
        country = country,
        expMonth = expMonth?.toLong() ?: 0L,
        expYear = expYear?.toLong() ?: 0L,
        funding = fundingToApi(funding),
        last4 = last4,
        cardholderName = cardholderName,
        generatedCard = generatedCard,
        receipt = receiptDetails?.toApi(),
        emvAuthData = emvAuthData,
        networks = networks?.toApi(),
        incrementalAuthorizationStatus = incrementalAuthorizationStatus.toApi()
    )
}

fun ReceiptDetails.toApi(): ReceiptDetailsApi {
    return ReceiptDetailsApi(
        accountType = accountType,
        applicationPreferredName = applicationPreferredName,
        authorizationCode = authorizationCode,
        authorizationResponseCode = authorizationResponseCode,
        applicationCryptogram = applicationCryptogram,
        dedicatedFileName = dedicatedFileName,
        transactionStatusInformation = tsi,
        terminalVerificationResults = tvr
    )
}

fun CardNetworks.toApi(): CardNetworksApi {
    return CardNetworksApi(
        available =
        available.mapNotNull { cardBrandToApi(it) },
        preferred = preferred
    )
}

fun IncrementalAuthorizationStatus.toApi(): IncrementalAuthorizationStatusApi? {
    return when (this) {
        IncrementalAuthorizationStatus.NOT_SUPPORTED -> IncrementalAuthorizationStatusApi.NOT_SUPPORTED
        IncrementalAuthorizationStatus.SUPPORTED -> IncrementalAuthorizationStatusApi.SUPPORTED
        IncrementalAuthorizationStatus.UNKNOWN -> null
    }
}

// PARAMS

fun CardPresentParametersApi.toHost(): CardPresentParameters {
    val b = CardPresentParameters.Builder()
    captureMethod?.let { b.setCaptureMethod(it.toHost()) }
    requestExtendedAuthorization?.let { b.setRequestExtendedAuthorization(it) }
    requestIncrementalAuthorizationSupport?.let { b.setRequestIncrementalAuthorizationSupport(it) }
    requestedPriority?.let { b.setRouting(CardPresentRoutingOptionParameters(it.toHost())) }
    return b.build()
}

fun CardPresentCaptureMethodApi.toHost(): CardPresentCaptureMethod {
    return when (this) {
        CardPresentCaptureMethodApi.MANUAL_PREFERRED -> CardPresentCaptureMethod.ManualPreferred
    }
}

fun CardPresentRoutingApi.toHost(): RoutingPriority {
    return when (this) {
        CardPresentRoutingApi.DOMESTIC -> RoutingPriority.DOMESTIC
        CardPresentRoutingApi.INTERNATIONAL -> RoutingPriority.INTERNATIONAL
    }
}

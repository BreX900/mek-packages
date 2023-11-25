package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.SetupAttempt
import com.stripe.stripeterminal.external.models.SetupAttemptStatus
import com.stripe.stripeterminal.external.models.SetupIntent
import com.stripe.stripeterminal.external.models.SetupIntentCardPresentDetails
import com.stripe.stripeterminal.external.models.SetupIntentPaymentMethodDetails
import com.stripe.stripeterminal.external.models.SetupIntentStatus
import com.stripe.stripeterminal.external.models.SetupIntentUsage
import mek.stripeterminal.api.SetupAttemptApi
import mek.stripeterminal.api.SetupAttemptCardPresentDetailsApi
import mek.stripeterminal.api.SetupAttemptPaymentMethodDetailsApi
import mek.stripeterminal.api.SetupAttemptStatusApi
import mek.stripeterminal.api.SetupIntentApi
import mek.stripeterminal.api.SetupIntentStatusApi
import mek.stripeterminal.api.SetupIntentUsageApi
import mek.stripeterminal.toHashMap

fun SetupIntent.toApi(): SetupIntentApi {
    return SetupIntentApi(
        id = id,
        created = created,
        customerId = customerId,
        metadata = metadata.toHashMap(),
        usage = usage!!.toApi(),
        status = status!!.toApi(),
        latestAttempt = latestAttempt?.toApi()
    )
}

fun SetupIntentUsage.toApi(): SetupIntentUsageApi {
    return when (this) {
        SetupIntentUsage.ON_SESSION -> SetupIntentUsageApi.ON_SESSION
        SetupIntentUsage.OFF_SESSION -> SetupIntentUsageApi.OFF_SESSION
    }
}

fun SetupIntentStatus.toApi(): SetupIntentStatusApi {
    return when (this) {
        SetupIntentStatus.REQUIRES_PAYMENT_METHOD -> SetupIntentStatusApi.REQUIRES_PAYMENT_METHOD
        SetupIntentStatus.REQUIRES_CONFIRMATION -> SetupIntentStatusApi.REQUIRES_CONFIRMATION
        SetupIntentStatus.REQUIRES_ACTION -> SetupIntentStatusApi.REQUIRES_ACTION
        SetupIntentStatus.PROCESSING -> SetupIntentStatusApi.PROCESSING
        SetupIntentStatus.SUCCEEDED -> SetupIntentStatusApi.SUCCEEDED
        SetupIntentStatus.CANCELLED -> SetupIntentStatusApi.CANCELLED
    }
}

fun SetupAttempt.toApi(): SetupAttemptApi {
    return SetupAttemptApi(
        id = id,
        applicationId = applicationId,
        created = created,
        customerId = customerId,
        onBehalfOf = onBehalfOfId,
        paymentMethodId = paymentMethodId,
        paymentMethodDetails = paymentMethodDetails.toApi(),
        setupIntentId = setupIntentId!!,
        status = status.toApi()
    )
}

fun SetupAttemptStatus.toApi(): SetupAttemptStatusApi {
    return when (this) {
        SetupAttemptStatus.REQUIRES_CONFIRMATION -> SetupAttemptStatusApi.REQUIRES_CONFIRMATION
        SetupAttemptStatus.REQUIRES_ACTION -> SetupAttemptStatusApi.REQUIRES_ACTION
        SetupAttemptStatus.PROCESSING -> SetupAttemptStatusApi.PROCESSING
        SetupAttemptStatus.SUCCEEDED -> SetupAttemptStatusApi.SUCCEEDED
        SetupAttemptStatus.FAILED -> SetupAttemptStatusApi.FAILED
        SetupAttemptStatus.ABANDONED -> SetupAttemptStatusApi.ABANDONED
    }
}

fun SetupIntentPaymentMethodDetails.toApi(): SetupAttemptPaymentMethodDetailsApi {
    return SetupAttemptPaymentMethodDetailsApi(
        cardPresent = cardPresentDetails?.toApi(),
        interacPresent = interacPresentDetails?.toApi()
    )
}

fun SetupIntentCardPresentDetails.toApi(): SetupAttemptCardPresentDetailsApi {
    return SetupAttemptCardPresentDetailsApi(
        emvAuthData = emvAuthData!!,
        generatedCard = generatedCard!!
    )
}

// PARAMS

fun SetupIntentUsageApi.toHost(): String {
    return when (this) {
        SetupIntentUsageApi.ON_SESSION -> "on_session"
        SetupIntentUsageApi.OFF_SESSION -> "off_session"
    }
}

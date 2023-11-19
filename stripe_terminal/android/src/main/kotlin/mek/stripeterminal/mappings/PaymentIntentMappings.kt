package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.AmountDetails
import com.stripe.stripeterminal.external.models.CaptureMethod
import com.stripe.stripeterminal.external.models.PaymentIntent
import com.stripe.stripeterminal.external.models.PaymentIntentParameters
import com.stripe.stripeterminal.external.models.PaymentIntentStatus
import com.stripe.stripeterminal.external.models.PaymentMethodOptionsParameters
import com.stripe.stripeterminal.external.models.PaymentMethodType
import com.stripe.stripeterminal.external.models.PaymentStatus
import mek.stripeterminal.api.AmountDetailsApi
import mek.stripeterminal.api.CaptureMethodApi
import mek.stripeterminal.api.ConfirmationMethodApi
import mek.stripeterminal.api.PaymentIntentApi
import mek.stripeterminal.api.PaymentIntentParametersApi
import mek.stripeterminal.api.PaymentIntentStatusApi
import mek.stripeterminal.api.PaymentIntentUsageApi
import mek.stripeterminal.api.PaymentMethodOptionsParametersApi
import mek.stripeterminal.api.PaymentMethodTypeApi
import mek.stripeterminal.api.PaymentStatusApi
import mek.stripeterminal.api.toHost
import mek.stripeterminal.toHashMap

fun PaymentIntent.toApi(): PaymentIntentApi {
    return PaymentIntentApi(
        id = id!!,
        created = created,
        status = status!!.toApi(),
        amount = amount.toDouble(),
        captureMethod =
            when (captureMethod!!) {
                "automatic" -> CaptureMethodApi.AUTOMATIC
                "manual" -> CaptureMethodApi.MANUAL
                else ->
                    throw IllegalArgumentException(
                        "Not supported CaptureMethod '$captureMethod' on PaymentIntent $id",
                    )
            },
        currency = currency!!,
        metadata = metadata?.toHashMap() ?: hashMapOf(),
        charges = getCharges().map { it.toApi() },
        paymentMethod = paymentMethod?.toApi(),
        amountDetails = amountDetails?.toApi(),
        paymentMethodId = paymentMethodId,
        amountTip = amountTip?.toDouble(),
        statementDescriptor = statementDescriptor,
        statementDescriptorSuffix = statementDescriptorSuffix,
        // Only Android
        amountCapturable = amountCapturable.toDouble(),
        amountReceived = amountReceived.toDouble(),
        applicationId = application,
        applicationFeeAmount = applicationFeeAmount.toDouble(),
        canceledAt = canceledAt,
        cancellationReason = cancellationReason,
        clientSecret = clientSecret,
        confirmationMethod =
            when (confirmationMethod) {
                "automatic" -> ConfirmationMethodApi.AUTOMATIC
                "manual" -> ConfirmationMethodApi.MANUAL
                else -> null
            },
        description = description,
        invoiceId = invoice,
        onBehalfOf = onBehalfOf,
        receiptEmail = receiptEmail,
        reviewId = review,
        setupFutureUsage =
            when (setupFutureUsage) {
                "on_session" -> PaymentIntentUsageApi.ON_SESSION
                "off_session" -> PaymentIntentUsageApi.OFF_SESSION
                else -> null
            },
        transferGroup = transferGroup,
        customerId = customer,
    )
}

fun PaymentIntentStatus.toApi(): PaymentIntentStatusApi {
    return when (this) {
        PaymentIntentStatus.CANCELED -> PaymentIntentStatusApi.CANCELED
        PaymentIntentStatus.PROCESSING -> PaymentIntentStatusApi.PROCESSING
        PaymentIntentStatus.REQUIRES_CAPTURE -> PaymentIntentStatusApi.REQUIRES_CAPTURE
        PaymentIntentStatus.REQUIRES_CONFIRMATION -> PaymentIntentStatusApi.REQUIRES_CONFIRMATION
        PaymentIntentStatus.REQUIRES_PAYMENT_METHOD -> PaymentIntentStatusApi.REQUIRES_PAYMENT_METHOD
        PaymentIntentStatus.SUCCEEDED -> PaymentIntentStatusApi.SUCCEEDED
    }
}

fun AmountDetails.toApi(): AmountDetailsApi {
    return AmountDetailsApi(
        tip = tip?.toApi(),
    )
}

// PARAMS

fun PaymentIntentUsageApi.toHost(): String {
    return when (this) {
        PaymentIntentUsageApi.OFF_SESSION -> "off_session"
        PaymentIntentUsageApi.ON_SESSION -> "on_session"
    }
}

fun PaymentIntentParametersApi.toHost(): PaymentIntentParameters {
    val b =
        PaymentIntentParameters.Builder(
            amount = amount,
            currency = currency,
            captureMethod =
                when (captureMethod) {
                    CaptureMethodApi.MANUAL -> CaptureMethod.Manual
                    CaptureMethodApi.AUTOMATIC -> CaptureMethod.Automatic
                },
            allowedPaymentMethodTypes =
                paymentMethodTypes.map {
                    when (it) {
                        PaymentMethodTypeApi.CARD_PRESENT -> PaymentMethodType.CARD_PRESENT
                        PaymentMethodTypeApi.CARD -> PaymentMethodType.CARD
                        PaymentMethodTypeApi.INTERACT_PRESENT -> PaymentMethodType.INTERAC_PRESENT
                    }
                },
        )
    b.setMetadata(metadata)
    description?.let(b::setDescription)
    statementDescriptor?.let(b::setStatementDescriptor)
    statementDescriptorSuffix?.let(b::setStatementDescriptorSuffix)
    receiptEmail?.let(b::setReceiptEmail)
    customerId?.let(b::setCustomer)
    applicationFeeAmount?.let(b::setApplicationFeeAmount)
    transferDataDestination?.let(b::setTransferDataDestination)
    transferGroup?.let(b::setTransferGroup)
    onBehalfOf?.let(b::setOnBehalfOf)
    setupFutureUsage?.toHost()?.let(b::setSetupFutureUsage)
    paymentMethodOptionsParameters?.let { b.setPaymentMethodOptionsParameters(it.toHost()) }
    return b.build()
}

fun PaymentMethodOptionsParametersApi.toHost(): PaymentMethodOptionsParameters {
    return PaymentMethodOptionsParameters.Builder()
        .setCardPresentParameters(cardPresentParameters.toHost())
        .build()
}

// EXTRA

fun PaymentStatus.toApi(): PaymentStatusApi {
    return when (this) {
        PaymentStatus.NOT_READY -> PaymentStatusApi.NOT_READY
        PaymentStatus.READY -> PaymentStatusApi.READY
        PaymentStatus.WAITING_FOR_INPUT -> PaymentStatusApi.WAITING_FOR_INPUT
        PaymentStatus.PROCESSING -> PaymentStatusApi.PROCESSING
    }
}

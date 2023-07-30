package com.stripe_terminal.api

import com.stripe_terminal.toHashMap
import com.stripe.stripeterminal.external.models.*
import java.util.Calendar

fun TerminalException.toApi(): TerminalExceptionApi {
    return  TerminalExceptionApi(
        code = errorCode.name,
        message = errorMessage,
        details = stackTraceToString()
    )
}

fun Reader.toApi(): ReaderApi {
    return ReaderApi(
        locationStatus = locationStatus.toApi(),
        batteryLevel = batteryLevel?.toDouble() ?: -1.0,
        deviceType = deviceType.toApi(),
        simulated = isSimulated,
        availableUpdate = availableUpdate?.hasFirmwareUpdate ?: false,
        locationId = location?.id,
        label = label,
        serialNumber = serialNumber!!,
    )
}

fun LocationStatus.toApi(): LocationStatusApi {
    return when (this) {
        LocationStatus.UNKNOWN -> LocationStatusApi.UNKNOWN
        LocationStatus.SET -> LocationStatusApi.SET
        LocationStatus.NOT_SET -> LocationStatusApi.NOT_SET
    }
}

fun DeviceType.toApi(): DeviceTypeApi {
    return when (this) {
        DeviceType.CHIPPER_1X -> DeviceTypeApi.CHIPPER1_X
        DeviceType.CHIPPER_2X -> DeviceTypeApi.CHIPPER2_X
        DeviceType.STRIPE_M2 -> DeviceTypeApi.STRIPE_M2
        DeviceType.COTS_DEVICE -> DeviceTypeApi.COTS_DEVICE
        DeviceType.VERIFONE_P400 -> DeviceTypeApi.VERIFONE_P400
        DeviceType.WISECUBE -> DeviceTypeApi.WISE_CUBE
        DeviceType.WISEPAD_3 -> DeviceTypeApi.WISEPAD3
        DeviceType.WISEPAD_3S -> DeviceTypeApi.WISEPAD3S
        DeviceType.WISEPOS_E -> DeviceTypeApi.WISEPOS_E
        DeviceType.WISEPOS_E_DEVKIT -> DeviceTypeApi.WISEPOS_E_DEVKIT
        DeviceType.ETNA -> DeviceTypeApi.ETNA
        DeviceType.STRIPE_S700 -> DeviceTypeApi.STRIPE_S700
        DeviceType.STRIPE_S700_DEVKIT -> DeviceTypeApi.STRIPE_S700_DEVKIT
        DeviceType.UNKNOWN -> DeviceTypeApi.UNKNOWN
    }
}

fun ConnectionStatus.toApi(): ConnectionStatusApi {
    return when (this) {
        ConnectionStatus.NOT_CONNECTED -> ConnectionStatusApi.NOT_CONNECTED
        ConnectionStatus.CONNECTING -> ConnectionStatusApi.CONNECTING
        ConnectionStatus.CONNECTED -> ConnectionStatusApi.CONNECTED
    }
}

fun ReaderSoftwareUpdate.toApi(): ReaderSoftwareUpdateApi {
    return ReaderSoftwareUpdateApi(
        components = components.map { it.toApi() },
        hasConfigUpdate = hasConfigUpdate,
        hasFirmwareUpdate = hasFirmwareUpdate,
        hasIncrementalUpdate = hasIncrementalUpdate,
        hasKeyUpdate = hasKeyUpdate,
        keyProfileName = keyProfileName,
        onlyInstallRequiredUpdates = onlyInstallRequiredUpdates,
        requiredAt = requiredAt.time,
        settingsVersion = settingsVersion,
        timeEstimate = timeEstimate.toApi(),
        version = version,
    )
}

fun ReaderSoftwareUpdate.UpdateComponent.toApi(): UpdateComponentApi {
    return when (this) {
        ReaderSoftwareUpdate.UpdateComponent.INCREMENTAL -> UpdateComponentApi.INCREMENTAL
        ReaderSoftwareUpdate.UpdateComponent.FIRMWARE -> UpdateComponentApi.FIRMWARE
        ReaderSoftwareUpdate.UpdateComponent.CONFIG -> UpdateComponentApi.CONFIG
        ReaderSoftwareUpdate.UpdateComponent.KEYS -> UpdateComponentApi.KEYS
    }
}

fun ReaderSoftwareUpdate.UpdateTimeEstimate.toApi(): UpdateTimeEstimateApi {
    return when (this) {
        ReaderSoftwareUpdate.UpdateTimeEstimate.LESS_THAN_ONE_MINUTE -> UpdateTimeEstimateApi.LESS_THAN_ONE_MINUTE
        ReaderSoftwareUpdate.UpdateTimeEstimate.ONE_TO_TWO_MINUTES -> UpdateTimeEstimateApi.ONE_TO_TWO_MINUTES
        ReaderSoftwareUpdate.UpdateTimeEstimate.TWO_TO_FIVE_MINUTES -> UpdateTimeEstimateApi.TWO_TO_FIVE_MINUTES
        ReaderSoftwareUpdate.UpdateTimeEstimate.FIVE_TO_FIFTEEN_MINUTES -> UpdateTimeEstimateApi.FIVE_TO_FIFTEEN_MINUTES

    }
}

fun PaymentMethod.toApi(): PaymentMethodApi {
    return PaymentMethodApi(
        cardDetails = cardDetails?.toApi(),
//        cardPresentDetails
        customer = customer,
        id = id,
        // interacPresentDetails
        livemode = livemode,
        metadata = metadata?.toHashMap(),
    )
}

fun CardDetails.toApi(): CardDetailsApi {
    return CardDetailsApi(
        brand = brand,
        country = country,
        expMonth = expMonth.toLong(),
        expYear = expYear.toLong(),
        fingerprint = fingerprint,
        funding = funding,
//        generatedFrom
        last4 = last4,
    )
}

fun PaymentIntent.toApi(): PaymentIntentApi {
    return PaymentIntentApi(
        amount = amount.toDouble(),
        amountCapturable = amountCapturable.toDouble(),
//         amountDetails
        amountReceived = amountReceived.toDouble(),
//         amountTip
        application = application,
        applicationFeeAmount = applicationFeeAmount.toDouble(),
        canceledAt = canceledAt,
        cancellationReason = cancellationReason,
        captureMethod = captureMethod,
        clientSecret = clientSecret,
        confirmationMethod = confirmationMethod,
        created = created,
        currency = currency,
        description = description,
        id = id,
        invoice = invoice,
//         lastPaymentError
        livemode = livemode,
        metadata = metadata?.toHashMap(),
//         offlineBehavior
        onBehalfOf = onBehalfOf,
//         paymentMethod
//         paymentMethodData
        paymentMethodId = paymentMethodId,
//         paymentMethodOptions
//         paymentMethodUnion
        receiptEmail = receiptEmail,
        review = review,
        setupFutureUsage = setupFutureUsage,
//         statementDescriptor
//         statementDescriptorSuffix
        status = status?.toApi(),
//        stripeAccountId
        transferGroup = transferGroup,
        customer = customer,
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

fun Location.toApi(): LocationApi {
    return LocationApi(
        address = address?.toApi(),
        displayName = displayName,
        id = id,
        livemode = livemode,
        metadata = metadata?.toHashMap(),
    )
}

fun Address.toApi(): AddressApi {
    return AddressApi(
        city = city,
        country = country,
        line1 = line1,
        line2 = line2,
        postalCode = postalCode,
        state = state,
    )
}

fun PaymentStatus.toApi(): PaymentStatusApi {
    return when (this) {
        PaymentStatus.NOT_READY -> PaymentStatusApi.NOT_READY
        PaymentStatus.READY -> PaymentStatusApi.READY
        PaymentStatus.WAITING_FOR_INPUT -> PaymentStatusApi.WAITING_FOR_INPUT
        PaymentStatus.PROCESSING -> PaymentStatusApi.PROCESSING
    }
}

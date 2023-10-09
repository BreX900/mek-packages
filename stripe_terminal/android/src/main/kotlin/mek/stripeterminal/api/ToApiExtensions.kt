package mek.stripeterminal.api

import mek.stripeterminal.toHashMap
import com.stripe.stripeterminal.external.models.*
import com.stripe.stripeterminal.external.models.TerminalException.TerminalErrorCode
import mek.stripeterminal.createApiError

fun TerminalException.toPlatformError(): PlatformError {
    return toApi().toPlatformError()
}

fun TerminalExceptionApi.toPlatformError(): PlatformError {
    return PlatformError(
        code = "mek_stripe_terminal",
        message = null,
        details = serialize()
    )
}

fun TerminalException.toApi(): TerminalExceptionApi {
    val code = errorCode.toApiCode()
        ?: return createApiError(
            TerminalExceptionCodeApi.UNKNOWN,
            "Unsupported Terminal exception code: $errorCode"
        )
    return TerminalExceptionApi(
        code = code,
        message = errorMessage,
        stackTrace = stackTraceToString(),
        paymentIntent = paymentIntent?.toApi(),
        apiError = apiError?.toString(),
    )
}

private fun TerminalErrorCode.toApiCode(): TerminalExceptionCodeApi? {
    return when (this) {
        TerminalErrorCode.CANCEL_FAILED -> TerminalExceptionCodeApi.CANCEL_FAILED
        TerminalErrorCode.NOT_CONNECTED_TO_READER -> TerminalExceptionCodeApi.NOT_CONNECTED_TO_READER
        TerminalErrorCode.ALREADY_CONNECTED_TO_READER -> TerminalExceptionCodeApi.ALREADY_CONNECTED_TO_READER
        TerminalErrorCode.BLUETOOTH_PERMISSION_DENIED -> TerminalExceptionCodeApi.BLUETOOTH_PERMISSION_DENIED
        TerminalErrorCode.CONFIRM_INVALID_PAYMENT_INTENT -> TerminalExceptionCodeApi.CONFIRM_INVALID_PAYMENT_INTENT
        TerminalErrorCode.INVALID_CLIENT_SECRET -> TerminalExceptionCodeApi.INVALID_CLIENT_SECRET
        TerminalErrorCode.UNSUPPORTED_OPERATION -> TerminalExceptionCodeApi.UNSUPPORTED_OPERATION
        TerminalErrorCode.UNEXPECTED_OPERATION -> TerminalExceptionCodeApi.UNEXPECTED_OPERATION
        TerminalErrorCode.UNSUPPORTED_SDK -> TerminalExceptionCodeApi.UNSUPPORTED_SDK
        TerminalErrorCode.USB_PERMISSION_DENIED -> TerminalExceptionCodeApi.USB_PERMISSION_DENIED
        TerminalErrorCode.MISSING_REQUIRED_PARAMETER -> TerminalExceptionCodeApi.INVALID_PARAMETER
        TerminalErrorCode.INVALID_REQUIRED_PARAMETER -> TerminalExceptionCodeApi.INVALID_REQUIRED_PARAMETER
        TerminalErrorCode.INVALID_TIP_PARAMETER -> TerminalExceptionCodeApi.INVALID_TIP_PARAMETER
        TerminalErrorCode.LOCAL_MOBILE_LIBRARY_NOT_INCLUDED -> null
        TerminalErrorCode.LOCAL_MOBILE_UNSUPPORTED_DEVICE -> TerminalExceptionCodeApi.LOCAL_MOBILE_UNSUPPORTED_DEVICE
        TerminalErrorCode.LOCAL_MOBILE_UNSUPPORTED_ANDROID_VERSION -> TerminalExceptionCodeApi.LOCAL_MOBILE_UNSUPPORTED_OPERATING_SYSTEM_VERSION
        TerminalErrorCode.LOCAL_MOBILE_DEVICE_TAMPERED -> TerminalExceptionCodeApi.LOCAL_MOBILE_DEVICE_TAMPERED
        TerminalErrorCode.LOCAL_MOBILE_DEBUG_NOT_SUPPORTED -> TerminalExceptionCodeApi.LOCAL_MOBILE_DEBUG_NOT_SUPPORTED
        TerminalErrorCode.OFFLINE_MODE_UNSUPPORTED_ANDROID_VERSION -> TerminalExceptionCodeApi.OFFLINE_MODE_UNSUPPORTED_OPERATING_SYSTEM_VERSION
        TerminalErrorCode.CANCELED -> TerminalExceptionCodeApi.CANCELED
        TerminalErrorCode.LOCATION_SERVICES_DISABLED -> TerminalExceptionCodeApi.LOCATION_SERVICES_DISABLED
        TerminalErrorCode.BLUETOOTH_SCAN_TIMED_OUT -> TerminalExceptionCodeApi.BLUETOOTH_SCAN_TIMED_OUT
        TerminalErrorCode.BLUETOOTH_LOW_ENERGY_UNSUPPORTED -> TerminalExceptionCodeApi.BLUETOOTH_LOW_ENERGY_UNSUPPORTED
        TerminalErrorCode.READER_SOFTWARE_UPDATE_FAILED_BATTERY_LOW -> TerminalExceptionCodeApi.READER_SOFTWARE_UPDATE_FAILED_BATTERY_LOW
        TerminalErrorCode.READER_SOFTWARE_UPDATE_FAILED_INTERRUPTED -> TerminalExceptionCodeApi.READER_SOFTWARE_UPDATE_FAILED_INTERRUPTED
        TerminalErrorCode.CARD_INSERT_NOT_READ -> TerminalExceptionCodeApi.CARD_INSERT_NOT_READ
        TerminalErrorCode.CARD_SWIPE_NOT_READ -> TerminalExceptionCodeApi.CARD_SWIPE_NOT_READ
        TerminalErrorCode.CARD_READ_TIMED_OUT -> TerminalExceptionCodeApi.CARD_READ_TIMED_OUT
        TerminalErrorCode.CARD_REMOVED -> TerminalExceptionCodeApi.CARD_REMOVED
        TerminalErrorCode.CUSTOMER_CONSENT_REQUIRED -> TerminalExceptionCodeApi.CUSTOMER_CONSENT_REQUIRED
        TerminalErrorCode.CARD_LEFT_IN_READER -> TerminalExceptionCodeApi.CARD_LEFT_IN_READER
        TerminalErrorCode.USB_DISCOVERY_TIMED_OUT -> TerminalExceptionCodeApi.USB_DISCOVERY_TIMED_OUT
        TerminalErrorCode.FEATURE_NOT_ENABLED_ON_ACCOUNT -> TerminalExceptionCodeApi.FEATURE_NOT_ENABLED_ON_ACCOUNT
        TerminalErrorCode.READER_BUSY -> TerminalExceptionCodeApi.READER_BUSY
        TerminalErrorCode.READER_COMMUNICATION_ERROR -> TerminalExceptionCodeApi.READER_COMMUNICATION_ERROR
        TerminalErrorCode.BLUETOOTH_ERROR -> TerminalExceptionCodeApi.BLUETOOTH_ERROR
        TerminalErrorCode.BLUETOOTH_DISCONNECTED -> TerminalExceptionCodeApi.BLUETOOTH_DISCONNECTED
        TerminalErrorCode.BLUETOOTH_RECONNECT_STARTED -> TerminalExceptionCodeApi.BLUETOOTH_RECONNECT_STARTED
        TerminalErrorCode.USB_DISCONNECTED -> TerminalExceptionCodeApi.USB_DISCONNECTED
        TerminalErrorCode.USB_RECONNECT_STARTED -> TerminalExceptionCodeApi.USB_RECONNECT_STARTED
        TerminalErrorCode.READER_CONNECTED_TO_ANOTHER_DEVICE -> TerminalExceptionCodeApi.READER_CONNECTED_TO_ANOTHER_DEVICE
        TerminalErrorCode.READER_SOFTWARE_UPDATE_FAILED -> TerminalExceptionCodeApi.READER_SOFTWARE_UPDATE_FAILED
        TerminalErrorCode.READER_SOFTWARE_UPDATE_FAILED_READER_ERROR -> TerminalExceptionCodeApi.READER_SOFTWARE_UPDATE_FAILED_READER_ERROR
        TerminalErrorCode.READER_SOFTWARE_UPDATE_FAILED_SERVER_ERROR -> TerminalExceptionCodeApi.READER_SOFTWARE_UPDATE_FAILED_SERVER_ERROR
        TerminalErrorCode.LOCAL_MOBILE_NFC_DISABLED -> TerminalExceptionCodeApi.NFC_DISABLED
        TerminalErrorCode.UNSUPPORTED_READER_VERSION -> TerminalExceptionCodeApi.UNSUPPORTED_READER_VERSION
        TerminalErrorCode.UNEXPECTED_SDK_ERROR -> TerminalExceptionCodeApi.UNEXPECTED_SDK_ERROR
        TerminalErrorCode.DECLINED_BY_STRIPE_API -> TerminalExceptionCodeApi.DECLINED_BY_STRIPE_API
        TerminalErrorCode.DECLINED_BY_READER -> TerminalExceptionCodeApi.DECLINED_BY_READER
        TerminalErrorCode.REQUEST_TIMED_OUT -> TerminalExceptionCodeApi.REQUEST_TIMED_OUT
        TerminalErrorCode.STRIPE_API_CONNECTION_ERROR -> TerminalExceptionCodeApi.STRIPE_API_CONNECTION_ERROR
        TerminalErrorCode.STRIPE_API_ERROR -> TerminalExceptionCodeApi.STRIPE_API_ERROR
        TerminalErrorCode.STRIPE_API_RESPONSE_DECODING_ERROR -> TerminalExceptionCodeApi.STRIPE_API_RESPONSE_DECODING_ERROR
        TerminalErrorCode.CONNECTION_TOKEN_PROVIDER_ERROR -> TerminalExceptionCodeApi.CONNECTION_TOKEN_PROVIDER_ERROR
        TerminalErrorCode.SESSION_EXPIRED -> TerminalExceptionCodeApi.SESSION_EXPIRED
        TerminalErrorCode.ANDROID_API_LEVEL_ERROR -> TerminalExceptionCodeApi.UNSUPPORTED_MOBILE_DEVICE_CONFIGURATION
        TerminalErrorCode.AMOUNT_EXCEEDS_MAX_OFFLINE_AMOUNT -> TerminalExceptionCodeApi.AMOUNT_EXCEEDS_MAX_OFFLINE_AMOUNT
        TerminalErrorCode.OFFLINE_PAYMENTS_DATABASE_TOO_LARGE -> TerminalExceptionCodeApi.OFFLINE_PAYMENTS_DATABASE_TOO_LARGE
        TerminalErrorCode.READER_CONNECTION_NOT_AVAILABLE_OFFLINE -> TerminalExceptionCodeApi.READER_CONNECTION_NOT_AVAILABLE_OFFLINE
        TerminalErrorCode.LOCATION_CONNECTION_NOT_AVAILABLE_OFFLINE -> TerminalExceptionCodeApi.LOCATION_CONNECTION_NOT_AVAILABLE_OFFLINE
        TerminalErrorCode.NO_LAST_SEEN_ACCOUNT -> TerminalExceptionCodeApi.NO_LAST_SEEN_ACCOUNT
        TerminalErrorCode.INVALID_OFFLINE_CURRENCY -> TerminalExceptionCodeApi.INVALID_OFFLINE_CURRENCY
        TerminalErrorCode.CARD_SWIPE_NOT_AVAILABLE -> TerminalExceptionCodeApi.CARD_SWIPE_NOT_AVAILABLE
        TerminalErrorCode.INTERAC_NOT_SUPPORTED_OFFLINE -> TerminalExceptionCodeApi.INTERAC_NOT_SUPPORTED_OFFLINE
        TerminalErrorCode.ONLINE_PIN_NOT_SUPPORTED_OFFLINE -> TerminalExceptionCodeApi.ONLINE_PIN_NOT_SUPPORTED_OFFLINE
        TerminalErrorCode.OFFLINE_AND_CARD_EXPIRED -> TerminalExceptionCodeApi.OFFLINE_AND_CARD_EXPIRED
        TerminalErrorCode.OFFLINE_TRANSACTION_DECLINED -> TerminalExceptionCodeApi.OFFLINE_TRANSACTION_DECLINED
        TerminalErrorCode.OFFLINE_COLLECT_AND_CONFIRM_MISMATCH -> TerminalExceptionCodeApi.OFFLINE_COLLECT_AND_CONFIRM_MISMATCH
        TerminalErrorCode.OFFLINE_TESTMODE_PAYMENT_IN_LIVEMODE -> TerminalExceptionCodeApi.FORWARDING_TEST_MODE_PAYMENT_IN_LIVE_MODE
        TerminalErrorCode.OFFLINE_LIVEMODE_PAYMENT_IN_TESTMODE -> TerminalExceptionCodeApi.FORWARDING_LIVE_MODE_PAYMENT_IN_TEST_MODE
        TerminalErrorCode.OFFLINE_PAYMENT_INTENT_NOT_FOUND -> TerminalExceptionCodeApi.OFFLINE_PAYMENT_INTENT_NOT_FOUND
        TerminalErrorCode.MISSING_EMV_DATA -> TerminalExceptionCodeApi.MISSING_EMV_DATA
        TerminalErrorCode.CONNECTION_TOKEN_PROVIDER_ERROR_WHILE_FORWARDING -> TerminalExceptionCodeApi.CONNECTION_TOKEN_PROVIDER_ERROR_WHILE_FORWARDING
        TerminalErrorCode.ACCOUNT_ID_MISMATCH_WHILE_FORWARDING -> TerminalExceptionCodeApi.ACCOUNT_ID_MISMATCH_WHILE_FORWARDING
        TerminalErrorCode.FORCE_OFFLINE_WITH_FEATURE_DISABLED -> TerminalExceptionCodeApi.OFFLINE_BEHAVIOR_FORCE_OFFLINE_WITH_FEATURE_DISABLED
        TerminalErrorCode.NOT_CONNECTED_TO_INTERNET_AND_REQUIRE_ONLINE_SET -> TerminalExceptionCodeApi.NOT_CONNECTED_TO_INTERNET_AND_OFFLINE_BEHAVIOR_REQUIRE_ONLINE
        TerminalErrorCode.TEST_CARD_IN_LIVEMODE -> TerminalExceptionCodeApi.TEST_CARD_IN_LIVE_MODE
        TerminalErrorCode.COLLECT_INPUTS_APPLICATION_ERROR -> TerminalExceptionCodeApi.COLLECT_INPUTS_APPLICATION_ERROR
        TerminalErrorCode.COLLECT_INPUTS_TIMED_OUT -> TerminalExceptionCodeApi.COLLECT_INPUTS_TIMED_OUT
        TerminalErrorCode.COLLECT_INPUTS_INVALID_PARAMETER -> TerminalExceptionCodeApi.INVALID_PARAMETER
    }
}

fun Reader.toApi(): ReaderApi {
    return ReaderApi(
        locationStatus = locationStatus.toApi(),
        batteryLevel = batteryLevel?.toDouble() ?: -1.0,
        deviceType = deviceType.toApi(),
        simulated = isSimulated,
        availableUpdate = availableUpdate?.hasFirmwareUpdate ?: false,
        locationId = location?.id,
        location = location?.toApi(),
        label = label,
        serialNumber = serialNumber!!,
    )
}

fun LocationStatus.toApi(): LocationStatusApi? {
    return when (this) {
        LocationStatus.UNKNOWN -> null
        LocationStatus.SET -> LocationStatusApi.SET
        LocationStatus.NOT_SET -> LocationStatusApi.NOT_SET
    }
}

fun DeviceType.toApi(): DeviceTypeApi? {
    return when (this) {
        DeviceType.CHIPPER_1X -> DeviceTypeApi.CHIPPER1_X
        DeviceType.CHIPPER_2X -> DeviceTypeApi.CHIPPER2_X
        DeviceType.STRIPE_M2 -> DeviceTypeApi.STRIPE_M2
        DeviceType.COTS_DEVICE -> DeviceTypeApi.COTS_DEVICE
        DeviceType.VERIFONE_P400 -> DeviceTypeApi.VERIFONE_P400
        DeviceType.WISECUBE -> DeviceTypeApi.WISE_CUBE
        DeviceType.WISEPAD_3 -> DeviceTypeApi.WISE_PAD3
        DeviceType.WISEPAD_3S -> DeviceTypeApi.WISE_PAD3S
        DeviceType.WISEPOS_E -> DeviceTypeApi.WISE_POS_E
        DeviceType.WISEPOS_E_DEVKIT -> DeviceTypeApi.WISE_POS_E_DEVKIT
        DeviceType.ETNA -> DeviceTypeApi.ETNA
        DeviceType.STRIPE_S700 -> DeviceTypeApi.STRIPE_S700
        DeviceType.STRIPE_S700_DEVKIT -> DeviceTypeApi.STRIPE_S700_DEVKIT
        DeviceType.UNKNOWN -> null
    }
}

fun ConnectionStatus.toApi(): ConnectionStatusApi {
    return when (this) {
        ConnectionStatus.NOT_CONNECTED -> ConnectionStatusApi.NOT_CONNECTED
        ConnectionStatus.CONNECTING -> ConnectionStatusApi.CONNECTING
        ConnectionStatus.CONNECTED -> ConnectionStatusApi.CONNECTED
    }
}

fun ReaderEvent.toApi(): ReaderEventApi {
    return when (this) {
        ReaderEvent.CARD_INSERTED -> ReaderEventApi.CARD_INSERTED
        ReaderEvent.CARD_REMOVED -> ReaderEventApi.CARD_REMOVED
    }
}

fun ReaderDisplayMessage.toApi(): ReaderDisplayMessageApi {
    return when (this) {
        ReaderDisplayMessage.CHECK_MOBILE_DEVICE -> ReaderDisplayMessageApi.CHECK_MOBILE_DEVICE
        ReaderDisplayMessage.RETRY_CARD -> ReaderDisplayMessageApi.RETRY_CARD
        ReaderDisplayMessage.INSERT_CARD -> ReaderDisplayMessageApi.INSERT_CARD
        ReaderDisplayMessage.INSERT_OR_SWIPE_CARD -> ReaderDisplayMessageApi.INSERT_OR_SWIPE_CARD
        ReaderDisplayMessage.SWIPE_CARD -> ReaderDisplayMessageApi.SWIPE_CARD
        ReaderDisplayMessage.REMOVE_CARD -> ReaderDisplayMessageApi.REMOVE_CARD
        ReaderDisplayMessage.MULTIPLE_CONTACTLESS_CARDS_DETECTED -> ReaderDisplayMessageApi.MULTIPLE_CONTACTLESS_CARDS_DETECTED
        ReaderDisplayMessage.TRY_ANOTHER_READ_METHOD -> ReaderDisplayMessageApi.TRY_ANOTHER_READ_METHOD
        ReaderDisplayMessage.TRY_ANOTHER_CARD -> ReaderDisplayMessageApi.TRY_ANOTHER_CARD
        ReaderDisplayMessage.CARD_REMOVED_TOO_EARLY -> ReaderDisplayMessageApi.CARD_REMOVED_TOO_EARLY
    }
}

fun ReaderInputOptions.ReaderInputOption.toApi(): ReaderInputOptionApi? {
    return when (this) {
        ReaderInputOptions.ReaderInputOption.NONE -> null
        ReaderInputOptions.ReaderInputOption.INSERT -> ReaderInputOptionApi.INSERT_CARD
        ReaderInputOptions.ReaderInputOption.SWIPE -> ReaderInputOptionApi.SWIPE_CARD
        ReaderInputOptions.ReaderInputOption.TAP -> ReaderInputOptionApi.TAP_CARD
        ReaderInputOptions.ReaderInputOption.MANUAL_ENTRY -> ReaderInputOptionApi.MANUAL_ENTRY
    }
}

fun BatteryStatus.toApi(): BatteryStatusApi? {
    return when (this) {
        BatteryStatus.UNKNOWN -> null
        BatteryStatus.CRITICAL -> BatteryStatusApi.CRITICAL
        BatteryStatus.LOW -> BatteryStatusApi.LOW
        BatteryStatus.NOMINAL -> BatteryStatusApi.NOMINAL
    }
}

fun ReaderSoftwareUpdate.toApi(): ReaderSoftwareUpdateApi {
    return ReaderSoftwareUpdateApi(
        components = components.map { it.toApi() },
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
        expMonth = expMonth.toLong(),
        expYear = expYear.toLong(),
        funding = fundingToApi(funding),
        last4 = last4,
        cardholderName = cardholderName,
        generatedCard = generatedCard,
        receipt = receiptDetails?.toApi(),
        emvAuthData = emvAuthData,
        networks = networks?.toApi(),
        incrementalAuthorizationStatus = incrementalAuthorizationStatus.toApi(),
    )
}

fun ReceiptDetails.toApi(): ReceiptDetailsApi {
    return ReceiptDetailsApi(
        accountType = accountType,
        applicationPreferredName = applicationPreferredName!!,
        authorizationCode = authorizationCode,
        authorizationResponseCode = authorizationResponseCode!!,
        applicationCryptogram = applicationCryptogram!!,
        dedicatedFileName = dedicatedFileName!!,
        transactionStatusInformation = tsi!!,
        terminalVerificationResults = tvr!!,
    )
}

fun CardNetworks.toApi(): CardNetworksApi {
    return CardNetworksApi(
        available = available.map { cardBrandToApi(it)!! },
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

fun PaymentIntent.toApi(): PaymentIntentApi {
    return PaymentIntentApi(
        id = id!!,
        created = created,
        status = status!!.toApi(),
        amount = amount.toDouble(),
        captureMethod = when (captureMethod!!) {
            "automatic" -> CaptureMethodApi.AUTOMATIC
            "manual" -> CaptureMethodApi.MANUAL
            else -> throw IllegalArgumentException("Not supported CaptureMethod '${captureMethod}' on PaymentIntent $id")
        },
        currency = currency!!,
        metadata = metadata?.toHashMap() ?: hashMapOf(),
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
        confirmationMethod = when (confirmationMethod) {
            "automatic" -> ConfirmationMethodApi.AUTOMATIC
            "manual" -> ConfirmationMethodApi.MANUAL
            else -> null
        },
        description = description,
        invoiceId = invoice,
        onBehalfOf = onBehalfOf,
        receiptEmail = receiptEmail,
        reviewId = review,
        setupFutureUsage = when (setupFutureUsage) {
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

fun Location.toApi(): LocationApi {
    return LocationApi(
        address = address?.toApi(),
        displayName = displayName,
        id = id,
        livemode = livemode,
        metadata = metadata?.toHashMap() ?: hashMapOf(),
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

fun SetupIntent.toApi(): SetupIntentApi {
    return SetupIntentApi(
        id = id,
        created = created,
        customerId = customerId,
        metadata = metadata.toHashMap(),
        usage = usage!!.toApi(),
        status = status!!.toApi(),
        latestAttempt = latestAttempt?.toApi(),
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
        status = status.toApi(),
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
        generatedCard = generatedCard!!,
    )
}

fun Refund.toApi(): RefundApi {
    return RefundApi(
        id = id,
        amount = amount!!,
        chargeId = chargeId!!,
        created = created!!,
        currency = currency!!,
        metadata = metadata?.toHashMap() ?: HashMap(),
        reason = reason,
        status = when (status) {
            "succeeded" -> RefundStatusApi.SUCCEEDED
            "pending" -> RefundStatusApi.PENDING
            "failed" -> RefundStatusApi.FAILED
            else -> null
        },
        paymentMethodDetails = paymentMethodDetails?.toApi(),
        failureReason = failureReason,
    )
}

fun PaymentMethodDetails.toApi(): PaymentMethodDetailsApi {
    return PaymentMethodDetailsApi(
        cardPresent = cardPresentDetails?.toApi(),
        interacPresent = interacPresentDetails?.toApi()
    )
}
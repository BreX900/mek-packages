package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.TerminalException
import mek.stripeterminal.api.PlatformError
import mek.stripeterminal.api.TerminalExceptionApi
import mek.stripeterminal.api.TerminalExceptionCodeApi

fun TerminalException.toPlatformError(): PlatformError {
    return toApi().toPlatformError()
}

fun TerminalExceptionApi.toPlatformError(): PlatformError {
    return PlatformError(code = "mek_stripe_terminal", message = null, details = serialize())
}

fun TerminalException.toApi(): TerminalExceptionApi {
    val code = errorCode.toApiCode()
    return TerminalExceptionApi(
        code = code ?: TerminalExceptionCodeApi.UNKNOWN,
        message = errorMessage,
        stackTrace = stackTraceToString(),
        paymentIntent = paymentIntent?.toApi(),
        apiError = apiError?.toString()
    )
}

private fun TerminalException.TerminalErrorCode.toApiCode(): TerminalExceptionCodeApi? {
    return when (this) {
        TerminalException.TerminalErrorCode.CANCEL_FAILED -> TerminalExceptionCodeApi.CANCEL_FAILED
        TerminalException.TerminalErrorCode.NOT_CONNECTED_TO_READER -> TerminalExceptionCodeApi.NOT_CONNECTED_TO_READER
        TerminalException.TerminalErrorCode.ALREADY_CONNECTED_TO_READER -> TerminalExceptionCodeApi.ALREADY_CONNECTED_TO_READER
        TerminalException.TerminalErrorCode.BLUETOOTH_PERMISSION_DENIED -> TerminalExceptionCodeApi.BLUETOOTH_PERMISSION_DENIED
        TerminalException.TerminalErrorCode.CONFIRM_INVALID_PAYMENT_INTENT -> TerminalExceptionCodeApi.CONFIRM_INVALID_PAYMENT_INTENT
        TerminalException.TerminalErrorCode.INVALID_CLIENT_SECRET -> TerminalExceptionCodeApi.INVALID_CLIENT_SECRET
        TerminalException.TerminalErrorCode.UNSUPPORTED_OPERATION -> TerminalExceptionCodeApi.UNSUPPORTED_OPERATION
        TerminalException.TerminalErrorCode.UNEXPECTED_OPERATION -> TerminalExceptionCodeApi.UNEXPECTED_OPERATION
        TerminalException.TerminalErrorCode.UNSUPPORTED_SDK -> TerminalExceptionCodeApi.UNSUPPORTED_SDK
        TerminalException.TerminalErrorCode.USB_PERMISSION_DENIED -> TerminalExceptionCodeApi.USB_PERMISSION_DENIED
        TerminalException.TerminalErrorCode.MISSING_PREREQUISITE -> null
        TerminalException.TerminalErrorCode.MISSING_REQUIRED_PARAMETER -> TerminalExceptionCodeApi.INVALID_PARAMETER
        TerminalException.TerminalErrorCode.INVALID_REQUIRED_PARAMETER -> TerminalExceptionCodeApi.INVALID_REQUIRED_PARAMETER
        TerminalException.TerminalErrorCode.INVALID_TIP_PARAMETER -> TerminalExceptionCodeApi.INVALID_TIP_PARAMETER
        TerminalException.TerminalErrorCode.LOCAL_MOBILE_LIBRARY_NOT_INCLUDED -> null
        TerminalException.TerminalErrorCode.LOCAL_MOBILE_UNSUPPORTED_DEVICE -> TerminalExceptionCodeApi.LOCAL_MOBILE_UNSUPPORTED_DEVICE
        TerminalException.TerminalErrorCode.LOCAL_MOBILE_UNSUPPORTED_ANDROID_VERSION -> TerminalExceptionCodeApi.LOCAL_MOBILE_UNSUPPORTED_OPERATING_SYSTEM_VERSION
        TerminalException.TerminalErrorCode.LOCAL_MOBILE_DEVICE_TAMPERED -> TerminalExceptionCodeApi.LOCAL_MOBILE_DEVICE_TAMPERED
        TerminalException.TerminalErrorCode.LOCAL_MOBILE_DEBUG_NOT_SUPPORTED -> TerminalExceptionCodeApi.LOCAL_MOBILE_DEBUG_NOT_SUPPORTED
        TerminalException.TerminalErrorCode.OFFLINE_MODE_UNSUPPORTED_ANDROID_VERSION -> TerminalExceptionCodeApi.OFFLINE_MODE_UNSUPPORTED_OPERATING_SYSTEM_VERSION
        TerminalException.TerminalErrorCode.CANCELED -> TerminalExceptionCodeApi.CANCELED
        TerminalException.TerminalErrorCode.LOCATION_SERVICES_DISABLED -> TerminalExceptionCodeApi.LOCATION_SERVICES_DISABLED
        TerminalException.TerminalErrorCode.BLUETOOTH_SCAN_TIMED_OUT -> TerminalExceptionCodeApi.BLUETOOTH_SCAN_TIMED_OUT
        TerminalException.TerminalErrorCode.BLUETOOTH_LOW_ENERGY_UNSUPPORTED -> TerminalExceptionCodeApi.BLUETOOTH_LOW_ENERGY_UNSUPPORTED
        TerminalException.TerminalErrorCode.READER_SOFTWARE_UPDATE_FAILED_BATTERY_LOW -> TerminalExceptionCodeApi.READER_SOFTWARE_UPDATE_FAILED_BATTERY_LOW
        TerminalException.TerminalErrorCode.READER_SOFTWARE_UPDATE_FAILED_INTERRUPTED -> TerminalExceptionCodeApi.READER_SOFTWARE_UPDATE_FAILED_INTERRUPTED
        TerminalException.TerminalErrorCode.CARD_INSERT_NOT_READ -> TerminalExceptionCodeApi.CARD_INSERT_NOT_READ
        TerminalException.TerminalErrorCode.CARD_SWIPE_NOT_READ -> TerminalExceptionCodeApi.CARD_SWIPE_NOT_READ
        TerminalException.TerminalErrorCode.CARD_READ_TIMED_OUT -> TerminalExceptionCodeApi.CARD_READ_TIMED_OUT
        TerminalException.TerminalErrorCode.CARD_REMOVED -> TerminalExceptionCodeApi.CARD_REMOVED
        TerminalException.TerminalErrorCode.CUSTOMER_CONSENT_REQUIRED -> TerminalExceptionCodeApi.CUSTOMER_CONSENT_REQUIRED
        TerminalException.TerminalErrorCode.CARD_LEFT_IN_READER -> TerminalExceptionCodeApi.CARD_LEFT_IN_READER
        TerminalException.TerminalErrorCode.USB_DISCOVERY_TIMED_OUT -> TerminalExceptionCodeApi.USB_DISCOVERY_TIMED_OUT
        TerminalException.TerminalErrorCode.FEATURE_NOT_ENABLED_ON_ACCOUNT -> TerminalExceptionCodeApi.FEATURE_NOT_ENABLED_ON_ACCOUNT
        TerminalException.TerminalErrorCode.READER_BUSY -> TerminalExceptionCodeApi.READER_BUSY
        TerminalException.TerminalErrorCode.READER_COMMUNICATION_ERROR -> TerminalExceptionCodeApi.READER_COMMUNICATION_ERROR
        TerminalException.TerminalErrorCode.BLUETOOTH_ERROR -> TerminalExceptionCodeApi.BLUETOOTH_ERROR
        TerminalException.TerminalErrorCode.BLUETOOTH_DISCONNECTED -> TerminalExceptionCodeApi.BLUETOOTH_DISCONNECTED
        TerminalException.TerminalErrorCode.BLUETOOTH_RECONNECT_STARTED -> TerminalExceptionCodeApi.BLUETOOTH_RECONNECT_STARTED
        TerminalException.TerminalErrorCode.USB_DISCONNECTED -> TerminalExceptionCodeApi.USB_DISCONNECTED
        TerminalException.TerminalErrorCode.USB_RECONNECT_STARTED -> TerminalExceptionCodeApi.USB_RECONNECT_STARTED
        TerminalException.TerminalErrorCode.READER_CONNECTED_TO_ANOTHER_DEVICE -> TerminalExceptionCodeApi.READER_CONNECTED_TO_ANOTHER_DEVICE
        TerminalException.TerminalErrorCode.READER_SOFTWARE_UPDATE_FAILED -> TerminalExceptionCodeApi.READER_SOFTWARE_UPDATE_FAILED
        TerminalException.TerminalErrorCode.READER_SOFTWARE_UPDATE_FAILED_READER_ERROR -> TerminalExceptionCodeApi.READER_SOFTWARE_UPDATE_FAILED_READER_ERROR
        TerminalException.TerminalErrorCode.READER_SOFTWARE_UPDATE_FAILED_SERVER_ERROR -> TerminalExceptionCodeApi.READER_SOFTWARE_UPDATE_FAILED_SERVER_ERROR
        TerminalException.TerminalErrorCode.LOCAL_MOBILE_NFC_DISABLED -> TerminalExceptionCodeApi.NFC_DISABLED
        TerminalException.TerminalErrorCode.UNSUPPORTED_READER_VERSION -> TerminalExceptionCodeApi.UNSUPPORTED_READER_VERSION
        TerminalException.TerminalErrorCode.UNEXPECTED_SDK_ERROR -> TerminalExceptionCodeApi.UNEXPECTED_SDK_ERROR
        TerminalException.TerminalErrorCode.DECLINED_BY_STRIPE_API -> TerminalExceptionCodeApi.DECLINED_BY_STRIPE_API
        TerminalException.TerminalErrorCode.DECLINED_BY_READER -> TerminalExceptionCodeApi.DECLINED_BY_READER
        TerminalException.TerminalErrorCode.REQUEST_TIMED_OUT -> TerminalExceptionCodeApi.REQUEST_TIMED_OUT
        TerminalException.TerminalErrorCode.STRIPE_API_CONNECTION_ERROR -> TerminalExceptionCodeApi.STRIPE_API_CONNECTION_ERROR
        TerminalException.TerminalErrorCode.STRIPE_API_ERROR -> TerminalExceptionCodeApi.STRIPE_API_ERROR
        TerminalException.TerminalErrorCode.STRIPE_API_RESPONSE_DECODING_ERROR -> TerminalExceptionCodeApi.STRIPE_API_RESPONSE_DECODING_ERROR
        TerminalException.TerminalErrorCode.CONNECTION_TOKEN_PROVIDER_ERROR -> TerminalExceptionCodeApi.CONNECTION_TOKEN_PROVIDER_ERROR
        TerminalException.TerminalErrorCode.SESSION_EXPIRED -> TerminalExceptionCodeApi.SESSION_EXPIRED
        TerminalException.TerminalErrorCode.ANDROID_API_LEVEL_ERROR -> TerminalExceptionCodeApi.UNSUPPORTED_MOBILE_DEVICE_CONFIGURATION
        TerminalException.TerminalErrorCode.AMOUNT_EXCEEDS_MAX_OFFLINE_AMOUNT -> TerminalExceptionCodeApi.AMOUNT_EXCEEDS_MAX_OFFLINE_AMOUNT
        TerminalException.TerminalErrorCode.OFFLINE_PAYMENTS_DATABASE_TOO_LARGE -> TerminalExceptionCodeApi.OFFLINE_PAYMENTS_DATABASE_TOO_LARGE
        TerminalException.TerminalErrorCode.READER_CONNECTION_NOT_AVAILABLE_OFFLINE -> TerminalExceptionCodeApi.READER_CONNECTION_NOT_AVAILABLE_OFFLINE
        TerminalException.TerminalErrorCode.LOCATION_CONNECTION_NOT_AVAILABLE_OFFLINE -> TerminalExceptionCodeApi.LOCATION_CONNECTION_NOT_AVAILABLE_OFFLINE
        TerminalException.TerminalErrorCode.NO_LAST_SEEN_ACCOUNT -> TerminalExceptionCodeApi.NO_LAST_SEEN_ACCOUNT
        TerminalException.TerminalErrorCode.INVALID_OFFLINE_CURRENCY -> TerminalExceptionCodeApi.INVALID_OFFLINE_CURRENCY
        TerminalException.TerminalErrorCode.CARD_SWIPE_NOT_AVAILABLE -> TerminalExceptionCodeApi.CARD_SWIPE_NOT_AVAILABLE
        TerminalException.TerminalErrorCode.INTERAC_NOT_SUPPORTED_OFFLINE -> TerminalExceptionCodeApi.INTERAC_NOT_SUPPORTED_OFFLINE
        TerminalException.TerminalErrorCode.ONLINE_PIN_NOT_SUPPORTED_OFFLINE -> TerminalExceptionCodeApi.ONLINE_PIN_NOT_SUPPORTED_OFFLINE
        TerminalException.TerminalErrorCode.OFFLINE_AND_CARD_EXPIRED -> TerminalExceptionCodeApi.OFFLINE_AND_CARD_EXPIRED
        TerminalException.TerminalErrorCode.OFFLINE_TRANSACTION_DECLINED -> TerminalExceptionCodeApi.OFFLINE_TRANSACTION_DECLINED
        TerminalException.TerminalErrorCode.OFFLINE_COLLECT_AND_CONFIRM_MISMATCH -> TerminalExceptionCodeApi.OFFLINE_COLLECT_AND_CONFIRM_MISMATCH
        TerminalException.TerminalErrorCode.OFFLINE_TESTMODE_PAYMENT_IN_LIVEMODE -> TerminalExceptionCodeApi.FORWARDING_TEST_MODE_PAYMENT_IN_LIVE_MODE
        TerminalException.TerminalErrorCode.OFFLINE_LIVEMODE_PAYMENT_IN_TESTMODE -> TerminalExceptionCodeApi.FORWARDING_LIVE_MODE_PAYMENT_IN_TEST_MODE
        TerminalException.TerminalErrorCode.OFFLINE_PAYMENT_INTENT_NOT_FOUND -> TerminalExceptionCodeApi.OFFLINE_PAYMENT_INTENT_NOT_FOUND
        TerminalException.TerminalErrorCode.MISSING_EMV_DATA -> TerminalExceptionCodeApi.MISSING_EMV_DATA
        TerminalException.TerminalErrorCode.CONNECTION_TOKEN_PROVIDER_ERROR_WHILE_FORWARDING -> TerminalExceptionCodeApi.CONNECTION_TOKEN_PROVIDER_ERROR_WHILE_FORWARDING
        TerminalException.TerminalErrorCode.ACCOUNT_ID_MISMATCH_WHILE_FORWARDING -> TerminalExceptionCodeApi.ACCOUNT_ID_MISMATCH_WHILE_FORWARDING
        TerminalException.TerminalErrorCode.FORCE_OFFLINE_WITH_FEATURE_DISABLED -> TerminalExceptionCodeApi.OFFLINE_BEHAVIOR_FORCE_OFFLINE_WITH_FEATURE_DISABLED
        TerminalException.TerminalErrorCode.NOT_CONNECTED_TO_INTERNET_AND_REQUIRE_ONLINE_SET -> TerminalExceptionCodeApi.NOT_CONNECTED_TO_INTERNET_AND_OFFLINE_BEHAVIOR_REQUIRE_ONLINE
        TerminalException.TerminalErrorCode.TEST_CARD_IN_LIVEMODE -> TerminalExceptionCodeApi.TEST_CARD_IN_LIVE_MODE
        TerminalException.TerminalErrorCode.COLLECT_INPUTS_APPLICATION_ERROR -> TerminalExceptionCodeApi.COLLECT_INPUTS_APPLICATION_ERROR
        TerminalException.TerminalErrorCode.COLLECT_INPUTS_TIMED_OUT -> TerminalExceptionCodeApi.COLLECT_INPUTS_TIMED_OUT
        TerminalException.TerminalErrorCode.COLLECT_INPUTS_INVALID_PARAMETER -> TerminalExceptionCodeApi.INVALID_PARAMETER
        TerminalException.TerminalErrorCode.COLLECT_INPUTS_UNSUPPORTED -> TerminalExceptionCodeApi.COLLECT_INPUTS_UNSUPPORTED
    }
}

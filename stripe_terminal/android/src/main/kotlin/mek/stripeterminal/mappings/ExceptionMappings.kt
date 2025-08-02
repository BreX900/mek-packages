package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.TerminalErrorCode
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

private fun TerminalErrorCode.toApiCode(): TerminalExceptionCodeApi? {
    return when (this) {
        TerminalErrorCode.CANCEL_FAILED -> TerminalExceptionCodeApi.CANCEL_FAILED
        TerminalErrorCode.NOT_CONNECTED_TO_READER -> TerminalExceptionCodeApi.NOT_CONNECTED_TO_READER
        TerminalErrorCode.ALREADY_CONNECTED_TO_READER -> TerminalExceptionCodeApi.ALREADY_CONNECTED_TO_READER
        TerminalErrorCode.BLUETOOTH_PERMISSION_DENIED -> TerminalExceptionCodeApi.BLUETOOTH_PERMISSION_DENIED
        TerminalErrorCode.CONFIRM_INVALID_PAYMENT_INTENT -> TerminalExceptionCodeApi.CONFIRM_INVALID_PAYMENT_INTENT
        TerminalErrorCode.CONFIRM_INVALID_SETUP_INTENT -> TerminalExceptionCodeApi.CONFIRM_INVALID_SETUP_INTENT
        TerminalErrorCode.INVALID_CLIENT_SECRET -> TerminalExceptionCodeApi.INVALID_CLIENT_SECRET
        TerminalErrorCode.UNSUPPORTED_OPERATION -> TerminalExceptionCodeApi.UNSUPPORTED_OPERATION
        TerminalErrorCode.UNEXPECTED_OPERATION -> TerminalExceptionCodeApi.UNEXPECTED_OPERATION
        TerminalErrorCode.UNSUPPORTED_SDK -> TerminalExceptionCodeApi.UNSUPPORTED_SDK
        TerminalErrorCode.USB_PERMISSION_DENIED -> TerminalExceptionCodeApi.USB_PERMISSION_DENIED
        TerminalErrorCode.MISSING_PREREQUISITE -> null
        TerminalErrorCode.MISSING_REQUIRED_PARAMETER -> TerminalExceptionCodeApi.INVALID_PARAMETER
        TerminalErrorCode.INVALID_REQUIRED_PARAMETER -> TerminalExceptionCodeApi.INVALID_REQUIRED_PARAMETER
        TerminalErrorCode.INVALID_TIP_PARAMETER -> TerminalExceptionCodeApi.INVALID_TIP_PARAMETER
        TerminalErrorCode.TAP_TO_PAY_LIBRARY_NOT_INCLUDED -> null
        TerminalErrorCode.TAP_TO_PAY_UNSUPPORTED_DEVICE -> TerminalExceptionCodeApi.TAP_TO_PAY_UNSUPPORTED_DEVICE
        TerminalErrorCode.TAP_TO_PAY_UNSUPPORTED_ANDROID_VERSION -> TerminalExceptionCodeApi.TAP_TO_PAY_UNSUPPORTED_OPERATING_SYSTEM_VERSION
        TerminalErrorCode.TAP_TO_PAY_DEVICE_TAMPERED -> TerminalExceptionCodeApi.TAP_TO_PAY_DEVICE_TAMPERED
        TerminalErrorCode.TAP_TO_PAY_DEBUG_NOT_SUPPORTED -> TerminalExceptionCodeApi.TAP_TO_PAY_DEBUG_NOT_SUPPORTED
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
        TerminalErrorCode.TAP_TO_PAY_NFC_DISABLED -> TerminalExceptionCodeApi.NFC_DISABLED
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
        TerminalErrorCode.MOBILE_WALLET_NOT_SUPPORTED_ON_SETUP_INTENTS -> TerminalExceptionCodeApi.MOBILE_WALLET_NOT_SUPPORTED_ON_SETUP_INTENTS
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
        TerminalErrorCode.COLLECT_INPUTS_UNSUPPORTED -> TerminalExceptionCodeApi.COLLECT_INPUTS_UNSUPPORTED
        TerminalErrorCode.READER_BATTERY_CRITICALLY_LOW -> TerminalExceptionCodeApi.READER_BATTERY_CRITICALLY_LOW
        TerminalErrorCode.READER_SETTINGS_ERROR -> TerminalExceptionCodeApi.READER_SETTINGS_ERROR
        TerminalErrorCode.READER_MISSING_ENCRYPTION_KEYS -> TerminalExceptionCodeApi.READER_MISSING_ENCRYPTION_KEYS
        TerminalErrorCode.INVALID_SURCHARGE_PARAMETER -> TerminalExceptionCodeApi.INVALID_SURCHARGE_PARAMETER
        TerminalErrorCode.READER_COMMUNICATION_SSL_ERROR -> TerminalExceptionCodeApi.READER_COMMUNICATION_SSL_ERROR
        TerminalErrorCode.TAP_TO_PAY_INSECURE_ENVIRONMENT -> TerminalExceptionCodeApi.TAP_TO_PAY_INSECURE_ENVIRONMENT
        TerminalErrorCode.GENERIC_READER_ERROR -> TerminalExceptionCodeApi.UNEXPECTED_READER_ERROR
        TerminalErrorCode.ALLOW_REDISPLAY_INVALID -> TerminalExceptionCodeApi.ALLOW_REDISPLAY_INVALID
        TerminalErrorCode.CANCELED_DUE_TO_INTEGRATION_ERROR -> TerminalExceptionCodeApi.CANCELED_DUE_TO_INTEGRATION_ERROR
        TerminalErrorCode.READER_TAMPERED -> TerminalExceptionCodeApi.READER_TAMPERED
        TerminalErrorCode.PRINTER_BUSY -> TerminalExceptionCodeApi.PRINTER_BUSY
        TerminalErrorCode.PRINTER_PAPERJAM -> TerminalExceptionCodeApi.PRINTER_PAPERJAM
        TerminalErrorCode.PRINTER_OUT_OF_PAPER -> TerminalExceptionCodeApi.PRINTER_OUT_OF_PAPER
        TerminalErrorCode.PRINTER_COVER_OPEN -> TerminalExceptionCodeApi.PRINTER_COVER_OPEN
        TerminalErrorCode.PRINTER_ABSENT -> TerminalExceptionCodeApi.PRINTER_ABSENT
        TerminalErrorCode.PRINTER_UNAVAILABLE -> TerminalExceptionCodeApi.PRINTER_UNAVAILABLE
        TerminalErrorCode.PRINTER_ERROR -> TerminalExceptionCodeApi.PRINTER_ERROR
        TerminalErrorCode.TAP_TO_PAY_UNSUPPORTED_PROCESSOR -> TerminalExceptionCodeApi.TAP_TO_PAY_UNSUPPORTED_PROCESSOR
    }
}

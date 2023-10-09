package mek.stripeterminal.api

import com.stripe.stripeterminal.external.models.*
import mek.stripeterminal.microsecondsToSeconds

fun DiscoveryConfigurationApi.toHost(): DiscoveryConfiguration? {
    return when (this) {
        is BluetoothDiscoveryConfigurationApi -> DiscoveryConfiguration.BluetoothDiscoveryConfiguration(
            isSimulated = isSimulated,
            timeout = timeout?.let { microsecondsToSeconds(it) } ?: 0,
        )

        is BluetoothProximityDiscoveryConfigurationApi -> null
        is HandoffDiscoveryConfigurationApi -> DiscoveryConfiguration.HandoffDiscoveryConfiguration()
        is InternetDiscoveryConfigurationApi -> DiscoveryConfiguration.InternetDiscoveryConfiguration(
            isSimulated = isSimulated,
            location = locationId,
        )

        is LocalMobileDiscoveryConfigurationApi -> DiscoveryConfiguration.LocalMobileDiscoveryConfiguration(
            isSimulated = isSimulated,
        )

        is UsbDiscoveryConfigurationApi -> DiscoveryConfiguration.UsbDiscoveryConfiguration(
            isSimulated = isSimulated,
            timeout = timeout?.let { microsecondsToSeconds(it) } ?: 0,
        )
    }
}

fun DeviceTypeApi.toHost(): DeviceType? {
    return when (this) {
        DeviceTypeApi.CHIPPER1_X -> DeviceType.CHIPPER_1X
        DeviceTypeApi.CHIPPER2_X -> DeviceType.CHIPPER_2X
        DeviceTypeApi.STRIPE_M2 -> DeviceType.STRIPE_M2
        DeviceTypeApi.COTS_DEVICE -> DeviceType.COTS_DEVICE
        DeviceTypeApi.VERIFONE_P400 -> DeviceType.VERIFONE_P400
        DeviceTypeApi.WISE_CUBE -> DeviceType.WISECUBE
        DeviceTypeApi.WISE_PAD3 -> DeviceType.WISEPAD_3
        DeviceTypeApi.WISE_PAD3S -> DeviceType.WISEPAD_3S
        DeviceTypeApi.WISE_POS_E -> DeviceType.WISEPOS_E
        DeviceTypeApi.WISE_POS_E_DEVKIT -> DeviceType.WISEPOS_E_DEVKIT
        DeviceTypeApi.ETNA -> DeviceType.ETNA
        DeviceTypeApi.STRIPE_S700 -> DeviceType.STRIPE_S700
        DeviceTypeApi.STRIPE_S700_DEVKIT -> DeviceType.STRIPE_S700_DEVKIT
        DeviceTypeApi.APPLE_BUILT_IN -> null
    }
}

fun CartApi.toHost(): Cart {
    return Cart.Builder(
        currency = currency,
        tax = tax,
        total = total,
        lineItems = lineItems.map { it.toHost() }
    ).build()
}

fun CartLineItemApi.toHost(): CartLineItem {
    return CartLineItem.Builder(
        description = description,
        quantity = quantity.toInt(),
        amount = amount
    ).build()
}

fun PaymentIntentUsageApi.toHost(): String {
    return when (this) {
        PaymentIntentUsageApi.OFF_SESSION -> "off_session"
        PaymentIntentUsageApi.ON_SESSION -> "on_session"
    }
}

fun PaymentIntentParametersApi.toHost(): PaymentIntentParameters {
    val b = PaymentIntentParameters.Builder(
        amount = amount,
        currency = currency,
        captureMethod = when (captureMethod) {
            CaptureMethodApi.MANUAL -> CaptureMethod.Manual
            CaptureMethodApi.AUTOMATIC -> CaptureMethod.Automatic
        },
        allowedPaymentMethodTypes = paymentMethodTypes.map {
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

fun SetupIntentUsageApi.toHost(): String {
    return when (this) {
        SetupIntentUsageApi.ON_SESSION -> "on_session"
        SetupIntentUsageApi.OFF_SESSION -> "off_session"
    }
}
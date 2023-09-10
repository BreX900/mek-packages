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

fun SetupIntentUsageApi.toHost(): String {
    return when (this) {
        SetupIntentUsageApi.ON_SESSION -> "on_session"
        SetupIntentUsageApi.OFF_SESSION -> "off_session"
    }
}
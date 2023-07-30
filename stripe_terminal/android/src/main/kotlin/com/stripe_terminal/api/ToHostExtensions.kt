package com.stripe_terminal.api

import com.stripe.stripeterminal.external.models.*

fun DiscoveryMethodApi.toHost(): DiscoveryMethod? {
    return when (this) {
        DiscoveryMethodApi.BLUETOOTH_SCAN -> DiscoveryMethod.BLUETOOTH_SCAN
        DiscoveryMethodApi.BLUETOOTH_PROXIMITY -> null
        DiscoveryMethodApi.INTERNET -> DiscoveryMethod.INTERNET
        DiscoveryMethodApi.LOCAL_MOBILE -> DiscoveryMethod.LOCAL_MOBILE
        DiscoveryMethodApi.HAND_OFF -> DiscoveryMethod.HANDOFF
        DiscoveryMethodApi.EMBEDDED -> DiscoveryMethod.EMBEDDED
        DiscoveryMethodApi.USB -> DiscoveryMethod.USB
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
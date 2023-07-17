package com.stripe_terminal.api

import com.stripe.stripeterminal.external.models.*

fun DiscoverConfigApi.toHost(): DiscoveryConfiguration {
    return DiscoveryConfiguration(
        isSimulated = simulated,
        discoveryMethod = discoveryMethod.toHost(),
        location = locationId
    )
}

fun DiscoveryMethodApi.toHost(): DiscoveryMethod {
    return when (this) {
        DiscoveryMethodApi.BLUETOOTH_SCAN -> DiscoveryMethod.BLUETOOTH_SCAN
        DiscoveryMethodApi.INTERNET -> DiscoveryMethod.INTERNET
        DiscoveryMethodApi.LOCAL_MOBILE -> DiscoveryMethod.LOCAL_MOBILE
        DiscoveryMethodApi.HAND_OFF -> DiscoveryMethod.HANDOFF
        DiscoveryMethodApi.EMBEDDED -> DiscoveryMethod.EMBEDDED
        DiscoveryMethodApi.USB -> DiscoveryMethod.USB
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
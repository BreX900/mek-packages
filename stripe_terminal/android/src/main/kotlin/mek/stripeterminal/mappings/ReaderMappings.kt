package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.Address
import com.stripe.stripeterminal.external.models.BatteryStatus
import com.stripe.stripeterminal.external.models.Cart
import com.stripe.stripeterminal.external.models.CartLineItem
import com.stripe.stripeterminal.external.models.ConnectionStatus
import com.stripe.stripeterminal.external.models.DeviceType
import com.stripe.stripeterminal.external.models.DiscoveryConfiguration
import com.stripe.stripeterminal.external.models.Location
import com.stripe.stripeterminal.external.models.LocationStatus
import com.stripe.stripeterminal.external.models.Reader
import com.stripe.stripeterminal.external.models.ReaderDisplayMessage
import com.stripe.stripeterminal.external.models.ReaderEvent
import com.stripe.stripeterminal.external.models.ReaderInputOptions
import com.stripe.stripeterminal.external.models.ReaderSoftwareUpdate
import mek.stripeterminal.api.AddressApi
import mek.stripeterminal.api.BatteryStatusApi
import mek.stripeterminal.api.BluetoothDiscoveryConfigurationApi
import mek.stripeterminal.api.BluetoothProximityDiscoveryConfigurationApi
import mek.stripeterminal.api.CartApi
import mek.stripeterminal.api.CartLineItemApi
import mek.stripeterminal.api.ConnectionStatusApi
import mek.stripeterminal.api.DeviceTypeApi
import mek.stripeterminal.api.DiscoveryConfigurationApi
import mek.stripeterminal.api.HandoffDiscoveryConfigurationApi
import mek.stripeterminal.api.InternetDiscoveryConfigurationApi
import mek.stripeterminal.api.LocationApi
import mek.stripeterminal.api.LocationStatusApi
import mek.stripeterminal.api.ReaderApi
import mek.stripeterminal.api.ReaderDisplayMessageApi
import mek.stripeterminal.api.ReaderEventApi
import mek.stripeterminal.api.ReaderInputOptionApi
import mek.stripeterminal.api.ReaderSoftwareUpdateApi
import mek.stripeterminal.api.TapToPayDiscoveryConfigurationApi
import mek.stripeterminal.api.UpdateComponentApi
import mek.stripeterminal.api.UpdateTimeEstimateApi
import mek.stripeterminal.api.UsbDiscoveryConfigurationApi
import mek.stripeterminal.microsecondsToSeconds
import mek.stripeterminal.toHashMap

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
        serialNumber = serialNumber!!
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
        DeviceType.TAP_TO_PAY_DEVICE -> DeviceTypeApi.TAP_TO_PAY
        DeviceType.VERIFONE_P400 -> DeviceTypeApi.VERIFONE_P400
        DeviceType.WISECUBE -> DeviceTypeApi.WISE_CUBE
        DeviceType.WISEPAD_3 -> DeviceTypeApi.WISE_PAD3
        DeviceType.WISEPAD_3S -> DeviceTypeApi.WISE_PAD3S
        DeviceType.WISEPOS_E -> DeviceTypeApi.WISE_POS_E
        DeviceType.WISEPOS_E_DEVKIT -> DeviceTypeApi.WISE_POS_E_DEVKIT
        DeviceType.ETNA -> DeviceTypeApi.ETNA
        DeviceType.STRIPE_S700 -> DeviceTypeApi.STRIPE_S700
        DeviceType.STRIPE_S700_DEVKIT -> DeviceTypeApi.STRIPE_S700_DEVKIT
        DeviceType.STRIPE_S710 -> DeviceTypeApi.STRIPE_S710
        DeviceType.STRIPE_S710_DEVKIT -> DeviceTypeApi.STRIPE_S710_DEVKIT
        DeviceType.UNKNOWN -> null
    }
}

fun Location.toApi(): LocationApi {
    return LocationApi(
        address = address?.toApi(),
        displayName = displayName,
        id = id,
        livemode = livemode,
        metadata = metadata?.toHashMap() ?: hashMapOf()
    )
}

fun Address.toApi(): AddressApi {
    return AddressApi(
        city = city,
        country = country,
        line1 = line1,
        line2 = line2,
        postalCode = postalCode,
        state = state
    )
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
        ReaderDisplayMessage.MULTIPLE_CONTACTLESS_CARDS_DETECTED ->
            ReaderDisplayMessageApi.MULTIPLE_CONTACTLESS_CARDS_DETECTED
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
        requiredAt = requiredAtMs,
        settingsVersion = settingsVersion,
        timeEstimate = durationEstimate.toApi(),
        version = version
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

fun ReaderSoftwareUpdate.UpdateDurationEstimate.toApi(): UpdateTimeEstimateApi {
    return when (this) {
        ReaderSoftwareUpdate.UpdateDurationEstimate.LESS_THAN_ONE_MINUTE ->
            UpdateTimeEstimateApi.LESS_THAN_ONE_MINUTE
        ReaderSoftwareUpdate.UpdateDurationEstimate.ONE_TO_TWO_MINUTES ->
            UpdateTimeEstimateApi.ONE_TO_TWO_MINUTES
        ReaderSoftwareUpdate.UpdateDurationEstimate.TWO_TO_FIVE_MINUTES ->
            UpdateTimeEstimateApi.TWO_TO_FIVE_MINUTES
        ReaderSoftwareUpdate.UpdateDurationEstimate.FIVE_TO_FIFTEEN_MINUTES ->
            UpdateTimeEstimateApi.FIVE_TO_FIFTEEN_MINUTES
    }
}

// PARAMS

fun DiscoveryConfigurationApi.toHost(): DiscoveryConfiguration? {
    return when (this) {
        is BluetoothDiscoveryConfigurationApi ->
            DiscoveryConfiguration.BluetoothDiscoveryConfiguration(
                isSimulated = isSimulated,
                timeout = timeout?.let { microsecondsToSeconds(it) } ?: 0
            )
        is BluetoothProximityDiscoveryConfigurationApi -> null
        is HandoffDiscoveryConfigurationApi -> DiscoveryConfiguration.HandoffDiscoveryConfiguration()
        is InternetDiscoveryConfigurationApi ->
            DiscoveryConfiguration.InternetDiscoveryConfiguration(
                isSimulated = isSimulated,
                location = locationId,
                timeout = timeout?.let { microsecondsToSeconds(it) } ?: 0
            )
        is TapToPayDiscoveryConfigurationApi ->
            DiscoveryConfiguration.TapToPayDiscoveryConfiguration(
                isSimulated = isSimulated
            )
        is UsbDiscoveryConfigurationApi ->
            DiscoveryConfiguration.UsbDiscoveryConfiguration(
                isSimulated = isSimulated,
                timeout = timeout?.let { microsecondsToSeconds(it) } ?: 0
            )
    }
}

fun DeviceTypeApi.toHost(): DeviceType? {
    return when (this) {
        DeviceTypeApi.CHIPPER1_X -> DeviceType.CHIPPER_1X
        DeviceTypeApi.CHIPPER2_X -> DeviceType.CHIPPER_2X
        DeviceTypeApi.STRIPE_M2 -> DeviceType.STRIPE_M2
        DeviceTypeApi.TAP_TO_PAY -> DeviceType.TAP_TO_PAY_DEVICE
        DeviceTypeApi.VERIFONE_P400 -> DeviceType.VERIFONE_P400
        DeviceTypeApi.WISE_CUBE -> DeviceType.WISECUBE
        DeviceTypeApi.WISE_PAD3 -> DeviceType.WISEPAD_3
        DeviceTypeApi.WISE_POS_E -> DeviceType.WISEPOS_E
        DeviceTypeApi.WISE_PAD3S -> DeviceType.WISEPAD_3S
        DeviceTypeApi.WISE_POS_E_DEVKIT -> DeviceType.WISEPOS_E_DEVKIT
        DeviceTypeApi.ETNA -> DeviceType.ETNA
        DeviceTypeApi.STRIPE_S700 -> DeviceType.STRIPE_S700
        DeviceTypeApi.STRIPE_S700_DEVKIT -> DeviceType.STRIPE_S700_DEVKIT
        DeviceTypeApi.STRIPE_S710 -> DeviceType.STRIPE_S710
        DeviceTypeApi.STRIPE_S710_DEVKIT -> DeviceType.STRIPE_S710_DEVKIT
    }
}

fun CartApi.toHost(): Cart {
    return Cart.Builder(
        currency = currency,
        tax = tax,
        total = total,
        lineItems = lineItems.map { it.toHost() }
    )
        .build()
}

fun CartLineItemApi.toHost(): CartLineItem {
    return CartLineItem.Builder(
        description = description,
        quantity = quantity.toInt(),
        amount = amount
    )
        .build()
}

// EXTRA

fun ConnectionStatus.toApi(): ConnectionStatusApi {
    return when (this) {
        ConnectionStatus.NOT_CONNECTED -> ConnectionStatusApi.NOT_CONNECTED
        ConnectionStatus.CONNECTING -> ConnectionStatusApi.CONNECTING
        ConnectionStatus.CONNECTED -> ConnectionStatusApi.CONNECTED
        ConnectionStatus.DISCOVERING -> ConnectionStatusApi.DISCOVERING
    }
}

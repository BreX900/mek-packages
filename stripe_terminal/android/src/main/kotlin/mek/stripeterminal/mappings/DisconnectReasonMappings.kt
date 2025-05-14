package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.DisconnectReason
import mek.stripeterminal.api.DisconnectReasonApi

fun DisconnectReason.toApi(): DisconnectReasonApi {
    return when (this) {
        DisconnectReason.UNKNOWN -> DisconnectReasonApi.UNKNOWN
        DisconnectReason.DISCONNECT_REQUESTED -> DisconnectReasonApi.DISCONNECT_REQUESTED
        DisconnectReason.REBOOT_REQUESTED -> DisconnectReasonApi.REBOOT_REQUESTED
        DisconnectReason.SECURITY_REBOOT -> DisconnectReasonApi.SECURITY_REBOOT
        DisconnectReason.CRITICALLY_LOW_BATTERY -> DisconnectReasonApi.CRITICALLY_LOW_BATTERY
        DisconnectReason.POWERED_OFF -> DisconnectReasonApi.POWERED_OFF
        DisconnectReason.BLUETOOTH_DISABLED -> DisconnectReasonApi.BLUETOOTH_DISABLED
        DisconnectReason.USB_DISCONNECTED -> DisconnectReasonApi.USB_DISCONNECTED
        DisconnectReason.IDLE_POWER_DOWN -> DisconnectReasonApi.IDLE_POWER_DOWN
    }
}

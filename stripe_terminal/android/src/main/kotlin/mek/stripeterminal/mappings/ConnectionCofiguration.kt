package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.ConnectionConfiguration
import mek.stripeterminal.api.BluetoothConnectionConfigurationApi
import mek.stripeterminal.api.ConnectionConfigurationApi
import mek.stripeterminal.api.HandoffConnectionConfigurationApi
import mek.stripeterminal.api.InternetConnectionConfigurationApi
import mek.stripeterminal.api.TapToPayConnectionConfigurationApi
import mek.stripeterminal.api.UsbConnectionConfigurationApi
import mek.stripeterminal.plugin.ReaderDelegatePlugin

fun ConnectionConfigurationApi.toHost(readerDelegate: ReaderDelegatePlugin): ConnectionConfiguration {
    return when(this) {
        is BluetoothConnectionConfigurationApi -> ConnectionConfiguration.BluetoothConnectionConfiguration(
            locationId = locationId,
            autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect,
            bluetoothReaderListener = readerDelegate
        )
//        is EmbeddedConnectionConfigurationApi -> ConnectionConfiguration.EmbeddedConnectionConfiguration(
//            posConnectionType = ,
//            listener = readerDelegate,
//            supportsOfflineMode = supportsOfflineMode,
//            supportsOfflineSetupIntents = supportsOfflineSetupIntents,
//            shouldActivateWithExpandedLocation = shouldActivateWithExpandedLocation,
//            shouldGenerateOfflineSessionToken = shouldGenerateOfflineSessionToken,
//        )
        is HandoffConnectionConfigurationApi -> ConnectionConfiguration.HandoffConnectionConfiguration(
            handoffReaderListener = readerDelegate,
        )
        is InternetConnectionConfigurationApi -> ConnectionConfiguration.InternetConnectionConfiguration(
            failIfInUse = failIfInUse,
            internetReaderListener = readerDelegate,
        )
        is TapToPayConnectionConfigurationApi -> ConnectionConfiguration.BluetoothConnectionConfiguration(
            locationId = locationId,
            autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect,
            bluetoothReaderListener = readerDelegate
        )
        is UsbConnectionConfigurationApi -> ConnectionConfiguration.UsbConnectionConfiguration(
            locationId = locationId,
            autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect,
            usbReaderListener = readerDelegate
        )
    }
}
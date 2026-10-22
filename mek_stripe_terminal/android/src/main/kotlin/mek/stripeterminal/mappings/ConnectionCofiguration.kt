package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.ConnectionConfiguration
import AppsOnDevicesConnectionConfigurationApi
import BluetoothConnectionConfigurationApi
import ConnectionConfigurationApi
import InternetConnectionConfigurationApi
import TapToPayConnectionConfigurationApi
import UsbConnectionConfigurationApi
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
        is AppsOnDevicesConnectionConfigurationApi -> ConnectionConfiguration.AppsOnDevicesConnectionConfiguration(
            appsOnDevicesListener = readerDelegate,
        )
//        is HandoffConnectionConfigurationApi -> ConnectionConfiguration.AppsOnDevicesConnectionConfiguration(
//            appsOnDevicesListener = readerDelegate,
//        )
        is InternetConnectionConfigurationApi -> ConnectionConfiguration.InternetConnectionConfiguration(
            failIfInUse = failIfInUse,
            internetReaderListener = readerDelegate,
        )
        is TapToPayConnectionConfigurationApi -> ConnectionConfiguration.TapToPayConnectionConfiguration(
            locationId = locationId,
            autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect,
            tapToPayReaderListener = readerDelegate
        )
        is UsbConnectionConfigurationApi -> ConnectionConfiguration.UsbConnectionConfiguration(
            locationId = locationId,
            autoReconnectOnUnexpectedDisconnect = autoReconnectOnUnexpectedDisconnect,
            usbReaderListener = readerDelegate
        )
    }
}

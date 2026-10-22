package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.DiscoveryConfiguration
import com.stripe.stripeterminal.external.models.EasyConnectConfiguration
import com.stripe.stripeterminal.external.models.EasyConnectConfiguration.AppsOnDevicesEasyConnectionConfiguration
import com.stripe.stripeterminal.external.models.EasyConnectConfiguration.InternetEasyConnectConfiguration
import com.stripe.stripeterminal.external.models.EasyConnectConfiguration.TapToPayEasyConnectConfiguration
import com.stripe.stripeterminal.external.models.ConnectionConfiguration.AppsOnDevicesConnectionConfiguration
import com.stripe.stripeterminal.external.models.ConnectionConfiguration.InternetConnectionConfiguration
import com.stripe.stripeterminal.external.models.ConnectionConfiguration.TapToPayConnectionConfiguration
import AppsOnDevicesEasyConnectionConfigurationApi
import ConnectionConfigurationApi
import DiscoveryConfigurationApi
import EasyConnectConfigurationApi
import InternetEasyConnectConfigurationApi
import TapToPayEasyConnectConfigurationApi
import mek.stripeterminal.plugin.ReaderDelegatePlugin

fun EasyConnectConfigurationApi.toHost(readerDelegate: ReaderDelegatePlugin): EasyConnectConfiguration {
    return when (this) {
        is InternetEasyConnectConfigurationApi -> InternetEasyConnectConfiguration(
            discoveryConfiguration = requireInternetDiscovery(discoveryConfiguration),
            connectionConfiguration = requireInternetConnection(connectionConfiguration, readerDelegate)
        )
        is AppsOnDevicesEasyConnectionConfigurationApi -> AppsOnDevicesEasyConnectionConfiguration(
            discoveryConfiguration = DiscoveryConfiguration.AppsOnDevicesDiscoveryConfiguration(),
            connectionConfiguration = requireAppsOnDevicesConnection(connectionConfiguration, readerDelegate)
        )
        is TapToPayEasyConnectConfigurationApi -> TapToPayEasyConnectConfiguration(
            discoveryConfiguration = requireTapToPayDiscovery(discoveryConfiguration),
            connectionConfiguration = requireTapToPayConnection(connectionConfiguration, readerDelegate)
        )
    }
}

private fun requireInternetDiscovery(
    discoveryConfiguration: DiscoveryConfigurationApi,
): DiscoveryConfiguration.InternetDiscoveryConfiguration {
    val host = discoveryConfiguration.toHost()
        ?: throw IllegalArgumentException("Discovery method not supported")
    return host as? DiscoveryConfiguration.InternetDiscoveryConfiguration
        ?: throw IllegalArgumentException("Internet discovery configuration required")
}

private fun requireTapToPayDiscovery(
    discoveryConfiguration: DiscoveryConfigurationApi,
): DiscoveryConfiguration.TapToPayDiscoveryConfiguration {
    val host = discoveryConfiguration.toHost()
        ?: throw IllegalArgumentException("Discovery method not supported")
    return host as? DiscoveryConfiguration.TapToPayDiscoveryConfiguration
        ?: throw IllegalArgumentException("TapToPay discovery configuration required")
}

private fun requireInternetConnection(
    connectionConfiguration: ConnectionConfigurationApi,
    readerDelegate: ReaderDelegatePlugin,
): InternetConnectionConfiguration {
    val host = connectionConfiguration.toHost(readerDelegate)
    return host as? InternetConnectionConfiguration
        ?: throw IllegalArgumentException("Internet connection configuration required")
}

private fun requireAppsOnDevicesConnection(
    connectionConfiguration: ConnectionConfigurationApi,
    readerDelegate: ReaderDelegatePlugin,
): AppsOnDevicesConnectionConfiguration {
    val host = connectionConfiguration.toHost(readerDelegate)
    return host as? AppsOnDevicesConnectionConfiguration
        ?: throw IllegalArgumentException("AppsOnDevices connection configuration required")
}

private fun requireTapToPayConnection(
    connectionConfiguration: ConnectionConfigurationApi,
    readerDelegate: ReaderDelegatePlugin,
): TapToPayConnectionConfiguration {
    val host = connectionConfiguration.toHost(readerDelegate)
    return host as? TapToPayConnectionConfiguration
        ?: throw IllegalArgumentException("TapToPay connection configuration required")
}

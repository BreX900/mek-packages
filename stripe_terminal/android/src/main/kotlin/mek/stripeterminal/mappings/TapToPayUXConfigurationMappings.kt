package mek.stripeterminal.mappings

import mek.stripeterminal.api.TapToPayUxConfigurationApi
import com.stripe.stripeterminal.external.models.TapToPayUxConfiguration
import mek.stripeterminal.api.TapToPayUxConfigurationColorSchemeApi
import mek.stripeterminal.api.TapToPayUxConfigurationTapZoneApi
import mek.stripeterminal.api.TapToPayUxConfigurationTapZoneIndicatorApi
import mek.stripeterminal.api.TapToPayUxConfigurationTapZonePositionApi
import mek.stripeterminal.api.TapToPayUxConfigurationDarkModeApi


fun TapToPayUxConfigurationApi.toHost(): TapToPayUxConfiguration {
    val builder = TapToPayUxConfiguration.Builder();
    if (tapZone != null) builder.tapZone(tapZone.toHost())
    if (colors != null) builder.colors(colors.toHost())
    if (darkMode != null) builder.darkMode(darkMode.toHost())
    return builder.build()
}

fun TapToPayUxConfigurationTapZoneApi.toHost(): TapToPayUxConfiguration.TapZone {
    val builder = TapToPayUxConfiguration.TapZone.Manual.Builder()
    if (indicator != null) builder.indicator(indicator.toHost())
    if (position != null) builder.position(position.toHost())
    return builder.build()
}

fun TapToPayUxConfigurationTapZoneIndicatorApi.toHost(): TapToPayUxConfiguration.TapZoneIndicator {
    return when (this) {
        TapToPayUxConfigurationTapZoneIndicatorApi.ABOVE -> TapToPayUxConfiguration.TapZoneIndicator.ABOVE
        TapToPayUxConfigurationTapZoneIndicatorApi.BELOW -> TapToPayUxConfiguration.TapZoneIndicator.BELOW
        TapToPayUxConfigurationTapZoneIndicatorApi.FRONT -> TapToPayUxConfiguration.TapZoneIndicator.FRONT
        TapToPayUxConfigurationTapZoneIndicatorApi.BEHIND -> TapToPayUxConfiguration.TapZoneIndicator.BEHIND
    }
}

fun TapToPayUxConfigurationTapZonePositionApi.toHost(): TapToPayUxConfiguration.TapZonePosition {
    return TapToPayUxConfiguration.TapZonePosition.Manual(xBias.toFloat(), yBias.toFloat());
}

fun TapToPayUxConfigurationColorSchemeApi.toHost(): TapToPayUxConfiguration.ColorScheme {
    val builder = TapToPayUxConfiguration.ColorScheme.Builder()
    if (primary != null) builder.primary(TapToPayUxConfiguration.Color.Value(primary.toInt()))
    if (success != null) builder.success(TapToPayUxConfiguration.Color.Value(success.toInt()))
    if (error != null) builder.primary(TapToPayUxConfiguration.Color.Value(error.toInt()))
    return builder.build()
}

fun TapToPayUxConfigurationDarkModeApi.toHost(): TapToPayUxConfiguration.DarkMode {
    return when (this) {
        TapToPayUxConfigurationDarkModeApi.SYSTEM -> TapToPayUxConfiguration.DarkMode.SYSTEM
        TapToPayUxConfigurationDarkModeApi.LIGHT -> TapToPayUxConfiguration.DarkMode.LIGHT
        TapToPayUxConfigurationDarkModeApi.DARK -> TapToPayUxConfiguration.DarkMode.DARK
    }
}

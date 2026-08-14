package mek.stripeterminal.mappings

import mek.stripeterminal.api.TapToPayUxConfigurationApi
import com.stripe.stripeterminal.external.models.TapToPayUxConfiguration
import mek.stripeterminal.api.TapToPayUxConfigurationColorSchemeApi
import mek.stripeterminal.api.TapToPayUxConfigurationTapZoneApi
import mek.stripeterminal.api.TapToPayUxConfigurationTapZoneIndicatorApi
import mek.stripeterminal.api.TapToPayUxConfigurationDarkModeApi


fun TapToPayUxConfigurationApi.toHost(): TapToPayUxConfiguration {
    val builder = TapToPayUxConfiguration.Builder();
    if (tapZone != null) builder.tapZone(tapZone.toHost())
    if (colors != null) builder.colors(colors.toHost())
    if (darkMode != null) builder.darkMode(darkMode.toHost())
    return builder.build()
}

fun TapToPayUxConfigurationTapZoneApi.toHost(): TapToPayUxConfiguration.TapZone {
    val xBias = position?.xBias?.toFloat()
    val yBias = position?.yBias?.toFloat()
    return when (indicator) {
        TapToPayUxConfigurationTapZoneIndicatorApi.LEFT ->
            if (yBias != null) TapToPayUxConfiguration.TapZone.Left(yBias)
            else TapToPayUxConfiguration.TapZone.Left()
        TapToPayUxConfigurationTapZoneIndicatorApi.RIGHT ->
            if (yBias != null) TapToPayUxConfiguration.TapZone.Right(yBias)
            else TapToPayUxConfiguration.TapZone.Right()
        TapToPayUxConfigurationTapZoneIndicatorApi.ABOVE ->
            if (xBias != null) TapToPayUxConfiguration.TapZone.Above(xBias)
            else TapToPayUxConfiguration.TapZone.Above()
        TapToPayUxConfigurationTapZoneIndicatorApi.BELOW ->
            if (xBias != null) TapToPayUxConfiguration.TapZone.Below(xBias)
            else TapToPayUxConfiguration.TapZone.Below()
        TapToPayUxConfigurationTapZoneIndicatorApi.FRONT ->
            if (xBias != null && yBias != null) TapToPayUxConfiguration.TapZone.Front(xBias, yBias)
            else TapToPayUxConfiguration.TapZone.Front()
        TapToPayUxConfigurationTapZoneIndicatorApi.BEHIND ->
            if (xBias != null && yBias != null) TapToPayUxConfiguration.TapZone.Behind(xBias, yBias)
            else TapToPayUxConfiguration.TapZone.Behind()
        null -> TapToPayUxConfiguration.TapZone.Default
    }
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

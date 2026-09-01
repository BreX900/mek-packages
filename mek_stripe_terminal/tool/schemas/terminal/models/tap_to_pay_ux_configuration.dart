/// Configuration for the user experience (UX) of the Tap to Pay screen. This configuration is only
/// used for the Tap to Pay reader to customize the appearance of the Tap to Pay screen. There are
/// three main components to the configuration:
/// - The type and position of the tap zone indicator, which directs the user where to tap their payment method.
/// - The overall theme for this screen, either light or dark mode.
/// - The color scheme for this screen.
class TapToPayUxConfigurationApi {
  final TapToPayUxConfigurationTapZoneApi? tapZone;
  final TapToPayUxConfigurationColorSchemeApi? colors;
  final TapToPayUxConfigurationDarkModeApi? darkMode;

  const TapToPayUxConfigurationApi({this.tapZone, this.colors, this.darkMode});
}

class TapToPayUxConfigurationTapZoneApi {
  final TapToPayUxConfigurationTapZoneIndicatorApi? indicator;
  final TapToPayUxConfigurationTapZonePositionApi? position;

  const TapToPayUxConfigurationTapZoneApi({this.indicator, this.position});
}

enum TapToPayUxConfigurationTapZoneIndicatorApi { above, below, front, behind, left, right }

class TapToPayUxConfigurationTapZonePositionApi {
  final double xBias;
  final double yBias;

  const TapToPayUxConfigurationTapZonePositionApi({required this.xBias, required this.yBias});
}

class TapToPayUxConfigurationColorSchemeApi {
  /// The color value in the form 0xAARRGGBB.
  final int? primary;

  /// The color value in the form 0xAARRGGBB.
  final int? success;

  /// The color value in the form 0xAARRGGBB.
  final int? error;

  const TapToPayUxConfigurationColorSchemeApi({this.primary, this.success, this.error});
}

enum TapToPayUxConfigurationDarkModeApi { system, light, dark }

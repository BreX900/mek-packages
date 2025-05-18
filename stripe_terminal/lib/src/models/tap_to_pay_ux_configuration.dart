/// Configuration for the user experience (UX) of the Tap to Pay screen. This configuration is only
/// used for the Tap to Pay reader to customize the appearance of the Tap to Pay screen. There are
/// three main components to the configuration:
/// - The type and position of the tap zone indicator, which directs the user where to tap their payment method.
/// - The overall theme for this screen, either light or dark mode.
/// - The color scheme for this screen.
class TapToPayUxConfiguration {
  final TapToPayUxConfigurationTapZone? tapZone;
  final TapToPayUxConfigurationColorScheme? colors;
  final TapToPayUxConfigurationDarkMode? darkMode;

  const TapToPayUxConfiguration({
    this.tapZone,
    this.colors,
    this.darkMode,
  });
}

class TapToPayUxConfigurationTapZone {
  final TapToPayUxConfigurationTapZoneIndicator? indicator;
  final TapToPayUxConfigurationTapZonePosition? position;

  const TapToPayUxConfigurationTapZone({
    this.indicator,
    this.position,
  });
}

enum TapToPayUxConfigurationTapZoneIndicator {
  above,
  below,
  front,
  behind,
}

class TapToPayUxConfigurationTapZonePosition {
  final double xBias;
  final double yBias;

  const TapToPayUxConfigurationTapZonePosition({
    required this.xBias,
    required this.yBias,
  });
}

class TapToPayUxConfigurationColorScheme {
  /// The color value in the form 0xAARRGGBB.
  final int? primary;

  /// The color value in the form 0xAARRGGBB.
  final int? success;

  /// The color value in the form 0xAARRGGBB.
  final int? error;

  const TapToPayUxConfigurationColorScheme({
    this.primary,
    this.success,
    this.error,
  });
}

enum TapToPayUxConfigurationDarkMode {
  system,
  light,
  dark,
}

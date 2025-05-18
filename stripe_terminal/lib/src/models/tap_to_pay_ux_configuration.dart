/// The `TapToPayUxConfiguration` class is used to configure the UX of the Tap to Pay flow.
///
/// Do not create new instances of this class. Instead, set the properties via [Terminal.setTapToPayUxConfiguration].
class TapToPayUXConfiguration {
  final TapToPayUxConfigurationTapZone? tapZone;
  final TapToPayUxConfigurationColors? colors;
  final TapToPayUxConfigurationTheme? theme;

  const TapToPayUXConfiguration({
    this.tapZone,
    this.colors,
    this.theme,
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
  deviceDefault,
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

class TapToPayUxConfigurationColors {
  final String? primary;
  final String? success;
  final String? error;

  const TapToPayUxConfigurationColors({
    this.primary,
    this.success,
    this.error,
  });
}

enum TapToPayUxConfigurationTheme {
  system,
  light,
  dark,
}

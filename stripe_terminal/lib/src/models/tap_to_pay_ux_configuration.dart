/// The `TapToPayUxConfiguration` class is used to configure the UX of the Tap to Pay flow.
///
/// Do not create new instances of this class. Instead, set the properties via [Terminal.setTapToPayUxConfiguration].
class TapToPayUXConfiguration {
  TapToPayUxConfigurationTapZone? tapZone;
  TapToPayUxConfigurationColors? colors;
  TapToPayUxConfigurationTheme? theme;

  TapToPayUXConfiguration({
    this.tapZone,
    this.colors,
    this.theme,
  });
}

class TapToPayUxConfigurationTapZone {
  TapToPayUxConfigurationTapZoneIndicator? indicator;
  TapToPayUxConfigurationTapZonePosition? position;

  TapToPayUxConfigurationTapZone({
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
  double xBias;
  double yBias;

  TapToPayUxConfigurationTapZonePosition({
    required this.xBias,
    required this.yBias,
  });
}

class TapToPayUxConfigurationColors {
  String? primary;
  String? success;
  String? error;

  TapToPayUxConfigurationColors({
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

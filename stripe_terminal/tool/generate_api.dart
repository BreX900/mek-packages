import 'package:one_for_all_generator/one_for_all_generator.dart';

void main() async {
  await OneForAll.from(
    options: const OneForAllOptions(
      apiFile: 'lib/src/platform/stripe_terminal_platform.dart',
      extraApiFiles: [
        'lib/src/stripe_terminal_exception.dart',
      ],
      hostClassSuffix: 'Api',
      codecs: ApiPlatformCodec.values,
    ),
    dartOptions: const DartOptions(),
    kotlinOptions: const KotlinOptions(
      package: 'mek.stripeterminal.api',
      outputFile: 'android/src/main/kotlin/mek/stripeterminal/api/StripeTerminalApi.kt',
    ),
    swiftOptions: const SwiftOptions(
      outputFile: 'ios/Classes/Api/StripeTerminalApi.swift',
    ),
  ).build();
}

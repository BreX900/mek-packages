import 'package:one_for_all_generator/one_for_all_generator.dart';

void main() async {
  await OneForAll.from(
    options: const OneForAllOptions(
      apiFile: 'lib/src/platform/terminal_platform.dart',
      extraApiFiles: [
        'lib/src/terminal_exception.dart',
      ],
      hostClassSuffix: 'Api',
      packageName: 'mek_stripe_terminal',
      codecs: ApiPlatformCodec.values,
    ),
    dartOptions: const DartOptions(),
    kotlinOptions: const KotlinOptions(
      package: 'mek.stripeterminal.api',
      outputFile: 'android/src/main/kotlin/mek/stripeterminal/api/TerminalApi.kt',
    ),
    swiftOptions: const SwiftOptions(
      outputFile: 'ios/Classes/Api/TerminalApi.swift',
    ),
  ).build();
}

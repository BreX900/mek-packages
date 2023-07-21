import 'package:one_for_all_generator/one_for_all_generator.dart';

void main() async {
  await OneForAll.from(
    options: OneForAllOptions(
      apiFile: 'lib/src/stripe_terminal.dart',
      extraApiFiles: [
        'lib/src/stripe_terminal_exception.dart',
      ],
      hostClassSuffix: 'Api',
      codecs: const [ApiPlatformCodec.dateTime],
    ),
    dartOptions: const DartOptions(),
    kotlinOptions: const KotlinOptions(
      outputFile: 'android/src/main/kotlin/com/stripe_terminal/api/StripeTerminalApi.kt',
      package: 'com.stripe_terminal.api',
    ),
    swiftOptions: const SwiftOptions(
      outputFile: 'ios/Classes/StripeTerminalApi.swift',
    ),
  ).build();
}

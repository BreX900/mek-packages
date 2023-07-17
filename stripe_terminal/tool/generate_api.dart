import 'package:one_for_all_generator/one_for_all_generator.dart';

void main() async {
  await OneForAllGenerator(
    apiPath: 'lib/src/stripe_terminal.dart',
    kotlinPath: 'android/src/main/kotlin/com/stripe_terminal/api/StripeTerminalApi.kt',
    kotlinPackage: 'com.stripe_terminal.api',
    hostClassSuffix: 'Api',
  ).build();
}

import 'package:args/args.dart';
import 'package:one_for_all_generator/one_for_all_generator.dart';

void main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addOption('api-path', help: 'Scheme path', mandatory: true)
    ..addOption('kotlin-path', mandatory: true)
    ..addOption('kotlin-package', mandatory: true);
  final args = argParser.parse(arguments);

  await OneForAll.from(
    options: OneForAllOptions(
      apiFile: args['api-path'],
      hostClassSuffix: 'Api',
    ),
    dartOptions: DartOptions(),
    kotlinOptions: KotlinOptions(
      outputFile: args['kotlin-path'],
      package: args['kotlin-package'],
    ),
    swiftOptions: SwiftOptions(
      outputFile: '',
    ),
  ).build();
}

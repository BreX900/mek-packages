import 'package:args/args.dart';
import 'package:one_for_all_generator/one_for_all_generator.dart';

void main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addOption('api-path', help: 'Scheme path', mandatory: true)
    ..addOption('kotlin-path', mandatory: true)
    ..addOption('kotlin-package', mandatory: true);
  final args = argParser.parse(arguments);

  await OneForAllGenerator(
    apiPath: args['api-path'],
    hostClassSuffix: 'Api',
    kotlinPath: args['kotlin-path'],
    kotlinPackage: args['kotlin-package'],
  ).build();
}

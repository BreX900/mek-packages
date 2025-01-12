import 'package:args/args.dart';
import 'package:one_for_all_generator/one_for_all_generator.dart';
import 'package:one_for_all_generator/src/utils.dart';

void main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addOption('api-path', help: 'Scheme path', mandatory: true)
    ..addOption('host-class-suffix')
    ..addOption('kotlin-output-file')
    ..addOption('kotlin-package')
    ..addOption('swift-output-file')
    ..addFlag('help');
  final args = argParser.parse(arguments);

  if (args['help'] as bool) {
    report(argParser.usage);
    return;
  }

  final kotlinOutputFile = args['kotlin-output-file'] as String?;
  final kotlinPackage = args['kotlin-package'] as String?;
  KotlinOptions? kotlinOptions;
  if (kotlinOutputFile != null && kotlinPackage != null) {
    kotlinOptions = KotlinOptions(
      outputFile: kotlinOutputFile,
      package: kotlinPackage,
    );
  }

  final swiftOutputFile = args['swift-output-file'] as String?;
  SwiftOptions? swiftOptions;
  if (swiftOutputFile != null) {
    swiftOptions = SwiftOptions(
      outputFile: swiftOutputFile,
    );
  }

  await OneForAll.from(
    options: OneForAllOptions(
      apiFile: args['api-path'],
      hostClassSuffix: args['host-class-suffix'] ?? '',
    ),
    dartOptions: const DartOptions(),
    kotlinOptions: kotlinOptions,
    swiftOptions: swiftOptions,
  ).build();
}

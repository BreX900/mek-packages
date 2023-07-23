import 'package:one_for_all_generator/one_for_all_generator.dart';

class OneForAllOptions {
  final String apiFile;
  final List<String> extraApiFiles;
  final String hostClassSuffix;
  final List<ApiPlatformCodec> codecs;

  const OneForAllOptions({
    required this.apiFile,
    this.extraApiFiles = const [],
    this.hostClassSuffix = '',
    this.codecs = const [],
  });
}

class DartOptions {
  const DartOptions();
}

class KotlinOptions {
  final String outputFile;
  final String package;

  const KotlinOptions({
    required this.outputFile,
    required this.package,
  });
}

class SwiftOptions {
  final String outputFile;

  const SwiftOptions({
    required this.outputFile,
  });
}

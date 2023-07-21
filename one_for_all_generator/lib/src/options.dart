import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/one_for_all_generator.dart';
import 'package:source_gen/source_gen.dart';

class OneForAllOptions {
  final String apiFile;
  final List<String> extraApiFiles;
  final String hostClassSuffix;
  final List<ApiPlatformCodec> codecs;

  OneForAllOptions({
    required this.apiFile,
    this.extraApiFiles = const [],
    this.hostClassSuffix = '',
    this.codecs = const [],
  });

  late final _codecs = codecs.map((e) => (TypeChecker.fromRuntime(e.type), e)).toList();

  Iterable<ApiCodec> readCodecs(PlatformApi platform) => codecs.map((e) => e.read(platform));

  bool hasCodec(DartType type) => _codecs.any((e) => e.$1.isExactlyType(type));

  ApiCodec? findCodec(PlatformApi platform, DartType type) =>
      _codecs.firstWhereOrNull((e) => e.$1.isExactlyType(type))?.$2.read(platform);
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

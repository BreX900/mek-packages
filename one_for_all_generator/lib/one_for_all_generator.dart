import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';
import 'package:one_for_all_generator/src/codecs/plataforms/dart_codecs.dart';
import 'package:one_for_all_generator/src/codecs/plataforms/kotlin_codecs.dart';
import 'package:one_for_all_generator/src/codecs/plataforms/swift_codecs.dart';
import 'package:one_for_all_generator/src/generators/dart_api_builder.dart';
import 'package:one_for_all_generator/src/generators/kotlin_api_builder.dart';
import 'package:one_for_all_generator/src/generators/swift_api_builder.dart';
import 'package:one_for_all_generator/src/library_scanner.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:path/path.dart' as path_;
import 'package:source_gen/source_gen.dart';

export 'src/codecs/codecs.dart';
export 'src/options.dart';

typedef ApiBuildersCreator = List<ApiBuilder> Function(OneForAllOptions options);

class OneForAll {
  final OneForAllOptions options;
  final ApiBuildersCreator buildersCreator;

  const OneForAll({
    required this.options,
    required this.buildersCreator,
  });

  factory OneForAll.from({
    required OneForAllOptions options,
    List<ApiPlatformCodec> codecs = ApiPlatformCodec.values,
    DartOptions? dartOptions,
    KotlinOptions? kotlinOptions,
    SwiftOptions? swiftOptions,
    ApiBuildersCreator? buildersCreator,
  }) {
    final platformsCodecs = Map.fromEntries(LanguageApi.values.map((platform) {
      final entries = codecs.map((e) => (TypeChecker.fromRuntime(e.type), e));
      return MapEntry(platform, entries.map((e) => (e.$1, e.$2.read(platform))).toList());
    }));
    return OneForAll(
      options: options,
      buildersCreator: (options) => [
        if (dartOptions != null)
          DartApiBuilder(
            options,
            dartOptions,
            DartApiCodes(options, platformsCodecs[LanguageApi.dart]!),
          ),
        if (kotlinOptions != null)
          KotlinApiBuilder(
            options,
            kotlinOptions,
            KotlinApiCodes(options, platformsCodecs[LanguageApi.kotlin]!),
          ),
        if (swiftOptions != null)
          SwiftApiBuilder(
            options,
            swiftOptions,
            SwiftApiCodes(options, platformsCodecs[LanguageApi.swift]!),
          ),
        ...?buildersCreator?.call(options),
      ],
    );
  }

  Future<void> build() async {
    print('Scanning...');
    // TODO: Check if file exists
    final apiAbsolutePaths = [options.apiFile, ...options.extraApiFiles]
        .map((e) => path_.absolute(path_.normalize(e)))
        .toList();

    final collection = AnalysisContextCollection(
      includedPaths: apiAbsolutePaths,
    );

    final scanner = LibraryScanner(options: options);

    await Future.wait(collection.contexts.expand((context) {
      return context.contextRoot.analyzedFiles().map((filePath) async {
        print('Reading... $filePath');
        final session = context.currentSession;
        final result = await session.getLibraryByUri('file://$filePath');
        if (result is! LibraryElementResult) {
          print(result);
          return;
        }

        print('Scanning... ${result.element.source.uri}');
        scanner.scan(result.element);
      });
    }));

    print('Building...');
    final scanResult = scanner.result;
    final builders = buildersCreator(options);

    for (final builder in builders) {
      scanResult.hostApiHandles.forEach(builder.writeHostApiClass);
      scanResult.flutterApiHandlers.forEach(builder.writeFlutterApiClass);
      scanResult.serializableHandlers.forEach(builder.writeSerializable);
    }

    print('Writing...');
    await Future.wait(builders.map((builder) async {
      await File(builder.outputFile).writeAsString(await builder.build());
    }));
  }
}

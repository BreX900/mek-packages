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
import 'package:one_for_all_generator/src/utils.dart';
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
      final entries = codecs.map((e) => (TypeChecker.typeNamed(e.type), e));
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
    report('Scanning...');
    // TODO: Check if file exists
    final apiAbsolutePaths = [options.apiFile, ...options.extraApiFiles]
        .map((e) => path_.absolute(path_.normalize(e)))
        .toList();

    report('[DEBUG] apiAbsolutePaths: $apiAbsolutePaths');

    final collection = AnalysisContextCollection(
      includedPaths: apiAbsolutePaths,
    );

    final scanner = LibraryScanner(options: options);
    var fileCount = 0;

    await Future.wait(collection.contexts.expand((context) {
      report('[DEBUG] Context root: ${context.contextRoot.root.path}');
      final analyzedFiles = context.contextRoot.analyzedFiles().toList();
      report('[DEBUG] Analyzed files in context: ${analyzedFiles.length}');
      for (final f in analyzedFiles) {
        report('[DEBUG] -> File: $f');
      }
      return analyzedFiles.map((filePath) async {
        try {
          report('Reading... $filePath');
          final session = context.currentSession;
          final fileUri = Uri.file(filePath);
          report('[DEBUG] Converted to URI: $fileUri');
          final result = await session.getLibraryByUri(fileUri.toString());
          if (result is! LibraryElementResult) {
            report('[DEBUG] NOT LibraryElementResult: ${result.runtimeType}');
            report(result);
            return;
          }

          report('Scanning... ${result.element2.uri}');
          report('[DEBUG] Library name: ${result.element2.name}');
          scanner.scan(result.element2);
          fileCount++;
        } catch (e, st) {
          report('[ERROR] Failed to process $filePath: $e\n$st');
        }
      });
    }));

    report('[DEBUG] Total files scanned: $fileCount');

    report('Building...');
    final scanResult = scanner.result;
    report(
        '[DEBUG] Found: hostApiHandles=${scanResult.hostApiHandles.length}, flutterApiHandlers=${scanResult.flutterApiHandlers.length}, serializableHandlers=${scanResult.serializableHandlers.length}');
    if (scanResult.hostApiHandles.isEmpty &&
        scanResult.flutterApiHandlers.isEmpty &&
        scanResult.serializableHandlers.isEmpty) {
      report('[WARNING] No APIs or serializable models found!');
    }
    final builders = buildersCreator(options);

    for (final builder in builders) {
      scanResult.hostApiHandles.forEach(builder.writeHostApiClass);
      scanResult.flutterApiHandlers.forEach(builder.writeFlutterApiClass);
      scanResult.serializableHandlers.forEach(builder.writeSerializable);
    }

    report('Writing...');
    await Future.wait(builders.map((builder) async {
      await File(builder.outputFile).writeAsString(await builder.build());
    }));
  }
}

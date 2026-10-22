import 'dart:async';

import 'package:build/build.dart';
import 'package:shelf_open_api_generator/src/dto/config.dart';
import 'package:shelf_open_api_generator/src/dto/pubspec.dart';
import 'package:shelf_open_api_generator/src/handlers/route_handler.dart';
import 'package:shelf_open_api_generator/src/handlers/routes_handler.dart';

Builder buildOpenApi(BuilderOptions options) {
  final config = Config.fromJson(options.config);
  var outputPath = config.outputPath;
  if (outputPath.startsWith('/')) outputPath = outputPath.substring(1);
  if (outputPath.endsWith('/')) outputPath = outputPath.substring(0, outputPath.length - 1);

  return OpenApiBuilder(
    buildExtensions: {
      'lib/{{}}.dart': ['$outputPath/{{}}.json', '$outputPath/{{}}.yaml'],
    },
    config: config,
  );
}

// https://github.com/dart-lang/build/blob/master/docs/writing_an_aggregate_builder.md
class OpenApiBuilder implements Builder {
  @override
  final Map<String, List<String>> buildExtensions;
  final Config config;

  OpenApiBuilder({required this.buildExtensions, required this.config});

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!config.enabled) return;

    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) return;

    final apiHandler = await OpenApiHandler.from(config, buildStep);
    if (apiHandler == null) return;

    final pubspec = await Pubspec.read(buildStep);

    final routes = OpenRouteFinder(
      schemasRegistry: apiHandler.schemasRegistry,
      strict: pubspec?.dependencies.containsKey('shelf_routing') ?? false,
    ).find(apiHandler.element);

    final results = apiHandler.code(pubspec, routes);

    for (final output in buildStep.allowedOutputs) {
      for (final (fileExtension, fileContent) in results) {
        if (output.extension != fileExtension) continue;
        await buildStep.writeAsString(output, fileContent);
      }
    }
  }
}

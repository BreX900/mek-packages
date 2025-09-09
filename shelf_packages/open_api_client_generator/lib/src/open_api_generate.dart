import 'dart:async';
import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:open_api_client_generator/src/api_specs.dart';
import 'package:open_api_client_generator/src/builders/build_api_class.dart';
import 'package:open_api_client_generator/src/builders/build_schema_class.dart';
import 'package:open_api_client_generator/src/client_codecs/client_codec.dart';
import 'package:open_api_client_generator/src/code_utils/codecs.dart';
import 'package:open_api_client_generator/src/options/context.dart';
import 'package:open_api_client_generator/src/options/options.dart';
import 'package:open_api_client_generator/src/plugins/plugin.dart';
import 'package:open_api_client_generator/src/serialization_codec/serialization_codec.dart';
import 'package:open_api_client_generator/src/utils/lg.dart';
import 'package:open_api_specification/open_api.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:path/path.dart' as path_;

Future<void> generateApi({
  required Options options,
  required SerializationCodec serializationCodec,
  required ClientCodec clientCodec,
  List<Plugin> plugins = const [],
  DartFormatter? formatter,
}) async {
  final timer = DateTime.now();
  lg.finest('StartAt: $timer');

  final works = <Future>[];
  final allPlugins = <Plugin>[
    if (clientCodec is Plugin) clientCodec as Plugin,
    if (serializationCodec is Plugin) serializationCodec as Plugin,
    if (serializationCodec.collectionCodec is Plugin) serializationCodec.collectionCodec as Plugin,
    ...plugins,
  ];
  await Future.wait(allPlugins.map((plugin) async => await plugin.onStart()));
  var specs = await readOpenApiWithRefs(options.input);
  specs = allPlugins.fold(specs, (specs, plugin) => plugin.onSpecifications(specs));
  lg.finest('ReadSpecs: ${DateTime.now().difference(timer)}');

  var openApi = OpenApi.fromJson(specs);
  openApi = allPlugins.fold(openApi, (openApi, plugin) => plugin.onOpenApi(openApi));
  lg.finest('ParseSpecs: ${DateTime.now().difference(timer)}');

  final versions = openApi.openapi.split('.');
  if (versions.length != 3) {
    final majorVersion = int.parse(versions[0]);
    if (majorVersion < 3 || majorVersion > 3) {
      throw StateError('Openapi version not supported ${openApi.openapi}');
    }
  }

  final emitter = DartEmitter(
    orderDirectives: true,
    useNullSafetySyntax: true,
    allocator: Allocator(),
  );
  formatter ??= DartFormatter(pageWidth: 100, languageVersion: DartFormatter.latestLanguageVersion);

  final codecs = ApiCodecs(options: options);

  final context = Context(options: options, codecs: codecs, components: openApi.components);

  // Api Class and data classes

  final apiFileName = '${options.outputApiFileTitle}.dart';
  final buildSchemaClass = BuildSchemaClass(context: context);
  final buildApiClass = BuildApiClass(
    context: context,
    clientCodec: clientCodec,
    dataCodec: serializationCodec,
    buildSchemaClass: buildSchemaClass,
  );

  var apiSpec = buildApiClass(openApi.paths);
  apiSpec = allPlugins.fold(apiSpec, (spec, plugin) => plugin.onApiClass(openApi, spec));

  final dataSpecs = buildSchemaClass.apiSpecs.map<Spec>((apiSpec) {
    switch (apiSpec) {
      case ApiClass():
        var spec = serializationCodec.buildDataClass(apiSpec);
        spec = allPlugins.fold(spec, (spec, plugin) => plugin.onDataClass(apiSpec.schema, spec));
        return spec;
      case ApiEnum():
        var spec = serializationCodec.buildDataEnum(apiSpec);
        spec = allPlugins.fold(spec, (spec, plugin) => plugin.onDataEnum(apiSpec.schema, spec));
        return spec;
    }
  });

  var librarySpec = Library(
    (b) => b
      ..ignoreForFile.addAll([
        'unnecessary_brace_in_string_interps',
        'no_leading_underscores_for_local_identifiers',
        'always_use_package_imports',
        'cast_nullable_to_non_nullable',
      ])
      ..directives.add(Directive.part('${path_.basenameWithoutExtension(apiFileName)}.g.dart'))
      ..body.add(apiSpec)
      ..body.addAll(dataSpecs),
  );
  librarySpec = allPlugins.fold(librarySpec, (spec, plugin) => plugin.onLibrary(openApi, spec));

  final page = formatter.format('${librarySpec.accept(emitter)}');
  works.add(File('${options.outputFolder}/$apiFileName').writeAsString(page));

  for (final plugin in allPlugins) {
    final result = plugin.onFinish();
    if (result is Future<void>) works.add(result);
  }

  await Future.wait(works);
  lg.finest('TotalTime: ${DateTime.now().difference(timer)}');
}

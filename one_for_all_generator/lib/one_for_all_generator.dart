import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';
import 'package:one_for_all_generator/src/codecs/plataforms/dart_codecs.dart';
import 'package:one_for_all_generator/src/codecs/plataforms/kotlin_codecs.dart';
import 'package:one_for_all_generator/src/codecs/plataforms/swift_codecs.dart';
import 'package:one_for_all_generator/src/generators/dart_api_builder.dart';
import 'package:one_for_all_generator/src/generators/kotlin_api_builder.dart';
import 'package:one_for_all_generator/src/generators/swift_api_builder.dart';
import 'package:one_for_all_generator/src/handlers.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:path/path.dart' as path_;
import 'package:source_gen/source_gen.dart';

export 'src/codecs/codecs.dart';
export 'src/options.dart';

typedef ApiBuildersCreator = List<ApiBuilder> Function(OneForAllOptions options);

class OneForAll {
  static const hostApiChecker = TypeChecker.fromRuntime(HostApi);
  static const flutterApiChecker = TypeChecker.fromRuntime(FlutterApi);
  static const serializableClassChecker = TypeChecker.fromRuntime(SerializableClass);
  static const serializableEnumChecker = TypeChecker.fromRuntime(SerializableEnum);

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
    final codecs = options.codecs.map((e) => (TypeChecker.fromRuntime(e.type), e)).toList();
    bool hasCodec(DartType type) => codecs.any((e) => e.$1.isExactlyType(type));

    final apiAbsolutePaths = [options.apiFile, ...options.extraApiFiles]
        .map((e) => path_.absolute(path_.normalize(e)))
        .toList();

    final collection = AnalysisContextCollection(
      includedPaths: apiAbsolutePaths,
    );

    final hostApiHandles = <HostApiHandler>{};
    final flutterApiHandlers = <FlutterApiHandler>{};
    final serializableClassHandlers = <InterfaceElement, SerializableClassHandler>{};
    final serializableEnumHandlers = <InterfaceElement, SerializableEnumHandler>{};

    void addDeepSerializables(
      DartType type, {
      bool flutterToHost = false,
      bool hostToFlutter = false,
    }) {
      if (hasCodec(type)) return;
      if (type.isDartCoreList || type.isDartCoreMap) {
        for (final typeArg in (type as ParameterizedType).typeArguments) {
          addDeepSerializables(
            typeArg,
            hostToFlutter: hostToFlutter,
            flutterToHost: flutterToHost,
          );
        }
        return;
      }
      if (type.isSupported) return;

      final element = type.element;
      if (element is! InterfaceElement) return;

      if (element is EnumElement) {
        final handler = serializableEnumHandlers.putIfAbsent(element, () {
          return SerializableEnumHandler.from(element);
        });
        final updatedHandler = handler.apply(
          flutterToHost: flutterToHost,
          hostToFlutter: hostToFlutter,
        );
        if (handler == updatedHandler) return;

        serializableEnumHandlers[element] = updatedHandler;
      } else if (element is ClassElement) {
        final handler = serializableClassHandlers.putIfAbsent(element, () {
          return SerializableClassHandler.from(element);
        });

        final updatedHandler = handler.apply(
          flutterToHost: flutterToHost,
          hostToFlutter: hostToFlutter,
        );
        if (handler == updatedHandler) return;

        serializableClassHandlers[element] = updatedHandler;

        for (final field in element.fields) {
          addDeepSerializables(
            field.type,
            hostToFlutter: hostToFlutter,
            flutterToHost: flutterToHost,
          );
        }
      }
    }

    void addApiSerializables(
      InterfaceElement element, {
      bool flutterToHost = false,
      bool hostToFlutter = false,
    }) {
      for (final method in element.methods) {
        if (!method.isSupported) continue;

        for (final parameter in method.parameters) {
          addDeepSerializables(
            parameter.type,
            flutterToHost: flutterToHost,
            hostToFlutter: hostToFlutter,
          );
        }

        addDeepSerializables(
          method.returnType.singleTypeArg,
          flutterToHost: hostToFlutter,
          hostToFlutter: flutterToHost,
        );
      }
    }

    for (final context in collection.contexts) {
      for (final filePath in context.contextRoot.analyzedFiles()) {
        final session = context.currentSession;
        final result = await session.getLibraryByUri('file://$filePath');

        if (result is! LibraryElementResult) {
          print(result);
          return;
        }
        final library = result.element;
        final libraryReader = LibraryReader(library);

        print('$filePath: Encoding');

        final serializableClassElements =
            libraryReader.classes.whereHasAnnotation(serializableClassChecker.firstAnnotationOf);
        for (final AnnotatedWithElement(:element) in serializableClassElements) {
          addDeepSerializables(element.thisType, flutterToHost: true, hostToFlutter: true);
        }
        final serializableEnumElements =
            libraryReader.enums.whereHasAnnotation(serializableEnumChecker.firstAnnotationOf);
        for (final AnnotatedWithElement(:element) in serializableEnumElements) {
          addDeepSerializables(element.thisType, flutterToHost: true, hostToFlutter: true);
        }

        hostApiHandles.addAll(
            libraryReader.annotatedWith(hostApiChecker).map((e) => HostApiHandler.of(options, e)));

        flutterApiHandlers.addAll(libraryReader
            .annotatedWith(flutterApiChecker)
            .map((e) => FlutterApiHandler.of(options, e)));
      }
    }

    for (final HostApiHandler(:element) in hostApiHandles) {
      addApiSerializables(element, flutterToHost: true);
    }

    for (final FlutterApiHandler(:element) in flutterApiHandlers) {
      addApiSerializables(element, hostToFlutter: true);
    }

    final builders = buildersCreator(options);

    for (final builder in builders) {
      hostApiHandles.forEach(builder.writeHostApiClass);
      flutterApiHandlers.forEach(builder.writeFlutterApiClass);
      serializableClassHandlers.values.forEach(builder.writeSerializableClass);
      serializableEnumHandlers.values.forEach(builder.writeSerializableEnum);
    }

    for (final builder in builders) {
      await File(builder.outputFile).writeAsString(builder.build());
    }
  }
}

extension<T extends Element> on Iterable<T> {
  Iterable<AnnotatedWithElement<T>> whereHasAnnotation(DartObject? Function(Element) finder) sync* {
    for (final element in this) {
      final annotation = finder(element);
      if (annotation == null) continue;
      yield AnnotatedWithElement(ConstantReader(annotation), element);
    }
  }
}

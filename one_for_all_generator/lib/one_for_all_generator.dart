import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/generators/dart_api_builder.dart';
import 'package:one_for_all_generator/src/generators/kotlin_api_builder.dart';
import 'package:one_for_all_generator/src/generators/swift_api_builder.dart';
import 'package:one_for_all_generator/src/handlers.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:path/path.dart' as path_;
import 'package:source_gen/source_gen.dart';

export 'src/options.dart';

typedef ApiBuildersCreator = List<ApiBuilder> Function(OneForAllOptions options);

class OneForAll {
  static const hostApiChecker = TypeChecker.fromRuntime(HostApiScheme);
  static const flutterApiChecker = TypeChecker.fromRuntime(FlutterApiScheme);
  static const serializableChecker = TypeChecker.fromRuntime(SerializableScheme);

  final OneForAllOptions options;
  final ApiBuildersCreator buildersCreator;

  const OneForAll({
    required this.options,
    required this.buildersCreator,
  });

  factory OneForAll.from({
    required OneForAllOptions options,
    DartOptions? dartOptions,
    KotlinOptions? kotlinOptions,
    SwiftOptions? swiftOptions,
    ApiBuildersCreator? buildersCreator,
  }) {
    return OneForAll(
      options: options,
      buildersCreator: (options) => [
        if (dartOptions != null) DartApiBuilder(options, dartOptions),
        if (kotlinOptions != null) KotlinApiBuilder(options, kotlinOptions),
        if (swiftOptions != null) SwiftApiBuilder(options, swiftOptions),
        ...?buildersCreator?.call(options),
      ],
    );
  }

  Future<void> build() async {
    final apiAbsolutePath = path_.absolute(path_.normalize(options.apiFile));

    final collection = AnalysisContextCollection(
      includedPaths: [apiAbsolutePath],
    );

    final hostApiHandles = <HostApiHandler>{};
    final flutterApiHandlers = <FlutterApiHandler>{};
    final serializableHandlers = <InterfaceElement, SerializableHandler>{};

    void addDeepSerializables(
      DartType type, {
      bool flutterToHost = false,
      bool hostToFlutter = false,
    }) {
      if (type.isDartCoreList) {
        type as ParameterizedType;
        addDeepSerializables(
          type.typeArguments[0],
          hostToFlutter: hostToFlutter,
          flutterToHost: flutterToHost,
        );
        return;
      }
      if (type.isDartCoreMap) {
        type as ParameterizedType;
        addDeepSerializables(
          type.typeArguments[0],
          hostToFlutter: hostToFlutter,
          flutterToHost: flutterToHost,
        );
        addDeepSerializables(
          type.typeArguments[1],
          hostToFlutter: hostToFlutter,
          flutterToHost: flutterToHost,
        );
        return;
      }
      if (type.isSupported) return;

      final element = type.element;
      if (element is! InterfaceElement) return;
      SerializableHandler? handler;
      if (element is EnumElement) {
        handler = serializableHandlers[element] ?? SerializableHandler<EnumElement>.of(element);
      } else if (element is ClassElement) {
        handler = serializableHandlers[element] ?? SerializableHandler<ClassElement>.of(element);
      }
      if (handler == null) return;

      final updateHandler = handler.apply(
        flutterToHost: flutterToHost,
        hostToFlutter: hostToFlutter,
      );
      if (handler == updateHandler) return;
      serializableHandlers[element] = updateHandler;

      for (final field in element.fields) {
        addDeepSerializables(
          field.type,
          hostToFlutter: hostToFlutter,
          flutterToHost: flutterToHost,
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

        hostApiHandles.addAll(libraryReader.annotatedWith(hostApiChecker).map(HostApiHandler.from));

        flutterApiHandlers
            .addAll(libraryReader.annotatedWith(flutterApiChecker).map(FlutterApiHandler.from));

        final serializableElements = libraryReader.annotatedWith(serializableChecker);
        for (final AnnotatedElement(:element) in serializableElements) {
          addDeepSerializables(
            (element as InterfaceElement).thisType,
            flutterToHost: true,
            hostToFlutter: true,
          );
        }
      }
    }

    final apiElements = [
      ...hostApiHandles.map((e) => e.element),
      ...flutterApiHandlers.map((e) => e.element),
    ];
    for (final element in apiElements) {
      for (final method in element.methods) {
        if (!method.isSupported) continue;

        for (final parameter in method.parameters) {
          addDeepSerializables(parameter.type, flutterToHost: true);
        }

        addDeepSerializables(method.returnType.singleTypeArg, hostToFlutter: true);
      }
    }

    final builders = buildersCreator(options);

    for (final builder in builders) {
      for (final handler in hostApiHandles) {
        builder.writeHostApiClass(handler);
      }

      for (final element in flutterApiHandlers) {
        builder.writeFlutterApiClass(element);
      }

      for (final handler in serializableHandlers.values) {
        print(handler);
        if (handler is SerializableHandler<EnumElement>) {
          builder.writeEnum(handler);
        } else if (handler is SerializableHandler<ClassElement>) {
          builder.writeSerializable(handler);
        }
      }
    }

    for (final builder in builders) {
      await File(builder.outputFile).writeAsString(builder.build());
    }
  }
}

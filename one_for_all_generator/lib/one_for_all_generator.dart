import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/code_generator.dart';
import 'package:one_for_all_generator/src/generators/dart_builder.dart';
import 'package:one_for_all_generator/src/generators/kotlin_builder.dart';
import 'package:one_for_all_generator/src/generators/swift_generator.dart';
import 'package:one_for_all_generator/src/handlers.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:path/path.dart' as path_;
import 'package:source_gen/source_gen.dart';

export 'src/options.dart';

class OneForAll {
  static const hostApiChecker = TypeChecker.fromRuntime(HostApiScheme);
  static const flutterApiChecker = TypeChecker.fromRuntime(FlutterApiScheme);
  static const serializableChecker = TypeChecker.fromRuntime(SerializableScheme);

  final OneForAllOptions options;
  final List<CodeGenerator> Function(OneForAllOptions options) generatorsBuilder;

  const OneForAll({
    required this.options,
    required this.generatorsBuilder,
  });

  factory OneForAll.from({
    required OneForAllOptions options,
    DartOptions? dartOptions,
    KotlinOptions? kotlinOptions,
    SwiftOptions? swiftOptions,
    List<CodeGenerator> generators = const [],
  }) {
    return OneForAll(
      options: options,
      generatorsBuilder: (options) => [
        if (dartOptions != null) DartGenerator(options, dartOptions),
        if (kotlinOptions != null) KotlinGenerator(options, kotlinOptions),
        if (swiftOptions != null) SwiftGenerator(options, swiftOptions),
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
        if (!method.isHostMethod) continue;

        for (final parameter in method.parameters) {
          addDeepSerializables(parameter.type, flutterToHost: true);
        }

        addDeepSerializables(method.returnType.singleTypeArg, hostToFlutter: true);
      }
    }

    final generators = generatorsBuilder(options);

    for (final generator in generators) {
      for (final handler in hostApiHandles) {
        generator.writeHostApiClass(handler);
      }

      for (final element in flutterApiHandlers) {
        generator.writeFlutterApiClass(element);
      }

      for (final handler in serializableHandlers.values) {
        print(handler);
        if (handler is SerializableHandler<EnumElement>) {
          generator.writeEnum(handler);
        } else if (handler is SerializableHandler<ClassElement>) {
          generator.writeSerializable(handler);
        }
      }
    }

    for (final generator in generators) {
      generator.writeToFile();
    }
  }
}

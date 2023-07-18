import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/code_generator.dart';
import 'package:one_for_all_generator/src/generators/dart_builder.dart';
import 'package:one_for_all_generator/src/generators/kotlin_builder.dart';
import 'package:one_for_all_generator/src/generators/swift_generator.dart';
import 'package:one_for_all_generator/src/handlers/api_class_handler.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:path/path.dart' as path_;
import 'package:source_gen/source_gen.dart';

export 'src/options.dart';

class OneForAll {
  static const hostApiChecker = TypeChecker.fromRuntime(HostApiScheme);
  static const flutterApiChecker = TypeChecker.fromRuntime(FlutterApiScheme);
  static const dataChecker = TypeChecker.fromRuntime(DataScheme);

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

    final hostApiHandles = <ApiClassHandler>{};
    final flutterApiElements = <ClassElement>{};
    final dataElements = <InterfaceElement>{};

    void writeDataClasses(DartType type) {
      if (type.isDartCoreList) {
        type as ParameterizedType;
        writeDataClasses(type.typeArguments[0]);
      }
      if (type.isDartCoreMap) {
        type as ParameterizedType;
        writeDataClasses(type.typeArguments[0]);
        writeDataClasses(type.typeArguments[1]);
      }
      if (type.isSupported) return;
      final element = type.element;

      if (element is! InterfaceElement) return;

      if (dataElements.contains(element)) return;

      dataElements.add(element);

      for (final field in element.fields) {
        writeDataClasses(field.type);
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

        // final apiClassElement = libraryReader.classes.firstWhereOrNull((e) => e.name == apiClassName);
        // if (apiClassElement != null) apiElements.add(apiClassElement);

        hostApiHandles
            .addAll(libraryReader.annotatedWith(hostApiChecker).map(ApiClassHandler.from));

        flutterApiElements.addAll(
            libraryReader.annotatedWith(flutterApiChecker).map((e) => e.element as ClassElement));

        libraryReader
            .annotatedWith(dataChecker)
            .map((e) => (e.element as InterfaceElement).thisType)
            .forEach(writeDataClasses);
      }
    }

    final apiElements = hostApiHandles.map((e) => e.element).followedBy(flutterApiElements);
    for (final element in apiElements) {
      for (final method in element.methods) {
        if (!method.isHostMethod) continue;

        for (final parameter in method.parameters) {
          writeDataClasses(parameter.type);
        }

        writeDataClasses(method.returnType.singleTypeArg);
      }
    }

    final generators = generatorsBuilder(options);

    for (final generator in generators) {
      for (final handler in hostApiHandles) {
        generator.writeHostApiClass(handler);
      }

      for (final element in flutterApiElements) {
        generator.writeFlutterApiClass(element);
      }

      for (final element in dataElements) {
        if (element is EnumElement) {
          generator.writeEnum(element);
        } else {
          generator.writeDataClass(element as ClassElement);
        }
      }
    }

    for (final generator in generators) {
      generator.writeToFile();
    }
  }
}

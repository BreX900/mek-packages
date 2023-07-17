import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/code_builder.dart';
import 'package:one_for_all_generator/src/generators/dart_builder.dart';
import 'package:one_for_all_generator/src/generators/kotlin_builder.dart';
import 'package:one_for_all_generator/src/generators/swift_generator.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:path/path.dart' as path_;
import 'package:source_gen/source_gen.dart';

export 'src/options.dart';

class OneForAll {
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
      // // If using an in-memory file, also provide a layered ResourceProvider:
      // resourceProvider: OverlayResourceProvider(PhysicalResourceProvider())
      //   ..setOverlay(
      //     filePath,
      //     content: File(filePath).readAsStringSync(),
      //     modificationStamp: 0,
      //   ),
    );

    const apiChecker = TypeChecker.fromRuntime(ApiScheme);
    const dataChecker = TypeChecker.fromRuntime(DataScheme);

    final apiElements = <ClassElement>{};
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

        apiElements
            .addAll(libraryReader.annotatedWith(apiChecker).map((e) => e.element as ClassElement));

        libraryReader
            .annotatedWith(dataChecker)
            .map((e) => (e.element as ClassElement).thisType)
            .forEach(writeDataClasses);
      }
    }

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
      apiElements.forEach(generator.writeHostApiClass);

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

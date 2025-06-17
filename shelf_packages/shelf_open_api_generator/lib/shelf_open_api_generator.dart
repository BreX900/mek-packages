import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:open_api_specification/open_api.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_open_api_generator/src/config.dart';
import 'package:shelf_open_api_generator/src/handlers/route_handler.dart';
import 'package:shelf_open_api_generator/src/handlers/routes_handler.dart';
import 'package:shelf_open_api_generator/src/schemas_registry.dart';
import 'package:shelf_open_api_generator/src/utils/annotations_utils.dart';
import 'package:shelf_open_api_generator/src/utils/routing_utils.dart';
import 'package:shelf_open_api_generator/src/utils/utils.dart';
import 'package:shelf_open_api_generator/src/utils/yaml_encoder.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:source_gen/source_gen.dart';

Builder buildOpenApi(BuilderOptions options) {
  final rawConfig = Utils.optionYamlToBuilder(options.config);
  final config = Config.fromJson(rawConfig);

  return OpenApiBuilder(
    buildExtensions: const {
      'lib/{{}}.dart': ['public/{{}}.yaml'],
    },
    config: config,
  );
}

// https://github.com/dart-lang/build/blob/master/docs/writing_an_aggregate_builder.md
class OpenApiBuilder implements Builder {
  static final _routeType = TypeChecker.fromRuntime(Route);
  static final _openApiRouteType = TypeChecker.fromRuntime(OpenApiRoute);

  @override
  final Map<String, List<String>> buildExtensions;
  final Config config;

  OpenApiBuilder({required this.buildExtensions, required this.config});

  /// Find members of a class annotated with [shelf_router.Route].
  List<ExecutableElement> getAnnotatedElementsOrderBySourceOffset(ClassElement cls) =>
      <ExecutableElement>[
        ...cls.methods.where(_routeType.hasAnnotationOfExact),
        ...cls.accessors.where(_routeType.hasAnnotationOfExact),
      ]..sort((a, b) => (a.nameOffset).compareTo(b.nameOffset));

  List<RouteHandler?> _findRoutes(
    SchemasRegistry schemasRegistry,
    ClassElement element, {
    required String routePrefix,
    required bool strict,
  }) {
    final elements = getAnnotatedElementsOrderBySourceOffset(element);

    return elements.expand((executableElement) {
      final openApiAnnotation = ConstantReader(
        _openApiRouteType.firstAnnotationOfExact(executableElement),
      );

      return _routeType.annotationsOfExact(executableElement).map(ConstantReader.new).expand((
        routeAnnotation,
      ) sync* {
        final route = routeAnnotation.read('route').stringValue;

        switch (routeAnnotation.read('verb').stringValue) {
          case r'$all':
            return;
          case r'$mount':
            final childElement = executableElement.returnType.element;
            if (childElement is! ClassElement) {
              throw InvalidGenerationSourceError('The mounted should be a class', element: element);
            }
            yield* _findRoutes(schemasRegistry, childElement, routePrefix: route, strict: strict);
          default:
            final routing = RoutingHandler.from(executableElement, strict: strict);

            yield RouteHandler(
              element: executableElement,
              schemasRegistry: schemasRegistry,
              path: '$routePrefix$route',
              method: routeAnnotation.read('verb').stringValue,
              security: (openApiAnnotation.peek('security')?.listReader ?? const []).map((
                security,
              ) {
                return security.mapReader.map((securitySchemeKey, permissions) {
                  return MapEntry(
                    securitySchemeKey.stringValue,
                    permissions.listReader.map((e) => e.stringValue).toList(),
                  );
                });
              }).toList(),
              requestQuery: openApiAnnotation.peek('requestQuery')?.typeValue,
              requestBody: openApiAnnotation.peek('requestBody')?.typeValue,
              routing: routing,
            );
        }
      });
    }).toList();
  }

  String _generate(SchemasRegistry schemasRegistry, List<RouteHandler> routes) {
    final routesHandler = RoutesHandler(
      config: config,
      schemasRegistry: schemasRegistry,
      routes: routes,
    );

    final openApi = routesHandler.buildOpenApi();
    final rawOpenApi = organizeOpenApi(openApi.toJson());
    return YamlEncoder(
      shouldMultilineStringInBlock: false,
      toEncodable: (o) => o.toJson(),
    ).convert(rawOpenApi);
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) return;

    final package = await buildStep.packageConfig;
    final hasRouting = package.packages.any((e) => e.name == 'shelf_routing');

    final library = await buildStep.resolver.libraryFor(buildStep.inputId);
    final libraryReader = LibraryReader(library);
    final schemasRegistry = SchemasRegistry();

    final annotatedElements = libraryReader.annotatedWith(TypeChecker.fromRuntime(OpenApi));
    if (annotatedElements.isEmpty) return;

    final element = annotatedElements.singleOrNull?.element;
    if (element == null) {
      throw InvalidGenerationSourceError('You must annotate with "OpenApi" only one class');
    }
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'The OpenApi annotation must be used on class',
        element: element,
      );
    }

    final routes = _findRoutes(schemasRegistry, element, routePrefix: '', strict: hasRouting);

    final result = _generate(schemasRegistry, routes.nonNulls.toList());

    await buildStep.writeAsString(buildStep.allowedOutputs.single, result);
  }
}

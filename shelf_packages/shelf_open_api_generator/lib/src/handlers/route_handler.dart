import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_open_api_generator/src/schemas_registry.dart';
import 'package:shelf_open_api_generator/src/utils/annotations_utils.dart';
import 'package:shelf_open_api_generator/src/utils/doc.dart';
import 'package:shelf_open_api_generator/src/utils/utils.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing_generator/shelf_routing_generator.dart';
import 'package:source_gen/source_gen.dart';

/// A representation of a handler that was annotated with [Route].
class OpenRouteHandler {
  final HttpRouteHandler handler;
  final ExecutableElement2 element;
  final SchemasRegistry schemasRegistry;
  final String pathPrefix;
  final List<Map<String, List<String>>> security;
  final DartType? requestQuery;
  final DartType? requestBody;
  final DartType? responseBody;

  String get verb => handler.verb;
  String get path => '$pathPrefix${handler.path}';

  const OpenRouteHandler._({
    required this.handler,
    required this.element,
    required this.schemasRegistry,
    required this.pathPrefix,
    required this.security,
    required this.requestQuery,
    required this.requestBody,
    required this.responseBody,
  });

  OperationOpenApi buildOperation() {
    final classElement = element.enclosingElement2 as ClassElement2;
    final doc = Doc.from(element.documentationComment);

    return OperationOpenApi(
      tags: [classElement.displayName],
      summary: doc.summary ?? element.displayName,
      description: doc.description,
      operationId: element.displayName,
      parameters: _buildParameters(),
      requestBody: _buildRequestBody(),
      responses: {200: _buildResponse()},
      security: security,
    );
  }

  List<ParameterOpenApi> _buildParameters() {
    final pathParams = handler.pathParameters.map((parameter) {
      final schema = schemasRegistry.tryRegisterV2(
        object: false,
        iterables: false,
        dartType: parameter.type,
      );
      return ParameterOpenApi(
        name: parameter.requireName,
        in$: ParameterInOpenApi.path,
        required: true,
        schema: schema ?? SchemaOpenApi(type: TypeOpenApi.string),
      );
    });
    // TODO: check client generation
    final queryParams =
        (requestQuery?.element3 as ClassElement2?)?.requireUnnamedConstructor.formalParameters.map((
          e,
        ) {
          return ParameterOpenApi(
            name: e.requireName,
            in$: ParameterInOpenApi.query,
            // TODO: throw if detect a nested object
            schema: schemasRegistry.tryRegister(dartType: e.type),
            required: e.type.nullabilitySuffix == NullabilitySuffix.none,
          );
        }) ??
        handler.queryParameters.map((parameter) {
          return ParameterOpenApi(
            name: parameter.requireName,
            in$: ParameterInOpenApi.query,
            schema:
                schemasRegistry.tryRegisterV2(object: false, dartType: parameter.type) ??
                SchemaOpenApi(type: TypeOpenApi.string),
          );
        });
    return [...pathParams, ...queryParams];
  }

  RequestBodyOpenApi? _buildRequestBody() {
    final requestBody = this.requestBody ?? handler.bodyParameter?.type;
    if (requestBody == null) return null;
    return RequestBodyOpenApi(
      required: true,
      content: GroupMediaOpenApi(
        json: MediaOpenApi(schema: schemasRegistry.tryRegister(dartType: requestBody)),
      ),
    );
  }

  ResponseOpenApi _buildResponse() {
    final responseBody = this.responseBody;
    if (responseBody != null) {
      return ResponseOpenApi(
        description: 'Operation completed!',
        content: GroupMediaOpenApi(
          json: MediaOpenApi(schema: schemasRegistry.tryRegister(dartType: responseBody)),
        ),
      );
    }

    return ResponseOpenApi(
      description: 'Operation completed!',
      content: switch (handler.returns) {
        RouteReturnsVoid() => null,
        RouteReturnsResponse() || RouteReturnsBytes() => GroupMediaOpenApi(
          octetStream: MediaOpenApi(
            schema: SchemaOpenApi(type: TypeOpenApi.string, format: FormatOpenApi.binary),
          ),
        ),
        RouteReturnsText() => GroupMediaOpenApi(
          textPlain: MediaOpenApi(schema: SchemaOpenApi(type: TypeOpenApi.string)),
        ),
        RouteReturnsJsonResponse(:final type) || RouteReturnsJson(:final type) =>
          type is! VoidType
              ? GroupMediaOpenApi(
                  json: MediaOpenApi(schema: schemasRegistry.tryRegister(dartType: type)),
                )
              : null,
      },
    );
  }

  @override
  String toString() =>
      'RouteHandler(verb: ${handler.verb}, security:$security, requestQuery: $requestQuery, requestBody: $requestBody, element: $element)';
}

class OpenRouteFinder {
  static final _openApiRouteHttpChecker = TypeChecker.typeNamed(
    OpenApiRouteHttp,
    inPackage: 'shelf_open_api',
  );
  static final _openApiRouteMountChecker = TypeChecker.typeNamed(
    OpenApiRouteMount,
    inPackage: 'shelf_open_api',
  );
  static final _openApiRouteIgnoreChecker = TypeChecker.typeNamed(
    OpenApiRouteIgnore,
    inPackage: 'shelf_open_api',
  );

  final SchemasRegistry schemasRegistry;
  final bool strict;

  const OpenRouteFinder({required this.schemasRegistry, required this.strict});

  List<OpenRouteHandler> find(ClassElement2 classElement) => _find(classElement, pathPrefix: '');

  List<OpenRouteHandler> _find(ClassElement2 classElement, {required String pathPrefix}) {
    final routes = RouteHandler.from(classElement, strict: strict);

    return routes.expand<OpenRouteHandler>((route) sync* {
      final isIgnored = _openApiRouteIgnoreChecker.hasAnnotationOf(route.element);
      if (isIgnored) return;

      switch (route) {
        case MountRouteHandler(:final element, :final path, :final isRouterMixin):
          final mount = _openApiRouteMountChecker.firstAnnotationOf(element);
          final serviceType = mount?.getField('serviceType')?.toTypeValue();

          ClassElement2? classElement;
          if (serviceType != null) classElement = serviceType.element3 as ClassElement2?;
          if (isRouterMixin) classElement = element.returnType.element3 as ClassElement2;
          if (classElement == null) return;

          yield* _find(classElement, pathPrefix: path);

        case HttpRouteHandler(:final element):
          final openApiRoute = _openApiRouteHttpChecker
              .firstAnnotationOfExact(route.element)
              .asReader;

          yield OpenRouteHandler._(
            handler: route,
            element: element,
            schemasRegistry: schemasRegistry,
            pathPrefix: pathPrefix,
            security: (openApiRoute.peek('security')?.listReader ?? const []).map((security) {
              return security.mapReader.map((securitySchemeKey, permissions) {
                return MapEntry(
                  securitySchemeKey.stringValue,
                  permissions.listReader.map((e) => e.stringValue).toList(),
                );
              });
            }).toList(),
            requestQuery: openApiRoute.peek('requestQuery')?.typeValue,
            requestBody: openApiRoute.peek('requestBody')?.typeValue,
            responseBody: openApiRoute.peek('responseBody')?.typeValue,
          );
      }
    }).toList();
  }
}

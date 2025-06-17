import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api_generator/src/schemas_registry.dart';
import 'package:shelf_open_api_generator/src/utils/doc.dart';
import 'package:shelf_open_api_generator/src/utils/routing_utils.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:source_gen/source_gen.dart';

/// A representation of a handler that was annotated with [Route].
class RouteHandler {
  final ExecutableElement element;
  final SchemasRegistry schemasRegistry;
  final String path;
  final String method;
  final List<Map<String, List<String>>> security;
  final DartType? requestQuery;
  final DartType? requestBody;

  final RoutingHandler routing;

  RouteHandler({
    required this.element,
    required this.schemasRegistry,
    required this.path,
    required this.method,
    required this.security,
    required this.requestQuery,
    required this.requestBody,
    required this.routing,
  }) : assert(method != 'GET' || requestBody == null);

  OperationOpenApi buildOperation() {
    final classElement = element.enclosingElement3 as ClassElement;
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
    final pathParams = RegExp(r'<([^>]+)>').allMatches(path).map((e) {
      final name = e.group(1)!;

      final parameterType = routing.pathParameters.firstWhereOrNull((e) => e.name == name)?.type;
      final schema = schemasRegistry.tryRegisterV2(
        object: false,
        iterables: false,
        dartType: parameterType,
      );
      return ParameterOpenApi(
        name: name,
        in$: ParameterInOpenApi.path,
        required: true,
        schema: schema ?? SchemaOpenApi(type: TypeOpenApi.string),
      );
    });
    // TODO: check client generation
    final queryParams =
        (requestQuery?.element as ClassElement?)?.unnamedConstructor?.parameters.map((e) {
          return ParameterOpenApi(
            name: e.name,
            in$: ParameterInOpenApi.query,
            // TODO: throw if detect a nested object
            schema: schemasRegistry.tryRegister(dartType: e.type),
            required: e.type.nullabilitySuffix == NullabilitySuffix.none,
          );
        }) ??
        routing.queryParameters.map((parameter) {
          return ParameterOpenApi(
            name: parameter.name,
            in$: ParameterInOpenApi.query,
            schema:
                schemasRegistry.tryRegisterV2(object: false, dartType: parameter.type) ??
                SchemaOpenApi(type: TypeOpenApi.string),
          );
        });
    return [...pathParams, ...queryParams];
  }

  RequestBodyOpenApi? _buildRequestBody() {
    final requestBody = this.requestBody ?? routing.bodyParameter?.type;
    if (requestBody == null) return null;
    return RequestBodyOpenApi(
      required: true,
      content: GroupMediaOpenApi(
        json: MediaOpenApi(schema: schemasRegistry.tryRegister(dartType: requestBody)),
      ),
    );
  }

  ResponseOpenApi get _emptyResponse => ResponseOpenApi(description: 'Operation completed!');

  static final _responseType = TypeChecker.fromRuntime(Response);

  ResponseOpenApi _buildResponse() {
    final returnType = element.returnType;
    if (returnType is! InterfaceType) return _emptyResponse;

    final responseReturnType = returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr
        ? returnType.typeArguments.single
        : returnType;
    if (!_responseType.isAssignableFromType(responseReturnType)) return _emptyResponse;
    if (responseReturnType is! InterfaceType) return _emptyResponse;

    final responseType = responseReturnType.typeArguments.firstOrNull;
    if (responseType == null || responseType is VoidType) return _emptyResponse;

    return ResponseOpenApi(
      description: 'Operation completed!',
      content: GroupMediaOpenApi(
        json: MediaOpenApi(schema: schemasRegistry.tryRegister(dartType: responseType)),
      ),
    );
  }

  @override
  String toString() =>
      'RouteHandler(method: $method, security:$security, requestQuery: $requestQuery, requestBody: $requestBody, element: $element)';
}

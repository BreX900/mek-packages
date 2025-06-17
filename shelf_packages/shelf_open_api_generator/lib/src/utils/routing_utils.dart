import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:source_gen/source_gen.dart';

// Copied from shelf_routing_generator:route_handler.dart
class RoutingHandler {
  final ExecutableElement element;
  final String method;
  final String path;

  final ParameterElement? bodyParameter;
  final bool hasRequest;
  final List<ParameterElement> pathParameters;
  final List<ParameterElement> queryParameters;

  static RoutingHandler from(ExecutableElement element, {bool strict = true}) {
    final annotation = ConstantReader(routeChecker.firstAnnotationOf(element));
    // if (annotation.isNull) return null;

    final verb = annotation.read('verb').stringValue;
    final route = annotation.read('route').stringValue;
    if (!RegExp(r'^\/.*').hasMatch(route)) {
      throw InvalidGenerationSourceError('"route" field must begin with "/".', element: element);
    }

    final pathParams = RegExp(r'\/<(\w+)>').allMatches(route).map((e) => e.group(1)!).toList();
    final parametersIterator = element.parameters.where((e) => e.isPositional).iterator;

    if (!parametersIterator.moveNext() ||
        !requestChecker.isAssignableFromType(parametersIterator.current.type)) {
      throw InvalidGenerationSourceError(
        'need first parameter as "Request request".',
        element: element,
      );
    }

    if (!strict) {
      return RoutingHandler._(
        method: verb,
        path: route,
        element: element,
        bodyParameter: null,
        hasRequest: true,
        pathParameters: [],
        queryParameters: [],
      );
    }

    final pathParameters = <ParameterElement>[];
    for (final pathParam in pathParams) {
      if (!parametersIterator.moveNext()) {
        throw InvalidGenerationSourceError(
          'not has "$pathParam" path parameter.',
          element: element,
        );
      }
      final parameter = parametersIterator.current;

      if (pathParam != parameter.name) {
        throw InvalidGenerationSourceError(
          'has name different to path param "$pathParam".',
          element: parameter,
        );
      }
      pathParameters.add(parameter);
    }

    ParameterElement? bodyParameter;
    if (parametersIterator.moveNext()) {
      if (verb == 'GET') {
        throw InvalidGenerationSourceError('"GET" endpoint cannot have a body.', element: element);
      }
      final parameter = parametersIterator.current;

      bool check(DartType type) {
        if (type.isDartCoreBool || type.isDartCoreString) return true;
        if (type.isDartCoreInt || type.isDartCoreDouble || type.isDartCoreNum) return true;

        if (type is! InterfaceType) return false;

        if (type.isDartCoreList) {
          return check(type.typeArguments.single);
        } else if (type.isDartCoreMap) {
          return check(type.typeArguments[1]);
        } else {
          final parameterElement = type.element as ClassElement;
          if (parameterElement.constructors.every((e) => e.name != 'fromJson')) {
            return false;
          }
          return true;
        }
      }

      if (!check(parameter.type)) {
        final parameterTypeName = parameter.type.getDisplayString(withNullability: false);
        throw InvalidGenerationSourceError(
          'invalid body parameter type.\n'
          'You can use primitive types: bool, int, double, num or String or List, Map with primitive values.\n'
          'If you want use custom type add "factory $parameterTypeName.fromJson(Map<String, dynamic> map)" constructor.',
          element: parameter.enclosingElement3,
        );
      }
      bodyParameter = parameter;
    }

    if (parametersIterator.moveNext()) {
      throw InvalidGenerationSourceError('has many parameters.', element: element);
    }

    final queryParameters = element.parameters.where((e) => e.isNamed).toList();

    return RoutingHandler._(
      method: verb,
      path: route,
      element: element,
      bodyParameter: bodyParameter,
      hasRequest: true,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
    );
  }

  RoutingHandler._({
    required this.element,
    required this.method,
    required this.path,
    required this.bodyParameter,
    required this.hasRequest,
    required this.pathParameters,
    required this.queryParameters,
  });
}

// Copied from shelf_routing_generator:utils.dart

const TypeChecker routeChecker = TypeChecker.fromRuntime(Route);
const TypeChecker requestChecker = TypeChecker.fromRuntime(Request);
const TypeChecker responseChecker = TypeChecker.fromRuntime(Response);

bool isHandlerClassAssignableFromType(DartType type) {
  if (type is! InterfaceType) return false;

  final callMethod = type.getMethod('call');
  if (callMethod == null || callMethod.isStatic) return false;

  return isHandlerFunctionAssignableFromType(callMethod.type);
}

bool isHandlerFunctionAssignableFromType(DartType type) {
  if (type is! FunctionType) return false;

  var returnType = type.returnType;
  returnType = returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr
      ? (returnType as InterfaceType).typeArguments.single
      : returnType;
  if (!responseChecker.isAssignableFromType(returnType)) return false;

  final parameter = type.parameters.singleOrNull;
  if (parameter == null || !requestChecker.isAssignableFromType(parameter.type)) return false;

  return true;
}

void ensureIsValidRoute(String? route, {required String name, Element? element}) {
  if (route == null || RegExp(r'^\/.+[^/]$').hasMatch(route)) return;
  throw InvalidGenerationSourceError(
    '"$name" field must begin and not end with "/". ',
    element: element,
  );
}

extension JsonType on DartType {
  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;

  bool get isPrimitive =>
      isDartCoreBool || isDartCoreInt || isDartCoreDouble || isDartCoreNum || isDartCoreString;

  bool get isJsonPrimitive => isDartCoreNull || isPrimitive;
  bool get isJson => isJsonPrimitive || isDartCoreList || isDartCoreMap;

  InterfaceType? get asDartCoreList => this is InterfaceType ? this as InterfaceType : null;
}

extension InterfaceTypeExtensions on InterfaceType {
  DartType get typeArgument => typeArguments.single;
}

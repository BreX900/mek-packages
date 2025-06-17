import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:shelf_routing_generator/src/route_header_handler.dart';
import 'package:shelf_routing_generator/src/utils.dart';
import 'package:source_gen/source_gen.dart';

enum RouteReturnsType { response, json, nothing }

sealed class RouteHandlerBase {
  static List<RouteHandlerBase> fromClass(ClassElement element) {
    return [
      ...element.methods.map(RouteHandler.from).nonNulls,
      ...element.accessors.map(MountRouteHandler.from).nonNulls,
    ];
  }
}

class MountRouteHandler extends RouteHandlerBase {
  final ExecutableElement element;
  final bool isRouterMixin;
  final String path;

  MountRouteHandler({required this.element, required this.isRouterMixin, required this.path});

  static MountRouteHandler? from(ExecutableElement element) {
    final annotation = ConstantReader(routeChecker.firstAnnotationOf(element));
    if (annotation.isNull) return null;

    final verb = annotation.read('verb').stringValue;
    final route = annotation.read('route').stringValue;
    if (!RegExp(r'^\/.*').hasMatch(route)) {
      throw InvalidGenerationSourceError('"route" field must begin with "/".', element: element);
    }
    if (verb != r'$mount') {
      throw InvalidGenerationSourceError(
        'the field must be use @Route.mount(...) or @Route.all(...) annotation.',
        element: element,
      );
    }

    final type = element.returnType;
    bool isRouterMixin;
    if (routerChecker.isAssignableFromType(type)) {
      isRouterMixin = false;
    } else if (routerMixinChecker.isAssignableFromType(type)) {
      isRouterMixin = true;
    } else {
      throw InvalidGenerationSourceError(
        'the getter must be a returns a "Router" type or a class with "router" getter to returns a "Router" type.',
        element: element,
      );
    }

    return MountRouteHandler(element: element, isRouterMixin: isRouterMixin, path: route);
  }
}

class RouteHandler extends RouteHandlerBase {
  final ExecutableElement element;
  final String method;
  final String path;

  final ParameterElement? bodyParameter;
  final bool hasRequest;
  final List<ParameterElement> pathParameters;
  final List<RouteHeaderHandler> headers;
  // final List<ParameterElement> headerParameters;
  final List<ParameterElement> queryParameters;
  final RouteReturnsType returns;

  static RouteHandler? from(MethodElement element) {
    final annotation = ConstantReader(routeChecker.firstAnnotationOf(element));
    if (annotation.isNull) return null;

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
          return check(type.typeArgument);
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

    // final headerParameters =
    //     element.parameters.where((e) => e.isNamed && _headerChecker.hasAnnotationOf(e)).toList();
    final queryParameters = element.parameters.where((e) => e.isNamed).toList();

    return RouteHandler._(
      // routable: routable,
      method: verb,
      path: route,
      element: element,
      bodyParameter: bodyParameter,
      hasRequest: true,
      pathParameters: pathParameters,
      headers: RouteHeaderHandler.from(element),
      queryParameters: queryParameters,
      returns: _parseReturnsType(element.returnType),
    );
  }

  static RouteReturnsType _parseReturnsType(DartType type) {
    final returnType = type.isDartAsyncFuture || type.isDartAsyncFuture
        ? (type as InterfaceType).typeArguments.single
        : type;

    if (returnType is VoidType) return RouteReturnsType.nothing;

    if (returnType.isJson) return RouteReturnsType.json;

    final returnElement = returnType.element;
    if (returnElement is ClassElement) {
      if (responseChecker.isAssignableFromType(returnType)) return RouteReturnsType.response;
      if (returnElement.methods.every((element) => element.name != 'toJson')) {
        throw InvalidGenerationSourceError(
          'Please implement "Map<String, dynamic> ${returnElement.name}.toJson()" method.',
        );
      }
      return RouteReturnsType.json;
    }

    final typeName = type.getDisplayString(withNullability: false);
    throw InvalidGenerationSourceError(
      'Please update $typeName with valid returns json value.',
      element: type.element,
    );
  }

  RouteHandler._({
    // required this.routable,
    required this.element,
    required this.method,
    required this.path,
    required this.bodyParameter,
    required this.hasRequest,
    required this.pathParameters,
    required this.headers,
    required this.queryParameters,
    required this.returns,
  });
}

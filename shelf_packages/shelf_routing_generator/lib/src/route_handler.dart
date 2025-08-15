import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:http_methods/http_methods.dart';
// ignore: implementation_imports
import 'package:shelf_router/src/router_entry.dart' show RouterEntry;
import 'package:shelf_routing_generator/src/route_header_handler.dart';
import 'package:shelf_routing_generator/src/utils.dart';
import 'package:source_gen/source_gen.dart';

enum RouteReturnsType { response, json, nothing }

class _Route {
  final String verb;
  final String path;

  _Route(this.verb, this.path);

  static _Route? from(ExecutableElement element) {
    final annotation = ConstantReader(routeChecker.firstAnnotationOf(element));
    if (annotation.isNull) return null;

    return _Route(annotation.read('verb').stringValue, annotation.read('route').stringValue);
  }
}

sealed class RouteHandler {
  final ExecutableElement element;
  final String path;

  RouteHandler({required this.element, required this.path});

  static List<RouteHandler> from(ClassElement element, {bool strict = true}) {
    return [
      ...element.methods.map((element) => HttpRouteHandler.from(element, strict: strict)).nonNulls,
      ...element.accessors.map(MountRouteHandler.from).nonNulls,
    ];
  }
}

class MountRouteHandler extends RouteHandler {
  final bool isRouterMixin;

  MountRouteHandler({required super.element, required super.path, required this.isRouterMixin});

  static MountRouteHandler? from(ExecutableElement element) {
    final route = _Route.from(element);
    if (route == null) return null;

    if (element.isStatic) {
      throw InvalidGenerationSourceError(
        'The shelf_router.Route annotation cannot be used on static members',
        element: element,
      );
    }
    if (element.kind != ElementKind.GETTER) {
      throw InvalidGenerationSourceError(
        'The shelf_router.Route.mount annotation can only be used on a '
        'getter that returns shelf_router.Router',
        element: element,
      );
    }
    if (!route.path.startsWith('/')) {
      throw InvalidGenerationSourceError(
        'The prefix "${route.path}" in shelf_router.Route.mount(prefix) '
        'annotation must begin with a slash',
        element: element,
      );
    }
    if (route.path.contains('<')) {
      throw InvalidGenerationSourceError(
        'The prefix "${route.path}" in shelf_router.Route.mount(prefix) '
        'annotation cannot contain <',
        element: element,
      );
    }

    if (route.verb != r'$mount') {
      throw InvalidGenerationSourceError(
        'Only the shelf_router.Route.mount annotation can only be used on a '
        'getter, and only if it returns a shelf_router.Router or shelf_routing.RouterMixin',
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
        'The getter must returns a shelf_router.Router or shelf_routing.RouterMixin',
        element: element,
      );
    }

    return MountRouteHandler(element: element, isRouterMixin: isRouterMixin, path: route.path);
  }
}

class HttpRouteHandler extends RouteHandler {
  final String verb;
  final ParameterElement? bodyParameter;
  final bool hasRequest;
  final List<ParameterElement> pathParameters;
  final List<RouteHeaderHandler> headers;
  final List<ParameterElement> queryParameters;
  final RouteReturns returns;

  static HttpRouteHandler? from(MethodElement element, {bool strict = true}) {
    final route = _Route.from(element);
    if (route == null) return null;

    if (element.isStatic) {
      throw InvalidGenerationSourceError(
        'The shelf_router.Route annotation cannot be used on static members',
        element: element,
      );
    }
    if (!isHttpMethod(route.verb)) {
      throw InvalidGenerationSourceError(
        'The verb "${route.verb}" used in shelf_router.Route annotation must be '
        'a valid HTTP method',
        element: element,
      );
    }
    if (element.kind == ElementKind.GETTER) {
      throw InvalidGenerationSourceError(
        'Only the shelf_router.Route.mount annotation can only be used on a '
        'getter, and only if it returns a shelf_router.Router',
        element: element,
      );
    }
    if (element.kind != ElementKind.METHOD) {
      throw InvalidGenerationSourceError(
        'The shelf_router.Route annotation can only be used on request handling methods',
        element: element,
      );
    }
    List<String> pathParams;
    try {
      pathParams = RouterEntry(route.verb, route.path, () => null).params;
      // ignore: avoid_catching_errors
    } on ArgumentError catch (e) {
      throw InvalidGenerationSourceError(e.toString(), element: element);
    }

    final parametersIterator = element.parameters.where((e) => e.isPositional).iterator;

    if (!parametersIterator.moveNext() ||
        !requestChecker.isAssignableFromType(parametersIterator.current.type)) {
      throw InvalidGenerationSourceError(
        'The shelf_router.Route annotation can only be used on shelf request '
        'handlers accept a shelf.Request parameter as first parameter',
        element: element,
      );
    }

    final pathParameters = <ParameterElement>[];
    for (final pathParam in pathParams) {
      if (!parametersIterator.moveNext()) {
        throw InvalidGenerationSourceError(
          'The shelf_router.Route annotation can only be used on shelf '
          'request handlers accept a shelf.Request parameter and all parameters in the route, '
          'the "$pathParam" is missing',
          element: element,
        );
      }
      final parameter = parametersIterator.current;

      if (pathParam != parameter.name) {
        throw InvalidGenerationSourceError(
          'The shelf_router.Route annotation can only be used on shelf '
          'request handlers accept a shelf.Request parameter and and all parameters in the route, '
          'the "${parameter.name}" parameter should be named "$pathParam"',
          element: parameter,
        );
      }
      if (parameter.isOptional) {
        throw InvalidGenerationSourceError(
          'The shelf_router.Route annotation can only be used on shelf '
          'request handlers accept a shelf.Request parameter and all parameters in the route, '
          'optional positional parameters are not permitted',
          element: parameter,
        );
      }
      pathParameters.add(parameter);
    }

    ParameterElement? bodyParameter;
    if (strict && parametersIterator.moveNext()) {
      if (route.verb == 'GET') {
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
        final parameterTypeName = parameter.type.getDisplayString();
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
      throw InvalidGenerationSourceError(
        'The shelf_router.Route annotation can only be used on shelf '
        'request handlers accept a shelf.Request parameter and all parameters in the route, '
        'remote "${parametersIterator.current}" parameter from the method',
        element: element,
      );
    }

    // final headerParameters =
    //     element.parameters.where((e) => e.isNamed && _headerChecker.hasAnnotationOf(e)).toList();
    var queryParameters = <ParameterElement>[];
    if (strict) {
      queryParameters = element.parameters.where((e) => e.isNamed).toList();
    } else {
      for (final parameter in element.parameters) {
        if (!parameter.isNamed) continue;
        throw InvalidGenerationSourceError(
          'The shelf_router.Route annotation can only be used on shelf '
          'request handlers accept a shelf.Request parameter and all parameters in the route, '
          'optional positional parameters are not permitted',
          element: parameter,
        );
      }
    }

    return HttpRouteHandler._(
      verb: route.verb,
      path: route.path,
      element: element,
      bodyParameter: bodyParameter,
      hasRequest: true,
      pathParameters: pathParameters,
      headers: RouteHeaderHandler.from(element),
      queryParameters: queryParameters,
      returns: _parseReturnsType(element.returnType),
    );
  }

  static RouteReturns _parseReturnsType(DartType type) {
    final returnType = type.isDartAsyncFuture || type.isDartAsyncFuture
        ? (type as InterfaceType).typeArguments.single
        : type;

    if (returnType is VoidType) return RouteReturnsVoid();
    if (responseChecker.isAssignableFromType(returnType)) {
      if (jsonResponseChecker.isAssignableFromType(returnType)) {
        return RouteReturnsResponse((returnType as InterfaceType).typeArguments.single);
      }
      return RouteReturnsResponse(null);
    }
    return RouteReturnsJson(returnType);
  }

  HttpRouteHandler._({
    required super.element,
    required this.verb,
    required super.path,
    required this.bodyParameter,
    required this.hasRequest,
    required this.pathParameters,
    required this.headers,
    required this.queryParameters,
    required this.returns,
  });
}

sealed class RouteReturns {}

class RouteReturnsVoid extends RouteReturns {}

class RouteReturnsResponse extends RouteReturns {
  final DartType? type;

  RouteReturnsResponse(this.type);
}

class RouteReturnsJson extends RouteReturns {
  final DartType type;

  RouteReturnsJson(this.type);
}

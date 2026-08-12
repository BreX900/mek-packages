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
      ...element.getters.map(MountRouteHandler.from).nonNulls,
    ];
  }
}

class MountRouteHandler extends RouteHandler {
  final bool isRouterMixin;

  MountRouteHandler({required super.element, required super.path, required this.isRouterMixin});

  static MountRouteHandler? from(GetterElement element) {
    final route = _Route.from(element);
    if (route == null) return null;

    if (element.isStatic) {
      throw InvalidGenerationSourceError(
        'The shelf_router.Route annotation cannot be used on static members',
        element: element,
      );
    }
    // if (element.kind != ElementKind.GETTER) {
    //   throw InvalidGenerationSourceError(
    //     'The shelf_router.Route.mount annotation can only be used on a '
    //     'getter that returns shelf_router.Router',
    //     element: element,
    //   );
    // }
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
  final RouteAccept? bodyParameter;
  final bool hasRequest;
  final List<FormalParameterElement> pathParameters;
  final List<RouteHeaderHandler> headers;
  final List<FormalParameterElement> queryParameters;
  final RouteReturns returns;

  bool get isAsync => bodyParameter != null || returns.isAsync;

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
    // if (element.kind == ElementKind.GETTER) {
    //   throw InvalidGenerationSourceError(
    //     'Only the shelf_router.Route.mount annotation can only be used on a '
    //     'getter, and only if it returns a shelf_router.Router',
    //     element: element,
    //   );
    // }
    // if (element.kind != ElementKind.METHOD) {
    //   throw InvalidGenerationSourceError(
    //     'The shelf_router.Route annotation can only be used on request handling methods',
    //     element: element,
    //   );
    // }
    List<String> pathParams;
    try {
      pathParams = RouterEntry(route.verb, route.path, () => null).params;
      // ignore: avoid_catching_errors
    } on ArgumentError catch (e) {
      throw InvalidGenerationSourceError(e.toString(), element: element);
    }

    final parametersIterator = element.formalParameters.where((e) => e.isPositional).iterator;

    if (!parametersIterator.moveNext() ||
        !requestChecker.isAssignableFromType(parametersIterator.current.type)) {
      throw InvalidGenerationSourceError(
        'The shelf_router.Route annotation can only be used on shelf request '
        'handlers accept a shelf.Request parameter as first parameter',
        element: element,
      );
    }

    final pathParameters = <FormalParameterElement>[];
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

    RouteAccept? bodyParameter;
    if (strict && parametersIterator.moveNext()) {
      if (route.verb == 'GET') {
        throw InvalidGenerationSourceError('"GET" endpoint cannot have a body.', element: element);
      }
      final parameter = parametersIterator.current;

      bool check(DartType type) {
        if (type.isDartCoreString) return true;

        if (type.isDartCoreBool ||
            type.isDartCoreInt ||
            type.isDartCoreDouble ||
            type.isDartCoreNum) {
          return true;
        }

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

      if (byteStreamChecker.isExactlyType(parameter.type)) {
        bodyParameter = RouteAcceptBytes(parameter.type);
      } else if (parameter.type.isDartCoreString) {
        bodyParameter = RouteAcceptText(parameter.type);
      } else {
        bodyParameter = check(parameter.type) ? RouteAcceptJson(parameter.type) : null;
      }

      if (bodyParameter == null) {
        final parameterTypeName = parameter.type.getDisplayString();
        throw InvalidGenerationSourceError(
          'invalid body parameter type.\n'
          'You can use primitive types: bool, int, double, num or String or List, Map with primitive values.\n'
          'If you want use custom type add "factory $parameterTypeName.fromJson(Map<String, dynamic> map)" constructor.',
          element: parameter.enclosingElement,
        );
      }
    }

    if (parametersIterator.moveNext()) {
      throw InvalidGenerationSourceError(
        'The shelf_router.Route annotation can only be used on shelf '
        'request handlers accept a shelf.Request parameter and all parameters in the route, '
        'remove "${parametersIterator.current}" parameter from the method',
        element: element,
      );
    }

    // final headerParameters =
    //     element.parameters.where((e) => e.isNamed && _headerChecker.hasAnnotationOf(e)).toList();
    var queryParameters = <FormalParameterElement>[];
    if (strict) {
      queryParameters = element.formalParameters.where((e) => e.isNamed).toList();
    } else {
      for (final parameter in element.formalParameters) {
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
      returns: _parseReturnsType(element),
    );
  }

  static RouteReturns _parseReturnsType(MethodElement element) {
    var isAsync = false;
    var type = element.returnType;
    if (type.isDartAsyncFuture || type.isDartAsyncFuture) {
      isAsync = true;
      type = (type as InterfaceType).typeArguments.single;
    }
    if (responseChecker.isAssignableFromType(type)) {
      if (jsonResponseChecker.isAssignableFromType(type)) {
        return RouteReturnsJsonResponse(
          isAsync: isAsync,
          (type as InterfaceType).typeArguments.single,
        );
      }
      return RouteReturnsResponse(isAsync: isAsync);
    }

    if (type is VoidType) {
      return RouteReturnsVoid(isAsync: isAsync);
    }
    if (type.isDartAsyncStream || bytesChecker.isAssignableFromType(type)) {
      return RouteReturnsBytes(isAsync: isAsync);
    }
    if (type.isJson) {
      return RouteReturnsJson(isAsync: isAsync, type);
    }
    if (type is InterfaceType ? type.getMethod('toJson') : null case final toJsonMethod?
        when toJsonMethod.returnType.isJson && toJsonMethod.formalParameters.isEmpty) {
      return RouteReturnsJson(isAsync: isAsync, type);
    }

    throw InvalidGenerationSourceError(
      'The shelf_router.Route annotation can only be used on shelf '
      'request handlers returns a Stream<List<int>>, Uint8List, any valid json value or '
      'class with "toJson()" method returning valid json value.',
      element: element,
    );
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

sealed class RouteReturns {
  final bool isAsync;

  const RouteReturns({required this.isAsync});
}

class RouteReturnsVoid extends RouteReturns {
  const RouteReturnsVoid({required super.isAsync});
}

class RouteReturnsResponse extends RouteReturns {
  const RouteReturnsResponse({required super.isAsync});
}

class RouteReturnsJsonResponse extends RouteReturns {
  final DartType type;

  const RouteReturnsJsonResponse(this.type, {required super.isAsync});
}

class RouteReturnsBytes extends RouteReturns {
  const RouteReturnsBytes({required super.isAsync});
}

class RouteReturnsText extends RouteReturns {
  const RouteReturnsText({required super.isAsync});
}

class RouteReturnsJson extends RouteReturns {
  final DartType type;

  const RouteReturnsJson(this.type, {required super.isAsync});
}

sealed class RouteAccept {
  final DartType type;

  const RouteAccept(this.type);
}

class RouteAcceptText extends RouteAccept {
  const RouteAcceptText(super.type);
}

class RouteAcceptBytes extends RouteAccept {
  const RouteAcceptBytes(super.type);
}

class RouteAcceptJson extends RouteAccept {
  const RouteAcceptJson(super.type);
}

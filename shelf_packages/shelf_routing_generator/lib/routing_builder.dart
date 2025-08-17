import 'dart:async';

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:recase/recase.dart';
import 'package:shelf_routing_generator/src/route_handler.dart';
import 'package:shelf_routing_generator/src/utils.dart';
import 'package:source_gen/source_gen.dart';

Builder routingBuilder(BuilderOptions options) {
  return SharedPartBuilder(const [RoutingGenerator()], 'routing');
}

class RoutingGenerator extends Generator {
  const RoutingGenerator();

  String? _findParserMethod(DartType type) {
    if (type is! InterfaceType) return null;

    final parserMethod = type.getMethod2('parse');
    if (parserMethod == null) return null;

    if (!TypeChecker.fromStatic(type).isAssignableFromType(parserMethod.returnType)) return null;

    final firstParameter = parserMethod.formalParameters.firstOrNull;
    if (firstParameter == null || firstParameter.isNamed) return null;

    if (!firstParameter.type.isDartCoreString) return null;
    if (parserMethod.formalParameters.skip(1).any((e) => e.isRequired)) return null;

    return '${type.element3.requireName}.${parserMethod.requireName}';
  }

  String? _codeParser(DartType type) {
    if (type.isDartCoreBool) return 'bool.parse';
    if (type.isDartCoreInt) return 'int.parse';
    if (type.isDartCoreDouble) return 'double.parse';
    if (type.isDartCoreNum) return 'num.parse';
    if (type.isDartCoreString) return null;
    final parser = _findParserMethod(type);
    if (parser != null) return parser;
    throw UnsupportedError('the var $type has not supported $type type.');
  }

  String _codeListParser(DartType type) {
    if (type.isDartCoreList) {
      var parserCode = _codeParser((type as InterfaceType).typeArguments.single);
      if (parserCode != null) parserCode = '.map($parserCode).toList()';
      return '(vls) => vls${parserCode ?? ''}';
    }
    var parserCode = _codeParser(type);
    parserCode = parserCode != null ? '$parserCode(vls.single)' : 'vls.single';
    if (type.isNullable) {
      return '(vls) => vls.isNotEmpty ? $parserCode : null';
    } else {
      return '(vls) => $parserCode';
    }
  }

  String _codeFromJson(DartType type) {
    if (type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreNum ||
        type.isDartCoreBool ||
        type.isDartCoreString) {
      return 'data! as ${type.getDisplayString()}';
    }
    type as InterfaceType;
    if (type.isDartCoreList) {
      return '(data! as List<dynamic>).map((data) {\n'
          '  return ${_codeFromJson(type.typeArgument)};\n'
          '}).toList()\n';
    }
    if (type.isDartCoreMap) {
      return '(data! as Map<String, dynamic>).map((k, data) {\n'
          '  return  MapEntry(k, ${_codeFromJson(type.typeArguments[1])});\n'
          '})\n';
    }
    final element = type.element3 as ClassElement2;
    final constructor = element.constructors2.firstWhere((e) => e.name3 == 'fromJson');
    return '${type.getDisplayString()}.fromJson(data! as ${constructor.formalParameters.first.type.getDisplayString()})';
  }

  String _codeAddRoute(HttpRouteHandler __) {
    final HttpRouteHandler(
      :verb,
      :path,
      :element,
      :hasRequest,
      :pathParameters,
      :bodyParameter,
      :headers,
      :queryParameters,
      :returns,
    ) = __;

    final routeParams = [
      'Request request',
      ...pathParameters.map((e) => 'String \$${e.requireName}'),
    ].join(', ');

    final headersCode = headers.map((e) {
      return '\n\$ensureHasHeader(request, ${literalString(e.name)});';
    }).join();

    final methodParams = [
      if (hasRequest) 'request',
      ...pathParameters.map((e) {
        final parserCode = _codeParser(e.type);
        return parserCode != null ? '$parserCode(\$${e.requireName})' : '\$${e.requireName}';
      }),
      if (bodyParameter != null)
        'await \$readBodyAs(request, (data) => ${_codeFromJson(bodyParameter.type)})',
      // if (headerParameters.isNotEmpty)
      //   ...headerParameters.map((e) {
      //     final key = e.name.paramCase;
      //     return "${e.name}: \$parseHeaders(request, '$key', ${_codeListParser(e.type)})";
      //   }),
      if (queryParameters.isNotEmpty)
        ...queryParameters.map((e) {
          final key = e.requireName.paramCase;
          return '${e.requireName}: \$parseQueryParameters(request, ${literalString(key)}, ${_codeListParser(e.type)})';
        }),
    ];
    final methodParamsText = methodParams.expand((e) sync* {
      yield e;
      yield ',\n';
    }).join();

    var methodInvocation = '';
    if (element.returnType.isDartAsyncFutureOr || element.returnType.isDartAsyncFuture) {
      methodInvocation += 'await ';
    }
    methodInvocation += 'service.${element.requireName}($methodParamsText)';

    final responseCode = switch (returns) {
      RouteReturnsVoid() => '$methodInvocation;\nreturn Response.ok(null)',
      RouteReturnsResponse() => 'return $methodInvocation;',
      RouteReturnsBytes() ||
      RouteReturnsText() => 'final body = $methodInvocation;\nreturn Response.ok(body);',
      RouteReturnsJson() => 'final body = $methodInvocation;\nreturn JsonResponse.ok(body);',
    };

    if (verb == r'$all') {
      return '''
  ..all(${literalString(path)}, ($routeParams) async {$headersCode
    $responseCode
  })''';
    }

    return '''
  ..add('$verb', ${literalString(path)}, ($routeParams) async {$headersCode
    $responseCode
  })''';
  }

  @override
  Future<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final routers = library.classes.map((class$) {
      final routes = RouteHandler.from(class$);
      if (routes.isEmpty) return null;
      return MapEntry(class$, routes);
    }).nonNulls;
    if (routers.isEmpty) return null;

    final routersCode = routers.map((__) {
      final MapEntry(key: class$, value: routes) = __;

      final routesCode = routes.map((route) {
        return switch (route) {
          MountRouteHandler() => switch (route.isRouterMixin) {
            false =>
              '..mount(${literalString(route.path)}, service.${route.element.requireName}.call)',
            true =>
              '..mount(${literalString(route.path)}, service.${route.element.requireName}.router.call)',
          },
          HttpRouteHandler() => _codeAddRoute(route),
        };
      }).join();
      return '''
Router _\$${class$.requireName}Router(${class$.requireName} service) => Router()\n
  $routesCode;\n''';
    });
    return routersCode.join('\n');
  }
}

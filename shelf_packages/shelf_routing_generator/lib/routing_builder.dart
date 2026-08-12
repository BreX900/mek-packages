import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
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

    final candidates = <ExecutableElement>{
      ?type.getMethod('parse'),
      ?type.lookUpConstructor('fromJson', type.element.library),
    };
    for (final candidate in candidates) {
      if (!TypeChecker.fromStatic(type).isAssignableFromType(candidate.returnType)) continue;

      final firstParameter = candidate.formalParameters.firstOrNull;
      if (firstParameter == null || firstParameter.isNamed) continue;

      if (!firstParameter.type.isDartCoreString) continue;
      if (candidate.formalParameters.skip(1).any((e) => e.isRequired)) continue;

      return '${type.element.displayName}.${candidate.name!}';
    }

    return null;
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
    if (type.isDartCoreList || type.isDartCoreSet) {
      var parserCode = _codeParser((type as InterfaceType).typeArguments.single);
      if (parserCode != null) {
        parserCode = '.map($parserCode).${type.isDartCoreSet ? 'toSet' : 'toList'}()';
      }
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
    if (type.isDartCoreList || type.isDartCoreSet) {
      return '(data! as List<dynamic>).map((data) {\n'
          '  return ${_codeFromJson(type.typeArgument)};\n'
          '}).${type.isDartCoreSet ? 'toSet' : 'toList'}()\n';
    }
    if (type.isDartCoreMap) {
      return '(data! as Map<String, dynamic>).map((k, data) {\n'
          '  return  MapEntry(k, ${_codeFromJson(type.typeArguments[1])});\n'
          '})\n';
    }
    final element = type.element as ClassElement;
    final constructor = element.constructors.firstWhere((e) => e.name == 'fromJson');
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
      :isAsync,
      :returns,
    ) = __;

    final routeParams = [
      'Request request',
      ...pathParameters.map((e) => 'String \$${e.displayName}'),
    ].join(', ');

    final headersCode = headers.map((e) {
      return '\n\$ensureHasHeader(request, ${literalString(e.name)});';
    }).join();

    final methodParams = [
      if (hasRequest) 'request',
      ...pathParameters.map((e) {
        final parserCode = _codeParser(e.type);
        return parserCode != null ? '$parserCode(\$${e.displayName})' : '\$${e.displayName}';
      }),
      ?switch (bodyParameter) {
        null => null,
        RouteAcceptBytes() => 'request.read()',
        RouteAcceptText() => r'await $readBodyAsString(request)',
        RouteAcceptJson() =>
          'await \$readBodyAs(request, (data) => ${_codeFromJson(bodyParameter.type)})',
      },

      // if (headerParameters.isNotEmpty)
      //   ...headerParameters.map((e) {
      //     final key = e.name.paramCase;
      //     return "${e.name}: \$parseHeaders(request, '$key', ${_codeListParser(e.type)})";
      //   }),
      if (queryParameters.isNotEmpty)
        ...queryParameters.map((e) {
          final key = e.displayName;
          return '${e.displayName}: \$parseQueryParameters(request, ${literalString(key)}, ${_codeListParser(e.type)})';
        }),
    ];
    final methodParamsText = methodParams.expand((e) sync* {
      yield e;
      yield ',\n';
    }).join();

    var methodInvocation = '';
    if (returns.isAsync) methodInvocation += 'await ';
    methodInvocation += 'service.${element.displayName}($methodParamsText)';

    final responseCode = switch (returns) {
      RouteReturnsVoid() => '$methodInvocation;\nreturn Response.ok(null);',
      RouteReturnsResponse() || RouteReturnsJsonResponse() => 'return $methodInvocation;',
      RouteReturnsBytes() ||
      RouteReturnsText() => 'final body = $methodInvocation;\nreturn Response.ok(body);',
      RouteReturnsJson() => 'final body = $methodInvocation;\nreturn JsonResponse.ok(body);',
    };

    if (verb == r'$all') {
      return '''
  ..all(${literalString(path)}, ($routeParams)${isAsync ? ' async' : ''} {$headersCode
    $responseCode
  })''';
    }

    return '''
  ..add('$verb', ${literalString(path)}, ($routeParams)${isAsync ? ' async' : ''} {$headersCode
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
              '..mount(${literalString(route.path)}, service.${route.element.displayName}.call)',
            true =>
              '..mount(${literalString(route.path)}, service.${route.element.displayName}.router.call)',
          },
          HttpRouteHandler() => _codeAddRoute(route),
        };
      }).join();
      return '''
Router _\$${class$.displayName}Router(${class$.displayName} service) => Router()\n
  $routesCode;\n''';
    });
    return routersCode.join('\n');
  }
}

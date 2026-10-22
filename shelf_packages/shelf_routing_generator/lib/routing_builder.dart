import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart' hide FunctionType;
import 'package:collection/collection.dart';
import 'package:shelf_routing_generator/src/route_handler.dart';
import 'package:shelf_routing_generator/src/utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

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

  String? _codeParser(FormalParameterElement element, DartType type) {
    if (type.isDartCoreBool) return 'bool.parse';
    if (type.isDartCoreInt) return 'int.parse';
    if (type.isDartCoreDouble) return 'double.parse';
    if (type.isDartCoreNum) return 'num.parse';
    if (type.isDartCoreString) return null;
    final parser = _findParserMethod(type);
    if (parser != null) return parser;
    throw InvalidGenerationSourceError(
      'Cant resolve the parsing procedure for type "$type".',
      element: element,
      todo:
          'Implement "static $type parse(String source)" or "factory $type.fromJson(String source)" method',
    );
  }

  String _codeListParser(FormalParameterElement element, DartType type) {
    if (TypeCheckers.iterable.isAssignableFromType(type)) {
      if (type.isNullableType) {
        throw InvalidGenerationSourceError(
          'Any Iterable (List/Set/IList/ISet) cannot be nullable.',
          todo: 'Provide a default value or remove the nullability.',
          element: element,
        );
      }

      if (type.isDartCoreList || type.isDartCoreSet) {
        var parserCode = _codeParser(element, (type as InterfaceType).typeArguments.single);
        if (parserCode != null) {
          parserCode = '.map($parserCode).${type.isDartCoreSet ? 'toSet' : 'toList'}()';
        }
        return '(data) => data${parserCode ?? ''}';
      }

      if (type case final InterfaceType type) {
        final fromJsonConstructor = type.element.constructors.firstWhereOrNull((e) {
          return e.name == 'fromJson';
        });
        final typeParameter = type.typeArguments.singleOrNull;
        if (fromJsonConstructor != null && typeParameter != null) {
          final parsingCode = _codeParser(element, typeParameter);
          return '(data) => ${type.element.name}.fromJson(data, '
              '(data) => ${parsingCode != null ? '$parsingCode(data as String)' : 'data as String'}'
              ')';
        }
      }

      throw InvalidGenerationSourceError(
        'The iterable type is not supported.',
        todo: 'Use List/Set or IList/ISet.',
        element: element,
      );
    }

    final parsingCode = _codeParser(element, type);
    if (type.isNullableType) {
      return '(data) => data.isNotEmpty '
          '? ${parsingCode != null ? '$parsingCode(data.single)' : 'data.single'} '
          ': null';
    } else {
      return '(data) => ${parsingCode != null ? '$parsingCode(data.single)' : 'data.single'}';
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
          '  return ${_codeFromJson(type.typeArguments.single)};\n'
          '}).${type.isDartCoreSet ? 'toSet' : 'toList'}()\n';
    }
    if (type.isDartCoreMap) {
      return '(data! as Map<String, dynamic>).map((k, data) {\n'
          '  return  MapEntry(k, ${_codeFromJson(type.typeArguments[1])});\n'
          '})\n';
    }

    final element = type.element as ClassElement;
    final constructor = element.constructors.firstWhere((e) => e.name == 'fromJson');

    final args = <String>[
      'data! as ${constructor.formalParameters.first.type.getDisplayString()}',
      ...constructor.formalParameters.skip(1).map((parameter) {
        final typeArgument = type.typeArguments.single;
        return '(data) => ${_codeFromJson(typeArgument)}';
      }),
    ];
    return '${type.getDisplayString()}.fromJson(${args.join(', ')})';
  }

  String _codeToJson(DartType type) {
    if (type.isJson || type is! InterfaceType) return 'data';

    final toJsonMethod = type.getMethod('toJson');
    if (toJsonMethod == null) return 'data';

    if (toJsonMethod.formalParameters.length == 1) {
      final typeArgument = type.typeArguments.single;
      return 'data.toJson((data) => ${_codeToJson(typeArgument)})';
    }
    return 'data.toJson()';
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
        final parserCode = _codeParser(e, e.type);
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
          final args = <String>[
            'request',
            escapeDartString(key),
            _codeListParser(e, e.type),
            if (e.defaultValueCode case final code?) 'defaultValue: $code',
          ];
          return '${e.displayName}: \$parseQueryParameters(${args.join(', ')})';
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
      RouteReturnsText() => 'final data = $methodInvocation;\nreturn Response.ok(data);',
      RouteReturnsJson() =>
        'final data = $methodInvocation;\nreturn JsonResponse.ok(${_codeToJson(returns.type)});',
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

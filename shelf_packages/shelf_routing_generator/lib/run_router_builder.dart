import 'dart:async';

import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:recase/recase.dart';
import 'package:shelf_routing_generator/src/route_handler.dart';
import 'package:shelf_routing_generator/src/utils.dart';
import 'package:source_gen/source_gen.dart';

Builder runRouterBuilder(BuilderOptions options) {
  return SharedPartBuilder(const [RouterGenerator()], 'router');
}

class RouterGenerator extends Generator {
  const RouterGenerator();

  String? _findParserMethod(DartType type) {
    if (type is! InterfaceType) return null;

    final parserMethod = type.getMethod('parse');
    if (parserMethod == null) return null;

    if (!TypeChecker.fromStatic(type).isAssignableFromType(parserMethod.returnType)) return null;

    final firstParameter = parserMethod.parameters.firstOrNull;
    if (firstParameter == null || firstParameter.isNamed) return null;

    if (!firstParameter.type.isDartCoreString) return null;
    if (parserMethod.parameters.skip(1).any((e) => e.isRequired)) return null;

    return '${type.element.name}.${parserMethod.name}';
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

  String _codeAddRoute(RouteHandler _) {
    final RouteHandler(
      :routable,
      method: verb,
      :path,
      :element,
      :hasRequest,
      :pathParameters,
      :bodyParameter,
      :headers,
      :queryParameters,
      :returns,
    ) = _;

    final routeParams = [
      'Request request',
      ...pathParameters.map((e) => 'String ${e.name}'),
    ].join(', ');

    final headersCode = headers.map((e) => "\n\$ensureHasHeader(request, '${e.name}');").join();

    final methodParams = [
      if (hasRequest) 'request',
      ...pathParameters.map((e) {
        final parserCode = _codeParser(e.type);
        return parserCode != null ? '$parserCode(${e.name})' : e.name;
      }),
      if (bodyParameter != null)
        'await \$readBodyAs(request, ${bodyParameter.type.getDisplayString(withNullability: false)}.fromJson)',
      // if (headerParameters.isNotEmpty)
      //   ...headerParameters.map((e) {
      //     final key = e.name.paramCase;
      //     return "${e.name}: \$parseHeaders(request, '$key', ${_codeListParser(e.type)})";
      //   }),
      if (queryParameters.isNotEmpty)
        ...queryParameters.map((e) {
          final key = e.name.paramCase;
          return "${e.name}: \$parseQueryParameters(request, '$key', ${_codeListParser(e.type)})";
        }),
    ].expand((e) sync* {
      yield e;
      yield ',\n';
    }).join();

    var methodInvocation = '';
    if (element.returnType.isDartAsyncFutureOr || element.returnType.isDartAsyncFuture) {
      methodInvocation += 'await ';
    }
    methodInvocation += '\$.${element.name}($methodParams)';

    final responseCode = switch (returns) {
      RouteReturnsType.response => '''
    return $methodInvocation;''',
      RouteReturnsType.json => '''
    final \$data = $methodInvocation;
    return JsonResponse.ok(\$data);''',
      RouteReturnsType.nothing => '''
    $methodInvocation;
    return JsonResponse.ok(null);''',
    };

    return '''
  ..add('$verb', r'$path', ($routeParams) async {$headersCode
    final \$ = request.get<${routable.element.name}>();
    $responseCode
  })''';
  }

  @override
  Future<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final routes = library.classes.expand(RouteHandler.fromClass).toList();
    if (routes.isEmpty) return null;

    final routables = routes.groupListsBy((e) => e.routable.element);

    return routables.entries.map((_) {
      final MapEntry(key: class$, value: routes) = _;
      final routesCode = routes.map(_codeAddRoute).join();
      return '''
Router get _${codePublicVarName('${class$.name}Router')} => Router()\n
  $routesCode;''';
    }).join('\n');
  }
}

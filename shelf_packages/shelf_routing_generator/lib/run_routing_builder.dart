import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:shelf_routing/shelf_routing.dart';
import 'package:shelf_routing_generator/src/routable_handler.dart';
import 'package:shelf_routing_generator/src/utils.dart';
import 'package:source_gen/source_gen.dart';

Builder runRoutingBuilder(BuilderOptions options) {
  return SharedPartBuilder([const GroupsRouterGenerator()], 'routing');
}

class _RoutersRouterHandler {
  static const _checker = TypeChecker.fromRuntime(GenerateRouterFor);

  final PropertyAccessorElement element;
  final List<RoutableHandler> routables;

  static _RoutersRouterHandler? from(PropertyAccessorElement element) {
    if (!element.isGetter) return null;

    final annotation = ConstantReader(_checker.firstAnnotationOf(element));
    if (annotation.isNull) return null;

    return _RoutersRouterHandler._(
      element: element,
      routables: annotation.read('routables').listValue.map((e) {
        final class$ = ConstantReader(e).typeValue.element;
        if (class$ is! ClassElement) {
          throw InvalidGenerationSourceError(
            '$Routable can only be used to annotate classes.',
            element: class$,
          );
        }
        return RoutableHandler.from(class$);
      }).toList(),
    );
  }

  const _RoutersRouterHandler._({required this.element, required this.routables});
}

class GroupsRouterGenerator extends Generator {
  const GroupsRouterGenerator();

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final handlers = library.element.units
        .expand((element) => element.accessors)
        .map(_RoutersRouterHandler.from)
        .nonNulls;

    return handlers.map((handler) => _generateForHandler(handler, buildStep)).join('\n\n');
  }

  String _generateForHandler(_RoutersRouterHandler handler, BuildStep buildStep) {
    final mountedRouters = handler.routables.map((routable) {
      return "..mount('${routable.prefix ?? '/'}', ${routable.element.name}.router)\n";
    }).join();

    return '''
Router get _${codePublicVarName(handler.element.name)} => Router()
  $mountedRouters;''';
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:shelf_routing/shelf_routing.dart';
import 'package:source_gen/source_gen.dart';

class RoutableHandler {
  static const _checker = TypeChecker.fromRuntime(Routable);

  final String? prefix;
  final ClassElement element;

  static RoutableHandler from(ClassElement element) {
    final annotation = ConstantReader(_checker.firstAnnotationOf(element));
    final prefix = annotation.peek('prefix')?.stringValue;

    if (prefix != null && !RegExp(r'^\/.*[^/]$').hasMatch(prefix)) {
      throw InvalidGenerationSourceError('"prefix" field must begin and not end with "/".',
          element: element);
    }

    return RoutableHandler._(
      prefix: prefix,
      element: element,
    );
  }

  const RoutableHandler._({
    required this.prefix,
    required this.element,
  });

  // TODO: Support getters
  // return <ExecutableElement>[
  //         ...element.methods.where(_routeType.hasAnnotationOfExact),
  //         ...element.accessors.where(_routeType.hasAnnotationOfExact)
  //       ]..sort((a, b) => (a.nameOffset).compareTo(b.nameOffset));
  static List<RoutableHandler> fromLibrary(LibraryReader library) {
    return library.classes.map(from).nonNulls.toList();
  }
}

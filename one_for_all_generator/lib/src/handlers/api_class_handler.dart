import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class ApiClassHandler {
  final ClassElement element;
  final Revivable? hostExceptionHandler;

  const ApiClassHandler({
    required this.element,
    required this.hostExceptionHandler,
  });

  factory ApiClassHandler.from(AnnotatedElement _) {
    final AnnotatedElement(:element, :annotation) = _;

    return ApiClassHandler(
      element: element as ClassElement,
      hostExceptionHandler: annotation.peek('hostExceptionHandler')?.revive(),
    );
  }
}

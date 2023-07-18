import 'package:analyzer/dart/element/element.dart';

class ApiClassHandler {
  final ClassElement element;
  final EnumElement hostExceptionElement;
  final EnumElement? flutterExceptionElement;

  const ApiClassHandler({
    required this.element,
    required this.hostExceptionElement,
    required this.flutterExceptionElement,
  });
}

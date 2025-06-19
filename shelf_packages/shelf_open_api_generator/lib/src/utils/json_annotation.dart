import 'package:analyzer/dart/element/element.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:source_gen/source_gen.dart';

abstract final class JsonAnnotation {
  static const _keyChecker = TypeChecker.fromRuntime(JsonKey);
  static const _valueChecker = TypeChecker.fromRuntime(JsonValue);

  static String? getFieldName(Element element) {
    final annotation = _keyChecker.firstAnnotationOf(element);
    if (annotation == null) return null;

    return annotation.getField('name')?.toStringValue();
  }

  static Object? getEnumValue(Element element) {
    final annotation = _valueChecker.firstAnnotationOf(element);
    if (annotation == null) return null;

    final value = annotation.getField('value')!;
    return value.toIntValue() ?? value.toStringValue()!;
  }
}

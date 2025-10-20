import 'package:analyzer/dart/element/element2.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_open_api_generator/src/utils/utils.dart';
import 'package:source_gen/source_gen.dart';

abstract final class JsonAnnotation {
  static const _keyChecker = TypeChecker.typeNamed(JsonKey, inPackage: 'json_annotation');
  static const _valueChecker = TypeChecker.typeNamed(JsonValue, inPackage: 'json_annotation');
  static const _enumChecker = TypeChecker.typeNamed(JsonEnum, inPackage: 'json_annotation');

  static String? getFieldName(Element2 element) {
    final annotation = _keyChecker.firstAnnotationOf(element);
    if (annotation == null) return null;

    return annotation.getField('name')?.toStringValue();
  }

  static Object getEnumValue(EnumElement2 enumElement, FieldElement2 fieldElement) {
    final valueAnnotation = _valueChecker.firstAnnotationOf(fieldElement);
    if (valueAnnotation != null) {
      final value = valueAnnotation.getField('value')!;
      return value.toIntValue() ?? value.toStringValue()!;
    }
    final enumAnnotation = _enumChecker.firstAnnotationOf(enumElement);
    if (enumAnnotation != null) {
      final valueEnumField = enumAnnotation.getField('valueField')?.toStringValue();
      if (valueEnumField != null) {
        final reader = ConstantReader(fieldElement.computeConstantValue());
        final valueReader = reader.read(valueEnumField);
        return valueReader.literalValue!;
      }
    }
    return fieldElement.requireName;
  }
}

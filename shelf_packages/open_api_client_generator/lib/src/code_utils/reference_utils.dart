import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/api_specs.dart';

const overrideAnnotation = CodeExpression(Code('override'));

abstract final class References {
  static const Reference void$ = Reference('void');
  static const Reference object = Reference('Object');
  static const Reference bool = Reference('bool');
  static const Reference num = Reference('num');
  static const Reference int = Reference('int');
  static const Reference double = Reference('double');
  static const Reference string = Reference('String');
  static const Reference dateTime = Reference('DateTime');
  static const Reference uri = Reference('Uri');
  static Reference list([Reference? typeArg]) => TypeReference((b) => b
    ..symbol = 'List'
    ..types.add(typeArg ?? References.void$));
  static Reference map({Reference? key, Reference? value}) => TypeReference((b) => b
    ..symbol = 'Map'
    ..types.add(key ?? jsonValue)
    ..types.add(value ?? jsonValue));

  static Reference future([Reference? typeArg]) => TypeReference((b) => b
    ..symbol = 'Future'
    ..types.add(typeArg ?? References.void$));

  static const Reference jsonMap = Reference('Map<String, dynamic>');
  static final Reference jsonValue = TypeReference((b) => b
    ..symbol = 'Object'
    ..isNullable = true);
}

extension ReferenceExtensions on Reference {
  bool get isObject => symbol == 'Object';
  bool get isBool => symbol == 'bool';
  bool get isNum => symbol == 'num';
  bool get isDouble => symbol == 'double';
  bool get isInt => symbol == 'int';
  bool get isString => symbol == 'String';

  bool get isVoid => symbol == 'void';
  bool get isMap => symbol == 'Map';
  bool get isList => symbol == 'List';
  bool get isDateTime => symbol == 'DateTime';

  bool get isJsonPrimitive => isObject || isBool || isNum || isDouble || isInt || isString;

  bool get isDartCore => isVoid || isJsonPrimitive || isMap || isList || isDateTime;

  bool get isNullable {
    final self = this;
    return self is TypeReference && (self.isNullable ?? false);
  }

  Iterable<Reference> get types {
    final self = this;
    return self is TypeReference ? self.types : const [];
  }

  // ignore: avoid_positional_boolean_parameters
  Reference toNullable([bool? nullable = true]) {
    return TypeReference((b) => b
      ..symbol = symbol
      ..types.replace(types)
      ..isNullable = nullable ?? b.isNullable);
  }

  Reference rebuild(Updates<TypeReferenceBuilder> updates) {
    return TypeReference((b) => b
      ..url = url
      ..symbol = symbol
      ..types.replace(types)
      ..isNullable = isNullable
      ..update(updates));
  }

  String encodeTypes() {
    return types.isEmpty ? '' : '<${types.map((e) => '${e.symbol}${e.encodeTypes()}').join(', ')}>';
  }
}

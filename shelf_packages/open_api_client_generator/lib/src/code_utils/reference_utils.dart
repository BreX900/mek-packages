import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/api_specs.dart';

const overrideAnnotation = CodeExpression(Code('override'));

abstract final class References {
  static const Reference never = Reference('Never');
  static const Reference void$ = Reference('void');
  static const Reference object = Reference('Object');
  static const Reference boolean = Reference('bool');
  static const Reference num = Reference('num');
  static const Reference int = Reference('int');
  static const Reference double = Reference('double');
  static const Reference string = Reference('String');
  static const Reference dateTime = Reference('DateTime');
  static const Reference uri = Reference('Uri');
  static Reference list([Reference? typeArg]) => ref('List', types: [typeArg ?? References.void$]);
  static Reference set([Reference? typeArg]) => ref('Set', types: [typeArg ?? References.void$]);
  static Reference map({Reference? key, Reference? value}) =>
      ref('Map', types: [key ?? jsonValue, value ?? jsonValue]);
  static Reference future([Reference? typeArg]) =>
      ref('Future', types: [typeArg ?? References.void$]);
  static const Reference jsonMap = Reference('Map<String, dynamic>');
  static final Reference jsonValue = ref('Object', isNullable: true);

  static const Reference bytes = Reference('Uint8List');
  static final Reference bytesStream = ref('Stream', types: [bytes]);

  static Reference ref(
    String symbol, {
    List<Reference> types = const [],
    bool isNullable = false,
  }) => TypeReference(
    (b) => b
      ..isNullable = isNullable
      ..symbol = symbol
      ..types.addAll(types),
  );
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
  bool get isSet => symbol == 'Set';
  bool get isDateTime => symbol == 'DateTime';
  bool get isUri => symbol == 'Uri';

  bool get isBytesStream => symbol == 'Stream';
  bool get isBytes => symbol == 'Uint8List';

  bool get isJsonPrimitive => isObject || isBool || isNum || isDouble || isInt || isString;

  bool get isDartCore =>
      isVoid || isJsonPrimitive || isMap || isList || isSet || isDateTime || isUri;

  bool get isNullable {
    final self = this;
    return self is TypeReference && (self.isNullable ?? false);
  }

  Iterable<Reference> get types {
    final self = this;
    return self is TypeReference ? self.types : const [];
  }

  // ignore: avoid_positional_boolean_parameters
  Reference toNullable([bool? nullable = true]) =>
      rebuild((b) => b..isNullable = nullable ?? b.isNullable);

  Reference mergeWith({required bool shouldNullable}) =>
      rebuild((b) => b..isNullable = shouldNullable || (b.isNullable ?? false));

  Reference rebuild(Updates<TypeReferenceBuilder> updates) {
    return TypeReference(
      (b) => b
        ..url = url
        ..symbol = symbol
        ..types.replace(types)
        ..isNullable = isNullable
        ..update(updates),
    );
  }

  String encodeTypes() {
    return types.isEmpty ? '' : '<${types.map((e) => '${e.symbol}${e.encodeTypes()}').join(', ')}>';
  }
}

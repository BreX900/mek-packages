import 'package:code_builder/code_builder.dart';
import 'package:open_api_specification/open_api_spec.dart';

typedef Updates<T> = void Function(T b);

sealed class ApiSpec {
  final SchemaOpenApi schema;
  final String name;

  const ApiSpec({
    required this.schema,
    required this.name,
  });
}

class ApiClass extends ApiSpec {
  final Iterable<String> docs;
  final List<String> implements;
  final List<ApiField> fields;

  const ApiClass({
    required super.schema,
    required this.docs,
    required this.implements,
    required super.name,
    required this.fields,
  });

  Class toSpec(Updates<ClassBuilder> updates) {
    return Class((b) => b
      ..docs.addAll(docs)
      ..name = name
      ..implements.replace(implements.map(Reference.new))
      ..update(updates));
  }
}

class ApiField {
  final String key;
  final Iterable<String> docs;
  final bool isRequired;
  final String name;
  final Reference type;

  const ApiField({
    required this.key,
    required this.docs,
    required this.isRequired,
    required this.name,
    required this.type,
  });

  Parameter toParameter(Updates<ParameterBuilder> updates) {
    return Parameter((b) => b
      ..named = true
      ..required = isRequired
      ..name = name
      ..update(updates));
  }

  Field toField(Updates<FieldBuilder> updates) {
    return Field((b) => b
      ..docs.addAll(docs)
      ..type = type
      ..name = name
      ..update(updates));
  }
}

class ApiEnum extends ApiSpec {
  final Iterable<String> docs;
  final List<ApiEnumValue> values;

  const ApiEnum({
    required super.schema,
    required this.docs,
    required super.name,
    required this.values,
  });

  Enum toSpec(Updates<EnumBuilder> updates) {
    return Enum((b) => b
      ..docs.addAll(docs)
      ..name = name
      ..update(updates));
  }
}

class ApiEnumValue {
  final String name;
  final String value;

  const ApiEnumValue({
    required this.name,
    required this.value,
  });

  EnumValue toSpec(Updates<EnumValueBuilder> updates) {
    return EnumValue((b) => b
      ..name = name
      ..update(updates));
  }
}

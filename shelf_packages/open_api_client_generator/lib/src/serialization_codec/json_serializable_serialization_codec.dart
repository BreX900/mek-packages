import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/api_specs.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/collection_codecs/dart_collection_codec.dart';
import 'package:open_api_client_generator/src/plugins/plugin.dart';
import 'package:open_api_client_generator/src/serialization_codec/serialization_codec.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:recase/recase.dart';

/// Values for the automatic field renaming behavior for `JsonSerializable`.
enum FieldRename {
  /// Use the field name without changes.
  none,

  /// Encodes a field named `kebabCase` with a JSON key `kebab-case`.
  kebab,

  /// Encodes a field named `snakeCase` with a JSON key `snake_case`.
  snake,

  /// Encodes a field named `pascalCase` with a JSON key `PascalCase`.
  pascal,

  /// Encodes a field named `screamingSnakeCase` with a JSON key
  /// `SCREAMING_SNAKE_CASE`
  screamingSnake;

  static FieldRename? fromName(String? name) {
    if (name == null) return null;
    return FieldRename.values.firstWhere((e) => e.name == name);
  }
}

class JsonSerializableSerializationCodec extends SerializationCodec with Plugin {
  final bool implicitCreate;
  final Type? classAnnotation;
  final FieldRename? classFieldRename;
  final Type? enumAnnotation;
  final FieldRename? enumFieldRename;

  const JsonSerializableSerializationCodec({
    super.collectionCodec = const DartCollectionCodec(),
    this.implicitCreate = true,
    this.classAnnotation,
    this.classFieldRename,
    this.enumAnnotation,
    this.enumFieldRename,
  });

  @override
  String encodeDeserialization(Reference type, String varAccess) {
    if (type.isJsonPrimitive) return '$varAccess as ${type.symbol!}';
    if (type.isList) {
      final eDeserialized = encodeDeserialization(type.types.single, 'e');
      return '($varAccess as List<Object?>)'
          '.map((e) => $eDeserialized)'
          '${collectionCodec.encodeToPackage(type)}';
    }
    if (type.isMap) {
      final [keyType, valueType] = type.types.toList();
      final kDeserialized = encodeDeserialization(keyType, 'k');
      final vDeserialized = encodeDeserialization(valueType, 'v');

      return '($varAccess as Map<String, dynamic>)'
          '.map((k, v) => MapEntry($kDeserialized, $vDeserialized))'
          '${collectionCodec.encodeToPackage(type)}';
    }
    return '${type.symbol}.fromJson($varAccess as Map<String, dynamic>)';
  }

  @override
  String encodeSerialization(Reference type, String varAccess) {
    if (type.isJsonPrimitive) return varAccess;
    if (type.isList) {
      return '$varAccess'
          '.map((e) => ${encodeSerialization(type.types.single, 'e')})'
          '${collectionCodec.encodeToCore(type)}';
    }
    if (type.isMap) {
      final [keyType, valueType] = type.types.toList();
      final kSerialized = encodeSerialization(keyType, 'e');
      final vSerialized = encodeSerialization(valueType, 'e');

      return '$varAccess'
          '.map((k, v) => MapEntry($kSerialized, $vSerialized))'
          '${collectionCodec.encodeToCore(type)}';
    }
    return '$varAccess${type.isNullable ? '?' : ''}.toJson()';
  }

  @override
  Class buildDataClass(ApiClass spec) {
    final args = <String>[
      if (classFieldRename != null) 'fieldRename: $classFieldRename',
      if (!implicitCreate) ...['createFactory: true', 'createToJson: true'],
    ];

    return spec.toSpec((b) => b
      ..annotations
          .add(CodeExpression(Code('${classAnnotation ?? 'JsonSerializable'}(${args.join(', ')})')))
      ..constructors.add(Constructor((b) => b
        ..constant = true
        ..optionalParameters.addAll(spec.fields.map((e) {
          return e.toParameter((b) => b..toThis = true);
        }))))
      ..fields.addAll(spec.fields.map((e) {
        final wireName = _resolveWireName(classFieldRename, e.name, e.key);

        return e.toField((b) => b
          ..annotations.addAll([
            if (wireName != null) CodeExpression(Code("JsonKey(name: '${e.key}')")),
          ])
          ..modifier = FieldModifier.final$);
      }))
      ..methods.add(Method((b) => b
        ..static = true
        ..returns = Reference(spec.name)
        ..name = 'fromJson'
        ..requiredParameters.add(Parameter((b) => b
          ..type = References.jsonMap
          ..name = 'map'))
        ..lambda = true
        ..body = Code('_\$${spec.name}FromJson(map)')))
      ..methods.add(Method((b) => b
        ..returns = References.jsonMap
        ..name = 'toJson'
        ..lambda = true
        ..body = Code('_\$${spec.name}ToJson(this)'))));
  }

  @override
  Enum buildDataEnum(ApiEnum spec) {
    return spec.toSpec((b) => b
      ..annotations.addAll([
        if (enumFieldRename != null)
          CodeExpression(Code('${enumAnnotation ?? 'JsonEnum'}(fieldRename: $enumFieldRename)')),
      ])
      ..values.addAll(spec.values.map((e) {
        final wireName = _resolveWireName(enumFieldRename, e.name, e.value);

        return e.toSpec((b) => b
          ..annotations.addAll([
            if (wireName != null) CodeExpression(Code("JsonValue('$wireName')")),
          ]));
      })));
  }

  @override
  Library onLibrary(OpenApi openApi, Library spec) {
    return spec.rebuild(
        (b) => b..directives.add(Directive.import('package:json_annotation/json_annotation.dart')));
  }

  String? _resolveWireName(FieldRename? fieldRename, String original, String target) {
    return target == (fieldRename ?? FieldRename.none).encode(original) ? null : target;
  }
}

extension on FieldRename {
  String encode(String text) {
    return switch (this) {
      FieldRename.none => text,
      FieldRename.kebab => text.paramCase,
      FieldRename.snake => text.snakeCase,
      FieldRename.pascal => text.pascalCase,
      FieldRename.screamingSnake => text.constantCase,
    };
  }
}

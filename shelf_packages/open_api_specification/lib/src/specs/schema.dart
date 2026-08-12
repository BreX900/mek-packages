// ignore_for_file: unintended_html_in_doc_comment

import 'package:json_annotation/json_annotation.dart';
import 'package:open_api_specification/src/specs/base_specs.dart';
import 'package:open_api_specification/src/specs/ref_or_specs.dart';
import 'package:open_api_specification/src/utils/specs_serialization.dart';
import 'package:open_api_specification/src/utils/utils.dart';

part 'schema.g.dart';

@SpecsSerializable()
class GroupMediaOpenApi extends OriginalJson {
  @JsonKey(name: 'text/plain')
  final MediaOpenApi? textPlain;
  @JsonKey(name: 'application/json')
  final MediaOpenApi? json;
  @JsonKey(name: 'application/x-www-form-urlencoded')
  final MediaOpenApi? urlEncoded;
  @JsonKey(name: 'application/octet-stream')
  final MediaOpenApi? octetStream;
  @JsonKey(name: 'multipart/form-data')
  final MediaOpenApi? formData;
  @JsonKey(name: 'image/*')
  final MediaOpenApi? image;
  @JsonKey(name: '*/*')
  final MediaOpenApi? any;

  const GroupMediaOpenApi({
    super.originalJson,
    this.textPlain,
    this.json,
    this.urlEncoded,
    this.octetStream,
    this.formData,
    this.image,
    this.any,
  });

  MediaOpenApi? get jsonOrAny => json ?? any;

  MediaOpenApi? get single => json ?? any ?? urlEncoded;

  factory GroupMediaOpenApi.fromJson(Map<dynamic, dynamic> map) =>
      _$GroupMediaOpenApiFromJson(OriginalJson.wrap(map));
  @override
  Map<String, dynamic> toJson() => _$GroupMediaOpenApiToJson(this);
}

@SpecsSerializable()
class MediaOpenApi with PrettyJsonToString {
  final String? example;
  @JsonKey(toJson: $nullIfEmpty)
  final Map<String, dynamic> examples;

  final SchemaOrRef schema;

  const MediaOpenApi({this.example, this.examples = const {}, required this.schema});

  factory MediaOpenApi.fromJson(Map<dynamic, dynamic> map) => _$MediaOpenApiFromJson(map);
  @override
  Map<String, dynamic> toJson() => _$MediaOpenApiToJson(this);
}

/// https://swagger.io/specification/#data-types
@JsonEnum()
enum TypeOpenApi { boolean, number, integer, string, array, object }

/// https://spec.openapis.org/registry/format/
enum FormatOpenApi {
  int32,
  int64,
  double,
  decimal,
  float,
  string,

  date,
  @JsonValue('date-time')
  dateTime,

  uuid,
  email,
  url,
  uri,

  /// File upload
  binary,
  base64,
}

@SpecsSerializable()
class SchemaOpenApi extends OriginalJson implements SchemaOrRef {
  final String? name;
  final String? title;
  final String? description;
  final Object? example;

  final TypeOpenApi? type;

  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final FormatOpenApi? format;

  /// With [TypeOpenApi.integer] | [TypeOpenApi.string]
  @JsonKey(name: 'enum')
  final List<Object>? enum$;

  /// Must be present if the type is [TypeOpenApi.array]
  final SchemaOrRef? items;

  /// With [TypeOpenApi.object]
  final Map<String, SchemaOrRef>? properties;

  /// With [TypeOpenApi.object]. It define a Map<String, *>
  final SchemaOrRef? propertyNames;
  @JsonKey(readValue: _readAdditionalProperties)
  final SchemaOrRef? additionalProperties;

  final List<SchemaOrRef>? allOf;

  // final List<SchemaOrRefOpenApi> anyOf;

  // final List<SchemaOrRefOpenApi> oneOf;

  /// With [TypeOpenApi.object]
  final List<String>? required;

  @JsonKey(toJson: $nullIfFalse)
  final bool nullable;

  @JsonKey(name: 'default')
  final Object? default$;

  final Object? $original;

  /// Json Properties

  // multipleOf
  // maximum
  // exclusiveMaximum
  // minimum
  // exclusiveMinimum
  // maxLength
  // minLength
  // pattern (This string SHOULD be a valid regular expression, according to the Ecma-262 Edition 5.1 regular expression dialect)
  // maxItems
  // minItems
  @JsonKey(toJson: $nullIfFalse)
  final bool? uniqueItems;
  // maxProperties
  // minProperties
  // required
  // enum

  const SchemaOpenApi({
    super.originalJson,
    this.name,
    this.title,
    this.description,
    this.example,
    this.type,
    this.format,
    this.enum$,
    this.items,
    this.properties,
    this.additionalProperties,
    this.propertyNames,
    this.allOf,
    this.required,
    this.nullable = false,
    this.default$,
    this.$original,
    this.uniqueItems,
  });

  String get requireName => ensureIsNotNull('name', name);

  @override
  SchemaOpenApi resolve(ComponentsOpenApi components) => this;

  static Object? _readAdditionalProperties(Map<dynamic, dynamic> data, String key) {
    final value = data[key];
    return switch (value) {
      bool() => null,
      _ => value,
    };
  }

  factory SchemaOpenApi.fromJson(Map<dynamic, dynamic> map) =>
      _$SchemaOpenApiFromJson(OriginalJson.wrap(map));
  @override
  Map<String, dynamic> toJson() => _$SchemaOpenApiToJson(this);
}

class SchemaRef extends SchemaOrRef {
  final String ref;

  factory SchemaRef(String ref) {
    final segments = ref.split('/');
    if (segments[0] != '#' ||
        segments[1] != 'components' ||
        segments[2] != 'schemas' ||
        segments.length != 4) {
      throw ArgumentError.value(ref, 'SchemaOpenApi', 'Invalid reference!');
    }
    return SchemaRef._(ref);
  }

  factory SchemaRef.from(String identifier) => SchemaRef('#/components/schemas/$identifier');

  const SchemaRef._(this.ref);

  @override
  SchemaOpenApi resolve(ComponentsOpenApi components) {
    final schema = components.schemas[ref.split('/').last];
    return ArgumentError.checkNotNull(schema, ref);
  }

  @override
  Map<String, dynamic> toJson() => {r'$ref': ref};
}

sealed class SchemaOrRef extends RefOr<SchemaOpenApi> {
  const SchemaOrRef();

  factory SchemaOrRef.fromJson(Map<dynamic, dynamic> map) {
    final ref = map[r'$ref'] as String?;
    if (ref == null) return SchemaOpenApi.fromJson(map);

    return SchemaRef(ref);
  }
  @override
  Map<String, dynamic> toJson();
}

extension SchemaOpenApiX on SchemaOpenApi {
  /// A [schema] contains this property
  /// A property [name]
  bool canNull(String name, SchemaOpenApi schema) {
    if (schema.nullable) return true;
    if ((required ?? const []).contains(name)) return false;
    return true;
  }

  /// A schema contains this property
  /// A property [name]
  bool isRequired(String name) {
    if ((required ?? const []).contains(name)) return true;
    return false;
  }

  bool get isClass => properties != null || allOf != null;

  bool get isEnum => enum$ != null;
}

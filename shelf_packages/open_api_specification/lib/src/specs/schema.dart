import 'package:json_annotation/json_annotation.dart';
import 'package:open_api_specification/src/specs/ref_or_specs.dart';
import 'package:open_api_specification/src/utils/specs_serialization.dart';
import 'package:open_api_specification/src/utils/utils.dart';

part 'schema.g.dart';

@SpecsSerializable()
class GroupMediaOpenApi with PrettyJsonToString {
  @JsonKey(name: 'application/json')
  final MediaOpenApi? json;

  @JsonKey(name: 'application/x-www-form-urlencoded')
  final MediaOpenApi? urlEncoded;

  @JsonKey(name: 'multipart/form-data')
  final MediaOpenApi? formData;

  @JsonKey(name: 'image/*')
  final MediaOpenApi? image;

  @JsonKey(name: '*/*')
  final MediaOpenApi? any;

  const GroupMediaOpenApi({
    this.json,
    this.urlEncoded,
    this.formData,
    this.image,
    this.any,
  });

  MediaOpenApi? get jsonOrAny => json ?? any;

  MediaOpenApi? get single => json ?? any ?? urlEncoded;

  factory GroupMediaOpenApi.fromJson(Map<dynamic, dynamic> map) => _$GroupMediaOpenApiFromJson(map);
  @override
  Map<String, dynamic> toJson() => _$GroupMediaOpenApiToJson(this);
}

@SpecsSerializable()
class MediaOpenApi with PrettyJsonToString {
  final String? example;
  @JsonKey(toJson: $nullIfEmpty)
  final Map<String, dynamic> examples;

  final SchemaOpenApi schema;

  const MediaOpenApi({
    this.example,
    this.examples = const {},
    required this.schema,
  });

  factory MediaOpenApi.fromJson(Map<dynamic, dynamic> map) => _$MediaOpenApiFromJson(map);
  @override
  Map<String, dynamic> toJson() => _$MediaOpenApiToJson(this);
}

/// https://swagger.io/specification/#data-types
@JsonEnum()
enum TypeOpenApi {
  boolean,
  number,
  integer,
  string,
  array,
  object,
}

enum FormatOpenApi {
  int32,
  int64,
  double,
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
  base64;
}

@SpecsSerializable()
class SchemaOpenApi implements RefOr<SchemaOpenApi> {
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
  final SchemaOpenApi? items;

  /// With [TypeOpenApi.object]
  final Map<String, SchemaOpenApi>? properties;

  /// With [TypeOpenApi.object]. It define a Map<String, *>
  final SchemaOpenApi? additionalProperties;

  final List<SchemaOpenApi>? allOf;

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

  // title
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
  final bool? uniqueItems;
  // maxProperties
  // minProperties
  // required
  // enum

  const SchemaOpenApi({
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
    this.allOf,
    this.required,
    this.nullable = false,
    this.default$,
    this.$original,
    this.uniqueItems,
  });

  factory SchemaOpenApi.fromJson(Map<dynamic, dynamic> map) => _SchemaOpenApi(map);
  @override
  Map<String, dynamic> toJson() => _$SchemaOpenApiToJson(this);

  @override
  R fold<R>(R Function(String ref) onRef, R Function(SchemaOpenApi p1) on) => on(this);
}

class _SchemaOpenApi extends RefOr<SchemaOpenApi> with PrettyJsonToString implements SchemaOpenApi {
  final Map<dynamic, dynamic> _json;
  SchemaOpenApi? _delegate$;
  SchemaOpenApi get _delegate => _delegate$ ??= _$SchemaOpenApiFromJson(_json);

  @override
  String? get name => _delegate.name;
  @override
  String? get title => _delegate.title;
  @override
  String? get description => _delegate.description;
  @override
  Object? get example => _delegate.example;

  @override
  TypeOpenApi? get type => _delegate.type;

  @override
  FormatOpenApi? get format => _delegate.format;

  /// With [TypeOpenApi.integer] | [TypeOpenApi.string]
  @override
  @JsonKey(name: 'enum')
  List<Object>? get enum$ => _delegate.enum$;

  /// Must be present if the type is [TypeOpenApi.array]
  @override
  SchemaOpenApi? get items => _delegate.items;

  /// With [TypeOpenApi.object]
  @override
  Map<String, SchemaOpenApi>? get properties => _delegate.properties;

  /// With [TypeOpenApi.object]. It define a Map<String, *>
  @override
  SchemaOpenApi? get additionalProperties => _delegate.additionalProperties;

  @override
  List<SchemaOpenApi>? get allOf => _delegate.allOf;

  // List<SchemaOrRefOpenApi> anyOf;

  // List<SchemaOrRefOpenApi> oneOf;

  /// With [TypeOpenApi.object]
  @override
  List<String>? get required => _delegate.required;

  @override
  @JsonKey(toJson: $nullIfFalse)
  bool get nullable => _delegate.nullable;

  @override
  @JsonKey(name: 'default')
  Object? get default$ => _delegate.default$;

  @override
  Object? get $original => _delegate.$original;

  /// JSON PROPERTIES

  @override
  bool? get uniqueItems => _delegate.uniqueItems;

  _SchemaOpenApi(this._json);

  @override
  R fold<R>(R Function(String ref) onRef, R Function(SchemaOpenApi p1) on) => on(this);

  @override
  Map<String, dynamic> toJson() => _delegate.toJson();
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

  Map<String, SchemaOpenApi> get allProperties {
    final allOfProperties = allOf?.map((e) => e.properties).nonNulls;

    return {
      if (allOfProperties != null)
        for (final properties in allOfProperties) ...properties,
      ...?properties,
    };
  }
}

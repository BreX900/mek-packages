// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, avoid_annotating_with_dynamic, unnecessary_null_checks

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMediaOpenApi _$GroupMediaOpenApiFromJson(Map json) => $checkedCreate(
  'GroupMediaOpenApi',
  json,
  ($checkedConvert) {
    final val = GroupMediaOpenApi(
      originalJson: $checkedConvert(r'$originalJson', (v) => v as Map?),
      textPlain: $checkedConvert(
        'text/plain',
        (v) => v == null ? null : MediaOpenApi.fromJson(v as Map),
      ),
      json: $checkedConvert(
        'application/json',
        (v) => v == null ? null : MediaOpenApi.fromJson(v as Map),
      ),
      urlEncoded: $checkedConvert(
        'application/x-www-form-urlencoded',
        (v) => v == null ? null : MediaOpenApi.fromJson(v as Map),
      ),
      octetStream: $checkedConvert(
        'application/octet-stream',
        (v) => v == null ? null : MediaOpenApi.fromJson(v as Map),
      ),
      formData: $checkedConvert(
        'multipart/form-data',
        (v) => v == null ? null : MediaOpenApi.fromJson(v as Map),
      ),
      image: $checkedConvert(
        'image/*',
        (v) => v == null ? null : MediaOpenApi.fromJson(v as Map),
      ),
      any: $checkedConvert(
        '*/*',
        (v) => v == null ? null : MediaOpenApi.fromJson(v as Map),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'originalJson': r'$originalJson',
    'textPlain': 'text/plain',
    'json': 'application/json',
    'urlEncoded': 'application/x-www-form-urlencoded',
    'octetStream': 'application/octet-stream',
    'formData': 'multipart/form-data',
    'image': 'image/*',
    'any': '*/*',
  },
);

Map<String, dynamic> _$GroupMediaOpenApiToJson(GroupMediaOpenApi instance) =>
    <String, dynamic>{
      'text/plain': ?instance.textPlain?.toJson(),
      'application/json': ?instance.json?.toJson(),
      'application/x-www-form-urlencoded': ?instance.urlEncoded?.toJson(),
      'application/octet-stream': ?instance.octetStream?.toJson(),
      'multipart/form-data': ?instance.formData?.toJson(),
      'image/*': ?instance.image?.toJson(),
      '*/*': ?instance.any?.toJson(),
    };

MediaOpenApi _$MediaOpenApiFromJson(Map json) => $checkedCreate(
  'MediaOpenApi',
  json,
  ($checkedConvert) {
    final val = MediaOpenApi(
      example: $checkedConvert('example', (v) => v as String?),
      examples: $checkedConvert(
        'examples',
        (v) => (v as Map?)?.map((k, e) => MapEntry(k as String, e)) ?? const {},
      ),
      schema: $checkedConvert('schema', (v) => SchemaOrRef.fromJson(v as Map)),
    );
    return val;
  },
);

Map<String, dynamic> _$MediaOpenApiToJson(MediaOpenApi instance) =>
    <String, dynamic>{
      'example': ?instance.example,
      'examples': ?$nullIfEmpty(instance.examples),
      'schema': instance.schema.toJson(),
    };

SchemaOpenApi _$SchemaOpenApiFromJson(Map json) => $checkedCreate(
  'SchemaOpenApi',
  json,
  ($checkedConvert) {
    final val = SchemaOpenApi(
      originalJson: $checkedConvert(r'$originalJson', (v) => v as Map?),
      name: $checkedConvert('name', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String?),
      description: $checkedConvert('description', (v) => v as String?),
      example: $checkedConvert('example', (v) => v),
      type: $checkedConvert(
        'type',
        (v) => $enumDecodeNullable(_$TypeOpenApiEnumMap, v),
      ),
      format: $checkedConvert(
        'format',
        (v) => $enumDecodeNullable(
          _$FormatOpenApiEnumMap,
          v,
          unknownValue: JsonKey.nullForUndefinedEnumValue,
        ),
      ),
      enum$: $checkedConvert(
        'enum',
        (v) => (v as List<dynamic>?)?.map((e) => e as Object).toList(),
      ),
      items: $checkedConvert(
        'items',
        (v) => v == null ? null : SchemaOrRef.fromJson(v as Map),
      ),
      properties: $checkedConvert(
        'properties',
        (v) => (v as Map?)?.map(
          (k, e) => MapEntry(k as String, SchemaOrRef.fromJson(e as Map)),
        ),
      ),
      additionalProperties: $checkedConvert(
        'additionalProperties',
        (v) => v == null ? null : SchemaOrRef.fromJson(v as Map),
        readValue: SchemaOpenApi._readAdditionalProperties,
      ),
      propertyNames: $checkedConvert(
        'propertyNames',
        (v) => v == null ? null : SchemaOrRef.fromJson(v as Map),
      ),
      allOf: $checkedConvert(
        'allOf',
        (v) => (v as List<dynamic>?)
            ?.map((e) => SchemaOrRef.fromJson(e as Map))
            .toList(),
      ),
      required: $checkedConvert(
        'required',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      nullable: $checkedConvert('nullable', (v) => v as bool? ?? false),
      default$: $checkedConvert('default', (v) => v),
      $original: $checkedConvert(r'$original', (v) => v),
      uniqueItems: $checkedConvert('uniqueItems', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'originalJson': r'$originalJson',
    r'enum$': 'enum',
    r'default$': 'default',
  },
);

Map<String, dynamic> _$SchemaOpenApiToJson(
  SchemaOpenApi instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'title': ?instance.title,
  'description': ?instance.description,
  'example': ?instance.example,
  'type': ?_$TypeOpenApiEnumMap[instance.type],
  'format': ?_$FormatOpenApiEnumMap[instance.format],
  'enum': ?instance.enum$,
  'items': ?instance.items?.toJson(),
  'properties': ?instance.properties?.map((k, e) => MapEntry(k, e.toJson())),
  'propertyNames': ?instance.propertyNames?.toJson(),
  'additionalProperties': ?instance.additionalProperties?.toJson(),
  'allOf': ?instance.allOf?.map((e) => e.toJson()).toList(),
  'required': ?instance.required,
  'nullable': ?$nullIfFalse(instance.nullable),
  'default': ?instance.default$,
  r'$original': ?instance.$original,
  'uniqueItems': ?$nullIfFalse(instance.uniqueItems),
};

const _$TypeOpenApiEnumMap = {
  TypeOpenApi.boolean: 'boolean',
  TypeOpenApi.number: 'number',
  TypeOpenApi.integer: 'integer',
  TypeOpenApi.string: 'string',
  TypeOpenApi.array: 'array',
  TypeOpenApi.object: 'object',
};

const _$FormatOpenApiEnumMap = {
  FormatOpenApi.int32: 'int32',
  FormatOpenApi.int64: 'int64',
  FormatOpenApi.double: 'double',
  FormatOpenApi.decimal: 'decimal',
  FormatOpenApi.float: 'float',
  FormatOpenApi.string: 'string',
  FormatOpenApi.date: 'date',
  FormatOpenApi.dateTime: 'date-time',
  FormatOpenApi.uuid: 'uuid',
  FormatOpenApi.email: 'email',
  FormatOpenApi.url: 'url',
  FormatOpenApi.uri: 'uri',
  FormatOpenApi.binary: 'binary',
  FormatOpenApi.base64: 'base64',
};

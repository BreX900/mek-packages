// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, avoid_annotating_with_dynamic

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMediaOpenApi _$GroupMediaOpenApiFromJson(Map json) => $checkedCreate(
      'GroupMediaOpenApi',
      json,
      ($checkedConvert) {
        final val = GroupMediaOpenApi(
          json: $checkedConvert(
              'application/json', (v) => v == null ? null : MediaOpenApi.fromJson(v as Map)),
          urlEncoded: $checkedConvert('application/x-www-form-urlencoded',
              (v) => v == null ? null : MediaOpenApi.fromJson(v as Map)),
          formData: $checkedConvert(
              'multipart/form-data', (v) => v == null ? null : MediaOpenApi.fromJson(v as Map)),
          image:
              $checkedConvert('image/*', (v) => v == null ? null : MediaOpenApi.fromJson(v as Map)),
          any: $checkedConvert('*/*', (v) => v == null ? null : MediaOpenApi.fromJson(v as Map)),
        );
        return val;
      },
      fieldKeyMap: const {
        'json': 'application/json',
        'urlEncoded': 'application/x-www-form-urlencoded',
        'formData': 'multipart/form-data',
        'image': 'image/*',
        'any': '*/*'
      },
    );

Map<String, dynamic> _$GroupMediaOpenApiToJson(GroupMediaOpenApi instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('application/json', instance.json?.toJson());
  writeNotNull('application/x-www-form-urlencoded', instance.urlEncoded?.toJson());
  writeNotNull('multipart/form-data', instance.formData?.toJson());
  writeNotNull('image/*', instance.image?.toJson());
  writeNotNull('*/*', instance.any?.toJson());
  return val;
}

MediaOpenApi _$MediaOpenApiFromJson(Map json) => $checkedCreate(
      'MediaOpenApi',
      json,
      ($checkedConvert) {
        final val = MediaOpenApi(
          example: $checkedConvert('example', (v) => v as String?),
          examples: $checkedConvert(
              'examples',
              (v) =>
                  (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  ) ??
                  const {}),
          schema: $checkedConvert('schema', (v) => SchemaOpenApi.fromJson(v as Map)),
        );
        return val;
      },
    );

Map<String, dynamic> _$MediaOpenApiToJson(MediaOpenApi instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('example', instance.example);
  writeNotNull('examples', $nullIfEmpty(instance.examples));
  val['schema'] = instance.schema.toJson();
  return val;
}

SchemaOpenApi _$SchemaOpenApiFromJson(Map json) => $checkedCreate(
      'SchemaOpenApi',
      json,
      ($checkedConvert) {
        final val = SchemaOpenApi(
          name: $checkedConvert('name', (v) => v as String?),
          title: $checkedConvert('title', (v) => v as String?),
          description: $checkedConvert('description', (v) => v as String?),
          example: $checkedConvert('example', (v) => v),
          type: $checkedConvert('type', (v) => $enumDecodeNullable(_$TypeOpenApiEnumMap, v)),
          format: $checkedConvert(
              'format',
              (v) => $enumDecodeNullable(_$FormatOpenApiEnumMap, v,
                  unknownValue: JsonKey.nullForUndefinedEnumValue)),
          enum$: $checkedConvert(
              'enum', (v) => (v as List<dynamic>?)?.map((e) => e as Object).toList()),
          items:
              $checkedConvert('items', (v) => v == null ? null : SchemaOpenApi.fromJson(v as Map)),
          properties: $checkedConvert(
              'properties',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, SchemaOpenApi.fromJson(e as Map)),
                  )),
          additionalProperties: $checkedConvert(
              'additionalProperties', (v) => v == null ? null : SchemaOpenApi.fromJson(v as Map)),
          allOf: $checkedConvert('allOf',
              (v) => (v as List<dynamic>?)?.map((e) => SchemaOpenApi.fromJson(e as Map)).toList()),
          required: $checkedConvert(
              'required', (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          nullable: $checkedConvert('nullable', (v) => v as bool? ?? false),
          default$: $checkedConvert('default', (v) => v),
          $original: $checkedConvert(r'$original', (v) => v),
          uniqueItems: $checkedConvert('uniqueItems', (v) => v as bool?),
        );
        return val;
      },
      fieldKeyMap: const {r'enum$': 'enum', r'default$': 'default'},
    );

Map<String, dynamic> _$SchemaOpenApiToJson(SchemaOpenApi instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  writeNotNull('example', instance.example);
  writeNotNull('type', _$TypeOpenApiEnumMap[instance.type]);
  writeNotNull('format', _$FormatOpenApiEnumMap[instance.format]);
  writeNotNull('enum', instance.enum$);
  writeNotNull('items', instance.items?.toJson());
  writeNotNull('properties', instance.properties?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull('additionalProperties', instance.additionalProperties?.toJson());
  writeNotNull('allOf', instance.allOf?.map((e) => e.toJson()).toList());
  writeNotNull('required', instance.required);
  writeNotNull('nullable', $nullIfFalse(instance.nullable));
  writeNotNull('default', instance.default$);
  writeNotNull(r'$original', instance.$original);
  writeNotNull('uniqueItems', instance.uniqueItems);
  return val;
}

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

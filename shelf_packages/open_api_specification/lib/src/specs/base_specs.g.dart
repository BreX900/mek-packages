// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, avoid_annotating_with_dynamic

part of 'base_specs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenApi _$OpenApiFromJson(Map json) =>
    $checkedCreate('OpenApi', json, ($checkedConvert) {
      final val = OpenApi(
        openapi: $checkedConvert('openapi', (v) => v as String),
        info: $checkedConvert('info', (v) => InfoOpenApi.fromJson(v as Map)),
        servers: $checkedConvert(
          'servers',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => ServerOpenApi.fromJson(e as Map))
                  .toList() ??
              const [],
        ),
        paths: $checkedConvert(
          'paths',
          (v) => (v as Map).map(
            (k, e) => MapEntry(k as String, ItemPathOpenApi.fromJson(e as Map)),
          ),
        ),
        components: $checkedConvert(
          'components',
          (v) => v == null
              ? const ComponentsOpenApi()
              : ComponentsOpenApi.fromJson(v as Map),
        ),
        tags: $checkedConvert(
          'tags',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => TagOpenApi.fromJson(e as Map))
                  .toList() ??
              const [],
        ),
      );
      return val;
    });

Map<String, dynamic> _$OpenApiToJson(OpenApi instance) => <String, dynamic>{
  'openapi': instance.openapi,
  'info': instance.info.toJson(),
  'servers': ?$nullIfEmpty(instance.servers),
  'paths': instance.paths.map((k, e) => MapEntry(k, e.toJson())),
  'components': instance.components.toJson(),
  'tags': instance.tags.map((e) => e.toJson()).toList(),
};

ItemPathOpenApi _$ItemPathOpenApiFromJson(Map json) =>
    $checkedCreate('ItemPathOpenApi', json, ($checkedConvert) {
      final val = ItemPathOpenApi(
        summary: $checkedConvert('summary', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
        get: $checkedConvert(
          'get',
          (v) => v == null ? null : OperationOpenApi.fromJson(v as Map),
        ),
        put: $checkedConvert(
          'put',
          (v) => v == null ? null : OperationOpenApi.fromJson(v as Map),
        ),
        post: $checkedConvert(
          'post',
          (v) => v == null ? null : OperationOpenApi.fromJson(v as Map),
        ),
        delete: $checkedConvert(
          'delete',
          (v) => v == null ? null : OperationOpenApi.fromJson(v as Map),
        ),
        head: $checkedConvert(
          'head',
          (v) => v == null ? null : OperationOpenApi.fromJson(v as Map),
        ),
        patch: $checkedConvert(
          'patch',
          (v) => v == null ? null : OperationOpenApi.fromJson(v as Map),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ItemPathOpenApiToJson(ItemPathOpenApi instance) =>
    <String, dynamic>{
      'summary': ?instance.summary,
      'description': ?instance.description,
      'get': ?instance.get?.toJson(),
      'put': ?instance.put?.toJson(),
      'post': ?instance.post?.toJson(),
      'delete': ?instance.delete?.toJson(),
      'head': ?instance.head?.toJson(),
      'patch': ?instance.patch?.toJson(),
    };

OperationOpenApi _$OperationOpenApiFromJson(Map json) => $checkedCreate(
  'OperationOpenApi',
  json,
  ($checkedConvert) {
    final val = OperationOpenApi(
      tags: $checkedConvert(
        'tags',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ),
      summary: $checkedConvert('summary', (v) => v as String?),
      description: $checkedConvert('description', (v) => v as String?),
      operationId: $checkedConvert('operationId', (v) => v as String?),
      parameters: $checkedConvert(
        'parameters',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => ParameterOpenApi.fromJson(e as Map))
                .toList() ??
            const [],
      ),
      requestBody: $checkedConvert(
        'requestBody',
        (v) => v == null ? null : RequestBodyOpenApi.fromJson(v as Map),
      ),
      responses: $checkedConvert(
        'responses',
        (v) => OperationOpenApi._responsesFromJson(v as Map),
      ),
      deprecated: $checkedConvert('deprecated', (v) => v as bool? ?? false),
      security: $checkedConvert(
        'security',
        (v) =>
            (v as List<dynamic>?)
                ?.map(
                  (e) => (e as Map).map(
                    (k, e) => MapEntry(
                      k as String,
                      (e as List<dynamic>).map((e) => e as String).toList(),
                    ),
                  ),
                )
                .toList() ??
            const [],
      ),
      servers: $checkedConvert(
        'servers',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => ServerOpenApi.fromJson(e as Map))
                .toList() ??
            const [],
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$OperationOpenApiToJson(OperationOpenApi instance) =>
    <String, dynamic>{
      'tags': ?$nullIfEmpty(instance.tags),
      'summary': ?instance.summary,
      'description': ?instance.description,
      'operationId': ?instance.operationId,
      'parameters': ?$nullIfEmpty(instance.parameters),
      'requestBody': ?instance.requestBody?.toJson(),
      'responses': instance.responses.map(
        (k, e) => MapEntry(k.toString(), e.toJson()),
      ),
      'deprecated': ?$nullIfFalse(instance.deprecated),
      'security': ?$nullIfEmpty(instance.security),
      'servers': ?$nullIfEmpty(instance.servers),
    };

ParameterOpenApi _$ParameterOpenApiFromJson(Map json) =>
    $checkedCreate('ParameterOpenApi', json, ($checkedConvert) {
      final val = ParameterOpenApi(
        description: $checkedConvert('description', (v) => v as String?),
        example: $checkedConvert('example', (v) => v),
        name: $checkedConvert('name', (v) => v as String),
        in$: $checkedConvert(
          'in',
          (v) => $enumDecode(_$ParameterInOpenApiEnumMap, v),
        ),
        required: $checkedConvert('required', (v) => v as bool? ?? false),
        deprecated: $checkedConvert('deprecated', (v) => v as bool? ?? false),
        style: $checkedConvert('style', (v) => v as String?),
        explode: $checkedConvert('explode', (v) => v as bool?),
        schema: $checkedConvert(
          'schema',
          (v) => v == null ? null : SchemaOpenApi.fromJson(v as Map),
        ),
        examples: $checkedConvert(
          'examples',
          (v) =>
              (v as Map?)?.map((k, e) => MapEntry(k as String, e)) ?? const {},
        ),
      );
      return val;
    }, fieldKeyMap: const {r'in$': 'in'});

Map<String, dynamic> _$ParameterOpenApiToJson(ParameterOpenApi instance) =>
    <String, dynamic>{
      'description': ?instance.description,
      'example': ?instance.example,
      'examples': ?$nullIfEmpty(instance.examples),
      'name': instance.name,
      'in': _$ParameterInOpenApiEnumMap[instance.in$]!,
      'required': instance.required,
      'deprecated': ?$nullIfFalse(instance.deprecated),
      'style': ?instance.style,
      'explode': ?instance.explode,
      'schema': ?instance.schema?.toJson(),
    };

const _$ParameterInOpenApiEnumMap = {
  ParameterInOpenApi.path: 'path',
  ParameterInOpenApi.query: 'query',
  ParameterInOpenApi.header: 'header',
  ParameterInOpenApi.cookie: 'cookie',
};

RequestBodyOpenApi _$RequestBodyOpenApiFromJson(Map json) =>
    $checkedCreate('RequestBodyOpenApi', json, ($checkedConvert) {
      final val = RequestBodyOpenApi(
        description: $checkedConvert('description', (v) => v as String?),
        required: $checkedConvert('required', (v) => v as bool? ?? false),
        content: $checkedConvert(
          'content',
          (v) => GroupMediaOpenApi.fromJson(v as Map),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RequestBodyOpenApiToJson(RequestBodyOpenApi instance) =>
    <String, dynamic>{
      'description': ?instance.description,
      'required': instance.required,
      'content': instance.content.toJson(),
    };

ResponseOpenApi _$ResponseOpenApiFromJson(Map json) =>
    $checkedCreate('ResponseOpenApi', json, ($checkedConvert) {
      final val = ResponseOpenApi(
        description: $checkedConvert('description', (v) => v as String),
        headers: $checkedConvert(
          'headers',
          (v) =>
              (v as Map?)?.map((k, e) => MapEntry(k as String, e)) ?? const {},
        ),
        content: $checkedConvert(
          'content',
          (v) => v == null ? null : GroupMediaOpenApi.fromJson(v as Map),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ResponseOpenApiToJson(ResponseOpenApi instance) =>
    <String, dynamic>{
      'description': instance.description,
      'headers': ?$nullIfEmpty(instance.headers),
      'content': ?instance.content?.toJson(),
    };

ComponentsOpenApi _$ComponentsOpenApiFromJson(Map json) =>
    $checkedCreate('ComponentsOpenApi', json, ($checkedConvert) {
      final val = ComponentsOpenApi(
        schemas: $checkedConvert(
          'schemas',
          (v) =>
              (v as Map?)?.map(
                (k, e) =>
                    MapEntry(k as String, SchemaOpenApi.fromJson(e as Map)),
              ) ??
              const {},
        ),
        responses: $checkedConvert(
          'responses',
          (v) =>
              (v as Map?)?.map(
                (k, e) =>
                    MapEntry(k as String, ResponseOpenApi.fromJson(e as Map)),
              ) ??
              const {},
        ),
        parameters: $checkedConvert(
          'parameters',
          (v) =>
              (v as Map?)?.map(
                (k, e) =>
                    MapEntry(k as String, ParameterOpenApi.fromJson(e as Map)),
              ) ??
              const {},
        ),
        requestBodies: $checkedConvert(
          'requestBodies',
          (v) =>
              (v as Map?)?.map((k, e) => MapEntry(k as String, e)) ?? const {},
        ),
        securitySchemes: $checkedConvert(
          'securitySchemes',
          (v) =>
              (v as Map?)?.map(
                (k, e) => MapEntry(
                  k as String,
                  SecuritySchemeOpenApi.fromJson(e as Map),
                ),
              ) ??
              const {},
        ),
      );
      return val;
    });

Map<String, dynamic> _$ComponentsOpenApiToJson(ComponentsOpenApi instance) =>
    <String, dynamic>{
      'schemas': ?$nullIfEmpty(instance.schemas),
      'responses': ?$nullIfEmpty(instance.responses),
      'parameters': ?$nullIfEmpty(instance.parameters),
      'requestBodies': ?$nullIfEmpty(instance.requestBodies),
      'securitySchemes': ?$nullIfEmpty(instance.securitySchemes),
    };

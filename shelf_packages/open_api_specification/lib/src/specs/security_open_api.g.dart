// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, avoid_annotating_with_dynamic

part of 'security_open_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecuritySchemeOpenApi _$SecuritySchemeOpenApiFromJson(Map json) =>
    $checkedCreate('SecuritySchemeOpenApi', json, ($checkedConvert) {
      final val = SecuritySchemeOpenApi(
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$SecuritySchemeTypeOpenApiEnumMap, v),
        ),
        description: $checkedConvert('description', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        in$: $checkedConvert(
          'in',
          (v) => $enumDecodeNullable(_$SecuritySchemeInOpenApiEnumMap, v),
        ),
        scheme: $checkedConvert(
          'scheme',
          (v) => SecuritySchemeNameOpenApi.fromJson(v as String?),
        ),
        bearerFormat: $checkedConvert('bearerFormat', (v) => v as String?),
        flows: $checkedConvert(
          'flows',
          (v) => v == null ? null : OAuthFlowsOpenApi.fromJson(v as Map),
        ),
        openIdConnectUrl: $checkedConvert(
          'openIdConnectUrl',
          (v) => v as String?,
        ),
      );
      return val;
    }, fieldKeyMap: const {r'in$': 'in'});

Map<String, dynamic> _$SecuritySchemeOpenApiToJson(
  SecuritySchemeOpenApi instance,
) => <String, dynamic>{
  'type': _$SecuritySchemeTypeOpenApiEnumMap[instance.type]!,
  'description': ?instance.description,
  'name': ?instance.name,
  'in': ?_$SecuritySchemeInOpenApiEnumMap[instance.in$],
  'scheme': ?_$SecuritySchemeNameOpenApiEnumMap[instance.scheme],
  'bearerFormat': ?instance.bearerFormat,
  'flows': ?instance.flows?.toJson(),
  'openIdConnectUrl': ?instance.openIdConnectUrl,
};

const _$SecuritySchemeTypeOpenApiEnumMap = {
  SecuritySchemeTypeOpenApi.apiKey: 'apiKey',
  SecuritySchemeTypeOpenApi.http: 'http',
  SecuritySchemeTypeOpenApi.oauth2: 'oauth2',
  SecuritySchemeTypeOpenApi.openIdConnect: 'openIdConnect',
};

const _$SecuritySchemeInOpenApiEnumMap = {
  SecuritySchemeInOpenApi.query: 'query',
  SecuritySchemeInOpenApi.header: 'header',
  SecuritySchemeInOpenApi.cookie: 'cookie',
};

const _$SecuritySchemeNameOpenApiEnumMap = {
  SecuritySchemeNameOpenApi.basic: 'Basic',
  SecuritySchemeNameOpenApi.bearer: 'Bearer',
  SecuritySchemeNameOpenApi.digest: 'Digest',
  SecuritySchemeNameOpenApi.hoba: 'HOBA',
  SecuritySchemeNameOpenApi.mutual: 'Mutual',
  SecuritySchemeNameOpenApi.negotiate: 'Negotiate',
  SecuritySchemeNameOpenApi.oAuth: 'OAuth',
  SecuritySchemeNameOpenApi.scramSha1: 'SCRAM-SHA-1',
  SecuritySchemeNameOpenApi.scramSha256: 'SCRAM-SHA-256',
  SecuritySchemeNameOpenApi.vapid: 'vapid',
};

OAuthFlowsOpenApi _$OAuthFlowsOpenApiFromJson(Map json) =>
    $checkedCreate('OAuthFlowsOpenApi', json, ($checkedConvert) {
      final val = OAuthFlowsOpenApi(
        implicit: $checkedConvert(
          'implicit',
          (v) => v == null ? null : OAuthFlowOpenApi.fromJson(v as Map),
        ),
        password: $checkedConvert(
          'password',
          (v) => v == null ? null : OAuthFlowOpenApi.fromJson(v as Map),
        ),
        clientCredentials: $checkedConvert(
          'clientCredentials',
          (v) => v == null ? null : OAuthFlowOpenApi.fromJson(v as Map),
        ),
        authorizationCode: $checkedConvert(
          'authorizationCode',
          (v) => v == null ? null : OAuthFlowOpenApi.fromJson(v as Map),
        ),
      );
      return val;
    });

Map<String, dynamic> _$OAuthFlowsOpenApiToJson(OAuthFlowsOpenApi instance) =>
    <String, dynamic>{
      'implicit': ?instance.implicit?.toJson(),
      'password': ?instance.password?.toJson(),
      'clientCredentials': ?instance.clientCredentials?.toJson(),
      'authorizationCode': ?instance.authorizationCode?.toJson(),
    };

OAuthFlowOpenApi _$OAuthFlowOpenApiFromJson(Map json) =>
    $checkedCreate('OAuthFlowOpenApi', json, ($checkedConvert) {
      final val = OAuthFlowOpenApi(
        authorizationUrl: $checkedConvert(
          'authorizationUrl',
          (v) => v as String?,
        ),
        tokenUrl: $checkedConvert('tokenUrl', (v) => v as String),
        refreshUrl: $checkedConvert('refreshUrl', (v) => v as String?),
        scopes: $checkedConvert(
          'scopes',
          (v) => Map<String, String>.from(v as Map),
        ),
      );
      return val;
    });

Map<String, dynamic> _$OAuthFlowOpenApiToJson(OAuthFlowOpenApi instance) =>
    <String, dynamic>{
      'authorizationUrl': ?instance.authorizationUrl,
      'tokenUrl': instance.tokenUrl,
      'refreshUrl': ?instance.refreshUrl,
      'scopes': instance.scopes,
    };

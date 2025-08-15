// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, avoid_annotating_with_dynamic

part of 'info_specs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoOpenApi _$InfoOpenApiFromJson(Map json) =>
    $checkedCreate('InfoOpenApi', json, ($checkedConvert) {
      final val = InfoOpenApi(
        title: $checkedConvert('title', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String?),
        termsOfService: $checkedConvert('termsOfService', (v) => v as String?),
        version: $checkedConvert('version', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$InfoOpenApiToJson(InfoOpenApi instance) {
  final val = <String, dynamic>{'title': instance.title};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  writeNotNull('termsOfService', instance.termsOfService);
  val['version'] = instance.version;
  return val;
}

ServerOpenApi _$ServerOpenApiFromJson(Map json) =>
    $checkedCreate('ServerOpenApi', json, ($checkedConvert) {
      final val = ServerOpenApi(
        url: $checkedConvert('url', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ServerOpenApiToJson(ServerOpenApi instance) {
  final val = <String, dynamic>{'url': instance.url};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  return val;
}

TagOpenApi _$TagOpenApiFromJson(Map json) => $checkedCreate('TagOpenApi', json, ($checkedConvert) {
  final val = TagOpenApi(
    name: $checkedConvert('name', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String?),
    externalDocs: $checkedConvert(
      'externalDocs',
      (v) => v == null ? null : ExternalDocsOpenApi.fromJson(v as Map),
    ),
  );
  return val;
});

Map<String, dynamic> _$TagOpenApiToJson(TagOpenApi instance) {
  final val = <String, dynamic>{'name': instance.name};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  writeNotNull('externalDocs', instance.externalDocs?.toJson());
  return val;
}

ExternalDocsOpenApi _$ExternalDocsOpenApiFromJson(Map json) =>
    $checkedCreate('ExternalDocsOpenApi', json, ($checkedConvert) {
      final val = ExternalDocsOpenApi(
        description: $checkedConvert('description', (v) => v as String?),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ExternalDocsOpenApiToJson(ExternalDocsOpenApi instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  val['url'] = instance.url;
  return val;
}

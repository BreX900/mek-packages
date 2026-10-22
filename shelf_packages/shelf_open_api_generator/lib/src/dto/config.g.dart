// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map json) => $checkedCreate(
  'Config',
  json,
  ($checkedConvert) {
    final val = Config(
      enabled: $checkedConvert('enabled', (v) => v as bool? ?? true),
      outputPath: $checkedConvert(
        'output_path',
        (v) => v as String? ?? 'public',
      ),
      info: $checkedConvert(
        'info',
        (v) => v == null ? null : InfoOpenApi.fromJson(v as Map),
      ),
      servers: $checkedConvert(
        'servers',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => ServerOpenApi.fromJson(e as Map))
                .toList() ??
            const [ServerOpenApi(url: 'http://localhost:8080')],
      ),
      securitySchemes: $checkedConvert(
        'security_schemes',
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
  },
  fieldKeyMap: const {
    'outputPath': 'output_path',
    'securitySchemes': 'security_schemes',
  },
);

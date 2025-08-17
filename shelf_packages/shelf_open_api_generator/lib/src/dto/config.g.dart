// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map json) => $checkedCreate('Config', json, (
  $checkedConvert,
) {
  final val = Config(
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
            (k, e) =>
                MapEntry(k as String, SecuritySchemeOpenApi.fromJson(e as Map)),
          ) ??
          const {},
    ),
  );
  return val;
}, fieldKeyMap: const {'securitySchemes': 'security_schemes'});

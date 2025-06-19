// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
  infoTitle: json['info_title'] as String?,
  infoDescription: json['info_description'] as String?,
  infoVersion: json['info_version'] as String?,
  infoTermsOfService: json['info_terms_of_service'] as String?,
  serverUrl: json['server_url'] as String? ?? 'http://localhost:8080',
  serverDescription: json['server_description'] as String?,
  securitySchemes:
      (json['security_schemes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          SecuritySchemeOpenApi.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
);

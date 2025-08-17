// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubspec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pubspec _$PubspecFromJson(Map json) =>
    $checkedCreate('Pubspec', json, ($checkedConvert) {
      final val = Pubspec(
        name: $checkedConvert('name', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String?),
        version: $checkedConvert('version', (v) => v as String?),
        dependencies: $checkedConvert(
          'dependencies',
          (v) =>
              (v as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
              const <String, Object?>{},
        ),
      );
      return val;
    });

import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/codecs/types/date_time_codec.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

extension IsNullableDartTypeExtension on DartType {
  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;

  String get displayName => getDisplayString(withNullability: false);
  String get displayNameNullable => getDisplayString(withNullability: true);
}

abstract class ApiCodec<T> {
  Type get type => T;

  const ApiCodec();

  bool get hasNullSafeSerialization => false;
  bool get hasNullSafeDeserialization => false;

  String encodeType(ApiCodecs codecs, DartType type);

  String encodeSerialization(ApiCodecs codecs, DartType type, String varAccess);

  String encodeDeserialization(ApiCodecs codecs, DartType type, String varAccess);
}

class ApiPlatformCodec<T> {
  Type get type => T;

  final ApiCodec<T> dart;
  final ApiCodec<T> kotlin;
  final ApiCodec<T> swift;

  const ApiPlatformCodec({
    required this.dart,
    required this.kotlin,
    required this.swift,
  });

  ApiCodec<T> read(LanguageApi platform) {
    return switch (platform) {
      LanguageApi.dart => dart,
      LanguageApi.kotlin => kotlin,
      LanguageApi.swift => swift,
    };
  }

  static const ApiPlatformCodec<DateTime> dateTime = ApiPlatformCodec(
    dart: DateTimeDartApiCodec(),
    kotlin: DateTimeKotlinApiCodec(),
    swift: DateTimeSwiftApiCodec(),
  );

  static const List<ApiPlatformCodec> values = [dateTime];
}

abstract class ApiCodecs {
  final OneForAllOptions pluginOptions;
  final List<(TypeChecker, ApiCodec)> codecs;

  ApiCodecs(this.pluginOptions, this.codecs);

  ApiCodec? findCodec(DartType type) =>
      codecs.firstWhereOrNull((e) => e.$1.isExactlyType(type))?.$2;

  String encodeName(String name);

  String encodeType(DartType type);

  String encodeDeserialization(DartType type, String varAccess);

  String encodeSerialization(DartType type, String varAccess);
}

abstract class HostApiCodecs extends ApiCodecs {
  HostApiCodecs(super.pluginOptions, super.codecs);

  @override
  String encodeName(String name) => '${name.pascalCase}${pluginOptions.hostClassSuffix}';

  @override
  String encodeType(DartType type, [bool withNullability = true]) {
    final encoded = encodePrimitiveType(type, withNullability);
    if (encoded != null) return encoded;

    final codec = findCodec(type);
    if (codec != null) return codec.encodeType(this, type);

    return type.getDisplayString(withNullability: true).replaceFirstMapped(RegExp(r'\w+'), (match) {
      return '${match.group(0)}${pluginOptions.hostClassSuffix}';
    });
  }

  String? encodePrimitiveType(DartType type, [bool withNullability = true]);
}

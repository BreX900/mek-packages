import 'dart:collection';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

const encoder = JsonEncoder.withIndent('  ');

mixin PrettyJsonToString {
  Map<String, dynamic> toJson();

  @override
  String toString() => encoder.convert(toJson());
}

abstract class OriginalJson {
  static Map<dynamic, dynamic> wrap(Map<dynamic, dynamic> map) => _OriginalJson(map);

  @JsonKey(name: r'$originalJson', includeToJson: false)
  final Map<dynamic, dynamic>? originalJson;

  const OriginalJson({required this.originalJson});

  T ensureIsNotNull<T>(String fieldName, T? value) {
    if (value != null) return value;

    throw ArgumentError(
      'Must not be null!\n${jsonEncode(originalJson ?? toJson())}',
      '$runtimeType.$fieldName',
    );
  }

  Map<dynamic, dynamic> toJson();

  @override
  String toString() => '$runtimeType: ${jsonEncode(originalJson ?? toJson())}';
}

class _OriginalJson extends UnmodifiableMapView<dynamic, dynamic> {
  final Map<dynamic, dynamic> delegate;

  _OriginalJson(this.delegate) : super(delegate);

  @override
  dynamic operator [](Object? key) {
    if (key == r'$originalJson') return delegate;
    return super[key];
  }
}

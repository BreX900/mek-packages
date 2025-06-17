extension MapFromIterable<T> on Iterable<T> {
  Map<K, V> toMap<K, V>(MapEntry<K, V> Function(T e) converter) => Map.fromEntries(map(converter));

  Iterable<R> mapWhereNotNull<R extends Object>(R? Function(T e) mapper) => map(mapper).nonNulls;
}

abstract class Utils {
  /// Convert [YamlMap] to [Map<String, dynamic>] and [YamlList] to [List]
  static dynamic optionYamlToBuilder(dynamic value) {
    if (value is Map<dynamic, dynamic>) {
      return value.map((key, value) {
        return MapEntry(key as String, optionYamlToBuilder(value));
      });
    } else if (value is List<dynamic>) {
      return value.map(optionYamlToBuilder).toList();
    }
    return value;
  }
}

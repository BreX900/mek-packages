extension MapFromIterable<T> on Iterable<T> {
  Map<K, V> toMap<K, V>(MapEntry<K, V> Function(T e) converter) => Map.fromEntries(map(converter));

  Iterable<R> mapWhereNotNull<R extends Object>(R? Function(T e) mapper) => map(mapper).nonNulls;
}

import 'dart:async';

extension Entries<K, V> on Iterable<MapEntry<K, V>> {
  Iterable<MapEntry<K, V>> whereEntry(bool Function(K key, V value) test) =>
      where((e) => test(e.key, e.value));

  Iterable<R> mapEntry<R>(R Function(K key, V value) mapper) => map((e) => mapper(e.key, e.value));

  Iterable<R> expandEntry<R>(Iterable<R> Function(K key, V value) mapper) =>
      expand((e) => mapper(e.key, e.value));
}

extension IterableX<T> on Iterable<T> {
  Future<R> asyncFold<R>(
    R initialValue,
    FutureOr<R> Function(R previousValue, T element) combine,
  ) async {
    var value = initialValue;
    for (final element in this) {
      value = await combine(value, element);
    }
    return value;
  }
}

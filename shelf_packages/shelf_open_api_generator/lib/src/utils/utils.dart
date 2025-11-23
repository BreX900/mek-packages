import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

extension MapFromIterable<T> on Iterable<T> {
  Map<K, V> toMap<K, V>(MapEntry<K, V> Function(T e) converter) => Map.fromEntries(map(converter));

  Iterable<R> mapWhereNotNull<R extends Object>(R? Function(T e) mapper) => map(mapper).nonNulls;
}

extension ElementExtensions on Element {
  String get requireName {
    if (name case final name?) return name;
    throw InvalidGenerationSourceError('The parameter name is required!', element: this);
  }
}

extension ClassElementExtensions on ClassElement {
  ConstructorElement get requireUnnamedConstructor {
    if (unnamedConstructor case final constructor?) return constructor;
    throw InvalidGenerationSourceError('Define a unnamed constructor!', element: this);
  }
}

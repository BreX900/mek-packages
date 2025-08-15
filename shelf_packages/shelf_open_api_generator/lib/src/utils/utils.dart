import 'package:analyzer/dart/element/element2.dart';
import 'package:source_gen/source_gen.dart';

extension MapFromIterable<T> on Iterable<T> {
  Map<K, V> toMap<K, V>(MapEntry<K, V> Function(T e) converter) => Map.fromEntries(map(converter));

  Iterable<R> mapWhereNotNull<R extends Object>(R? Function(T e) mapper) => map(mapper).nonNulls;
}

extension ElementExtensions on Element2 {
  String get requireName {
    if (name3 case final name?) return name;
    throw InvalidGenerationSourceError('The parameter name is required!', element: this);
  }
}

extension ClassElementExtensions on ClassElement2 {
  ConstructorElement2 get requireUnnamedConstructor {
    if (unnamedConstructor2 case final constructor?) return constructor;
    throw InvalidGenerationSourceError('Define a unnamed constructor!', element: this);
  }
}

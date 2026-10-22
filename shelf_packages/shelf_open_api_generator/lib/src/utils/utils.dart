import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

extension MapFromIterable<T> on Iterable<T> {
  Map<K, V> toMap<K, V>(MapEntry<K, V> Function(T e) converter) => Map.fromEntries(map(converter));

  Iterable<R> mapWhereNotNull<R extends Object>(R? Function(T e) mapper) => map(mapper).nonNulls;
}

extension ClassElementExtensions on ClassElement {
  ConstructorElement get requireUnnamedConstructor {
    if (unnamedConstructor case final constructor?) return constructor;
    throw InvalidGenerationSourceError('Define a unnamed constructor!', element: this);
  }
}

abstract final class TypeCheckers {
  static const _ficPackage = 'fast_immutable_collections';
  static const _builtPackage = 'built_collection';

  static const list = TypeChecker.any([
    TypeChecker.typeNamed(List, inSdk: true),
    TypeChecker.typeNamedLiterally('IList', inPackage: _ficPackage),
    TypeChecker.typeNamedLiterally('BuiltList', inPackage: _builtPackage),
  ]);
  static const set = TypeChecker.any([
    TypeChecker.typeNamed(Set, inSdk: true),
    TypeChecker.typeNamedLiterally('ISet', inPackage: _ficPackage),
    TypeChecker.typeNamedLiterally('BuiltSet', inPackage: _builtPackage),
  ]);
  static const listOrSet = TypeChecker.any([list, set]);
  static const map = TypeChecker.any([
    TypeChecker.typeNamed(Map, inSdk: true),
    TypeChecker.typeNamedLiterally('IMap', inPackage: _ficPackage),
    TypeChecker.typeNamedLiterally('BuiltMap', inPackage: _builtPackage),
  ]);
}

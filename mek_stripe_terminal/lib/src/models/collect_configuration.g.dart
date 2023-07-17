// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collect_configuration.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$CollectConfiguration {
  CollectConfiguration get _self => this as CollectConfiguration;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectConfiguration &&
          runtimeType == other.runtimeType &&
          _self.skipTipping == other.skipTipping;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.skipTipping.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('CollectConfiguration')
        ..add('skipTipping', _self.skipTipping))
      .toString();
}

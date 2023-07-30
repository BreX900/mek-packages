// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_software_update.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$ReaderSoftwareUpdate {
  ReaderSoftwareUpdate get _self => this as ReaderSoftwareUpdate;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderSoftwareUpdate &&
          runtimeType == other.runtimeType &&
          $listEquality.equals(_self.components, other.components) &&
          _self.hasConfigUpdate == other.hasConfigUpdate &&
          _self.hasFirmwareUpdate == other.hasFirmwareUpdate &&
          _self.hasIncrementalUpdate == other.hasIncrementalUpdate &&
          _self.hasKeyUpdate == other.hasKeyUpdate &&
          _self.keyProfileName == other.keyProfileName &&
          _self.onlyInstallRequiredUpdates == other.onlyInstallRequiredUpdates &&
          _self.requiredAt == other.requiredAt &&
          _self.settingsVersion == other.settingsVersion &&
          _self.timeEstimate == other.timeEstimate &&
          _self.version == other.version;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, $listEquality.hash(_self.components));
    hashCode = $hashCombine(hashCode, _self.hasConfigUpdate.hashCode);
    hashCode = $hashCombine(hashCode, _self.hasFirmwareUpdate.hashCode);
    hashCode = $hashCombine(hashCode, _self.hasIncrementalUpdate.hashCode);
    hashCode = $hashCombine(hashCode, _self.hasKeyUpdate.hashCode);
    hashCode = $hashCombine(hashCode, _self.keyProfileName.hashCode);
    hashCode = $hashCombine(hashCode, _self.onlyInstallRequiredUpdates.hashCode);
    hashCode = $hashCombine(hashCode, _self.requiredAt.hashCode);
    hashCode = $hashCombine(hashCode, _self.settingsVersion.hashCode);
    hashCode = $hashCombine(hashCode, _self.timeEstimate.hashCode);
    hashCode = $hashCombine(hashCode, _self.version.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('ReaderSoftwareUpdate')
        ..add('components', _self.components)
        ..add('hasConfigUpdate', _self.hasConfigUpdate)
        ..add('hasFirmwareUpdate', _self.hasFirmwareUpdate)
        ..add('hasIncrementalUpdate', _self.hasIncrementalUpdate)
        ..add('hasKeyUpdate', _self.hasKeyUpdate)
        ..add('keyProfileName', _self.keyProfileName)
        ..add('onlyInstallRequiredUpdates', _self.onlyInstallRequiredUpdates)
        ..add('requiredAt', _self.requiredAt)
        ..add('settingsVersion', _self.settingsVersion)
        ..add('timeEstimate', _self.timeEstimate)
        ..add('version', _self.version))
      .toString();
}

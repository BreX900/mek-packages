import 'package:json_annotation/json_annotation.dart';

export 'package:json_annotation/json_annotation.dart' show $checkKeys, $checkedCreate;

class SpecsSerializable extends JsonSerializable {
  const SpecsSerializable({super.createPerFieldToJson})
    : super(
        anyMap: true,
        createFactory: true,
        createToJson: true,
        includeIfNull: false,
        checked: true,
        explicitToJson: true,
      );
}

bool? $nullIfFalse(bool? value) => (value ?? false) ? true : null;

Object? $nullIfEmpty(Object? value) {
  if (value is List) {
    return value.isEmpty ? null : value;
  } else if (value is Map<String, dynamic>) {
    return value.isEmpty ? null : value;
  } else if (value is String) {
    return value.isEmpty ? null : value;
  }
  throw ArgumentError.value(value, null, 'Unsupported type');
}

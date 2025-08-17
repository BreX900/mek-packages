import 'package:json_annotation/json_annotation.dart';
import 'package:open_api_specification/src/specs/ref_or_specs.dart';
import 'package:open_api_specification/src/specs/schema.dart';

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
        converters: const [RefOrSchemaOpenApiConverter()],
      );
}

class RefOrSchemaOpenApiConverter extends _RefOrOpenApiConverter<SchemaOpenApi> {
  const RefOrSchemaOpenApiConverter() : super(SchemaOpenApi.fromJson);
}

class _RefOrOpenApiConverter<T extends RefOr<T>>
    extends JsonConverter<RefOr<T>, Map<dynamic, dynamic>> {
  final T Function(Map<dynamic, dynamic>) deserialize;

  const _RefOrOpenApiConverter(this.deserialize);

  @override
  RefOr<T> fromJson(Map<dynamic, dynamic> json) {
    final ref = json[r'$ref'];
    if (ref != null) {
      return RefOpenApi(ref: ref);
    } else {
      return deserialize(json);
    }
  }

  @override
  Map<dynamic, dynamic> toJson(RefOr<T> object) => object.toJson();
}

bool? $nullIfFalse(bool value) => value ? true : null;

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

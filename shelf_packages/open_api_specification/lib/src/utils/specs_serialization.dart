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
        converters: const [RefOrSchemaJsonConverter()],
      );
}

class RefOrSchemaJsonConverter extends JsonConverter<RefOr<SchemaOpenApi>, Map<dynamic, dynamic>> {
  const RefOrSchemaJsonConverter();

  @override
  RefOr<SchemaOpenApi> fromJson(Map<dynamic, dynamic> json) {
    final ref = json[r'$ref'] as String?;
    if (ref == null) return SchemaOpenApi.fromJson(json);

    final segments = ref.split('/');
    if (segments[0] != '#' || segments[1] != 'components' || segments[2] != 'schemas') {
      throw ArgumentError.value(ref, 'SchemaOpenApi', 'Invalid reference!');
    }

    SchemaOpenApi? cache;
    return RefOpenApi(ref, (components) => cache ??= components.schemas[segments[3]]!);
  }

  @override
  Map<dynamic, dynamic> toJson(RefOr<SchemaOpenApi> object) => object.toJson();
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

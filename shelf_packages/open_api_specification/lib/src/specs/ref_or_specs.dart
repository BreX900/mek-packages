import 'package:json_annotation/json_annotation.dart';
import 'package:open_api_specification/src/specs/base_specs.dart';
import 'package:open_api_specification/src/utils/utils.dart';

class RefOpenApi<T extends Object> extends RefOr<T> with PrettyJsonToString {
  final T Function(ComponentsOpenApi components) _resolver;
  @JsonKey(name: r'$ref')
  final String ref;

  const RefOpenApi(this.ref, this._resolver);

  @override
  T resolve(ComponentsOpenApi components) => _resolver(components);

  @override
  Map<dynamic, dynamic> toJson() => {r'$ref': ref};
}

abstract class RefOr<T extends Object> {
  const RefOr();

  T resolve(ComponentsOpenApi components);

  Map<dynamic, dynamic> toJson();
}

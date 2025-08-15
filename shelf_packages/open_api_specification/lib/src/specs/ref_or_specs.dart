import 'package:json_annotation/json_annotation.dart';
import 'package:open_api_specification/src/utils/utils.dart';

mixin RefOrOpenApi<T extends RefOrOpenApi<T>> {
  String? get ref;

  R fold<R>(R Function(String ref) onRef, R Function(T) on) {
    if (ref != null) {
      return onRef(ref!);
    } else {
      return on(this as T);
    }
  }

  Map<String, dynamic> toJson();
}

class RefOpenApi<T extends Object> extends RefOr<T> with PrettyJsonToString {
  @JsonKey(name: r'$ref')
  final String ref;

  const RefOpenApi({required this.ref});

  @override
  R fold<R>(R Function(String ref) onRef, R Function(T p1) on) => onRef(ref);

  @override
  Map<String, dynamic> toJson() => {r'$ref': ref};
}

abstract class RefOr<T extends Object> {
  const RefOr();

  R fold<R>(R Function(String ref) onRef, R Function(T p1) on);

  Map<String, dynamic> toJson();
}

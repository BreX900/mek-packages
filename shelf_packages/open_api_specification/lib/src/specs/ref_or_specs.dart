import 'package:open_api_specification/src/specs/base_specs.dart';

abstract class RefOr<T extends Object> {
  const RefOr();

  T resolve(ComponentsOpenApi components);

  Map<String, dynamic> toJson();
}

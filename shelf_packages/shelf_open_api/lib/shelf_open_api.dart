/// Annotations for the shelf_open_api_generator library.
library shelf_open_api;

import 'package:meta/meta_meta.dart';

@TargetKind.classType
class OpenApi {
  const OpenApi();
}

@TargetKind.method
class OpenApiRoute {
  final List<Map<String, List<String>>> security;
  final Type? requestQuery;
  final Type? requestBody;

  const OpenApiRoute({
    this.security = const <Map<String, List<String>>>[],
    this.requestQuery,
    this.requestBody,
  });
}

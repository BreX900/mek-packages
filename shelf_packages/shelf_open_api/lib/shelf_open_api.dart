/// Annotations for the shelf_open_api_generator library.
library shelf_open_api;

import 'package:meta/meta_meta.dart';

enum OpenApiFileFormat { yaml, json }

@TargetKind.classType
class OpenApiFile {
  final OpenApiFileFormat format;

  const OpenApiFile({this.format = OpenApiFileFormat.json});
}

class OpenApiRouteIgnore {
  const OpenApiRouteIgnore();
}

@TargetKind.method
class OpenApiRouteHttp {
  final List<Map<String, List<String>>> security;
  final Type? requestQuery;
  final Type? requestBody;
  final Type? responseBody;

  const OpenApiRouteHttp({
    this.security = const <Map<String, List<String>>>[],
    this.requestQuery,
    this.requestBody,
    this.responseBody,
  });
}

@TargetKind.getter
class OpenApiRouteMount {
  final Type serviceType;

  const OpenApiRouteMount(this.serviceType);
}

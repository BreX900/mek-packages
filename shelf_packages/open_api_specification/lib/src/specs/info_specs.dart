import 'package:open_api_specification/src/utils/specs_serialization.dart';

part 'info_specs.g.dart';

/// Version: 3.0.3
@SpecsSerializable()
class InfoOpenApi {
  final String title;
  final String? description;
  final String? termsOfService;
  // final ContactOpenApi? contact;
  final String version;

  const InfoOpenApi({
    required this.title,
    this.description,
    this.termsOfService,
    required this.version,
  });

  InfoOpenApi copyWith({
    String? title,
    String? description,
    String? termsOfService,
    String? version,
  }) => InfoOpenApi(
    title: title ?? this.title,
    description: description ?? this.description,
    termsOfService: termsOfService ?? this.termsOfService,
    version: version ?? this.version,
  );

  factory InfoOpenApi.fromJson(Map<dynamic, dynamic> map) => _$InfoOpenApiFromJson(map);
  Map<String, dynamic> toJson() => _$InfoOpenApiToJson(this);
}

/// Version: 3.0.3
@SpecsSerializable()
class ServerOpenApi {
  final String url;
  final String? description;
  // final Map<String, ServerVariableOpenApi>? variables;

  const ServerOpenApi({
    required this.url,
    this.description,
    // this.variables,
  });

  factory ServerOpenApi.fromJson(Map<dynamic, dynamic> map) => _$ServerOpenApiFromJson(map);
  Map<String, dynamic> toJson() => _$ServerOpenApiToJson(this);
}

/// Version: 3.0.3
@SpecsSerializable()
class TagOpenApi {
  final String name;
  final String? description;
  final ExternalDocsOpenApi? externalDocs;

  const TagOpenApi({required this.name, this.description, this.externalDocs});

  factory TagOpenApi.fromJson(Map<dynamic, dynamic> map) => _$TagOpenApiFromJson(map);
  Map<String, dynamic> toJson() => _$TagOpenApiToJson(this);
}

@SpecsSerializable()
class ExternalDocsOpenApi {
  final String? description;
  final String url;

  const ExternalDocsOpenApi({this.description, required this.url});

  factory ExternalDocsOpenApi.fromJson(Map<dynamic, dynamic> map) =>
      _$ExternalDocsOpenApiFromJson(map);
  Map<String, dynamic> toJson() => _$ExternalDocsOpenApiToJson(this);
}

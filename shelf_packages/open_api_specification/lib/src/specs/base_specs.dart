import 'package:json_annotation/json_annotation.dart';
import 'package:open_api_specification/src/specs/info_specs.dart';
import 'package:open_api_specification/src/specs/schema.dart';
import 'package:open_api_specification/src/specs/security_open_api.dart';
import 'package:open_api_specification/src/utils/specs_serialization.dart';
import 'package:open_api_specification/src/utils/utils.dart';

part 'base_specs.g.dart';

/// Documentation: https://swagger.io/specification
///
/// Version: 3.0.3
@SpecsSerializable()
class OpenApi with PrettyJsonToString {
  final String openapi;
  final InfoOpenApi info;
  @JsonKey(toJson: $nullIfEmpty)
  final List<ServerOpenApi> servers;

  /// Endpoint path
  final Map<String, ItemPathOpenApi> paths;
  // final SecurityOpenApi security;
  final ComponentsOpenApi components;

  final List<TagOpenApi> tags;
  // final ExternalDocsOpenApi externalDocs;

  const OpenApi({
    required this.openapi,
    required this.info,
    this.servers = const [],
    required this.paths,
    this.components = const ComponentsOpenApi(),
    this.tags = const [],
  });

  factory OpenApi.fromJson(Map<dynamic, dynamic> map) => _$OpenApiFromJson(map);
  @override
  Map<String, dynamic> toJson() => _$OpenApiToJson(this);
}

@SpecsSerializable()
class ItemPathOpenApi with PrettyJsonToString {
  final String? summary;
  final String? description;

  final OperationOpenApi? get;
  final OperationOpenApi? put;
  final OperationOpenApi? post;
  final OperationOpenApi? delete;
  // final MethodOpenApi? options;
  final OperationOpenApi? head;
  final OperationOpenApi? patch;
  // final MethodOpenApi? trace;
  // final List<ServerOpenApi>? servers;
  // final List<RefOrParamOpenApiConverter>? parameters;

  const ItemPathOpenApi({
    this.summary,
    this.description,
    this.get,
    this.put,
    this.post,
    this.delete,
    this.head,
    this.patch,
  });

  factory ItemPathOpenApi.from({
    String? summary,
    String? description,
    required Map<String, OperationOpenApi> operations,
  }) {
    final usedOperations = operations.map((key, value) => MapEntry(key.toLowerCase(), value));
    final instance = ItemPathOpenApi(
      summary: summary,
      description: description,
      get: usedOperations.remove('get'),
      put: usedOperations.remove('put'),
      post: usedOperations.remove('post'),
      delete: usedOperations.remove('delete'),
      head: usedOperations.remove('head'),
      patch: usedOperations.remove('patch'),
    );
    if (usedOperations.isNotEmpty) {
      // ignore: avoid_print
      print('[WARNING] Not consumed all item path methods: ${usedOperations.keys}');
    }
    return instance;
  }

  Map<String, OperationOpenApi> get operations => {
        if (get != null) 'get': get!,
        if (put != null) 'put': put!,
        if (post != null) 'post': post!,
        if (delete != null) 'delete': delete!,
        if (head != null) 'head': head!,
        if (patch != null) 'patch': patch!,
      };

  factory ItemPathOpenApi.fromJson(Map<dynamic, dynamic> map) => _$ItemPathOpenApiFromJson(map);
  @override
  Map<String, dynamic> toJson() => _$ItemPathOpenApiToJson(this);
}

/// Version: 3.0.3
@SpecsSerializable()
class OperationOpenApi with PrettyJsonToString {
  @JsonKey(toJson: $nullIfEmpty)
  final List<String> tags;
  final String? summary;
  final String? description;
  // final ExternalDocumentOpenApi externalDocs;

  final String? operationId;

  @JsonKey(toJson: $nullIfEmpty)
  final List<ParameterOpenApi> parameters;
  final RequestBodyOpenApi? requestBody;

  /// Map<String | int, ResponseOpenApi>
  @JsonKey(fromJson: _responsesFromJson)
  final Map<int, ResponseOpenApi> responses;

  // final Map<String, RefOpenApi<CallbackOpenApi>> callbacks;

  @JsonKey(toJson: $nullIfFalse)
  final bool deprecated;

  @JsonKey(toJson: $nullIfEmpty)
  final List<Map<String, List<String>>> security;
  @JsonKey(toJson: $nullIfEmpty)
  final List<ServerOpenApi> servers;

  const OperationOpenApi({
    this.tags = const [],
    this.summary,
    this.description,
    required this.operationId,
    this.parameters = const [],
    this.requestBody,
    required this.responses,
    this.deprecated = false,
    this.security = const [],
    this.servers = const [],
  });

  bool get hasSummary => summary != null && summary!.trim().isNotEmpty;
  bool get hasDescription => description != null && description!.trim().isNotEmpty;

  (int, ResponseOpenApi)? get successResponse {
    for (final MapEntry(key: code, value: response) in responses.entries) {
      if (code < 200 && code >= 300) continue;
      return (code, response);
    }
    return null;
  }

  Map<int, ResponseOpenApi> get failedResponses {
    return Map.fromEntries(responses.entries.where((e) {
      final MapEntry(key: code) = e;
      return code < 200 && code >= 300;
    }));
  }

  factory OperationOpenApi.fromJson(Map<dynamic, dynamic> map) => _$OperationOpenApiFromJson(map);
  @override
  Map<String, dynamic> toJson() => _$OperationOpenApiToJson(this);

  static Map<int, ResponseOpenApi> _responsesFromJson(Map<dynamic, dynamic> json) {
    return json.map((code, response) {
      if (code is String) {
        code = code == 'default' ? 200 : int.parse(code);
      } else {
        code as int;
      }
      return MapEntry(code, ResponseOpenApi.fromJson(response as Map));
    });
  }
}

// ====================  PARAMETERS

@JsonEnum()
enum ParameterInOpenApi { path, query, header, cookie }

extension ParameterInOpenApiExt on ParameterInOpenApi {
  bool get isQuery => this == ParameterInOpenApi.query;
  String toJson() => _$ParameterInOpenApiEnumMap[this]!;
  static ParameterInOpenApi? maybeFromJson(String? type) =>
      $enumDecodeNullable(_$ParameterInOpenApiEnumMap, type);
}

@SpecsSerializable()
class ParameterOpenApi with PrettyJsonToString {
  final String? description;
  final Object? example;

  @JsonKey(toJson: $nullIfEmpty)
  final Map<String, dynamic> examples;

  final String name;
  @JsonKey(name: 'in')
  final ParameterInOpenApi in$;

  final bool required;
  @JsonKey(toJson: $nullIfFalse)
  final bool deprecated;

  final String? style;
  final bool? explode;

  final SchemaOpenApi? schema; // Property

  // final Map<String, MediaOpenApi> content;

  const ParameterOpenApi({
    this.description,
    this.example,
    required this.name,
    required this.in$,
    this.required = false,
    this.deprecated = false,
    this.style,
    this.explode,
    required this.schema,
    this.examples = const {},
  });

  factory ParameterOpenApi.fromJson(Map<dynamic, dynamic> map) => _$ParameterOpenApiFromJson(map);
  @override
  Map<String, dynamic> toJson() => _$ParameterOpenApiToJson(this);
}

@SpecsSerializable()
class RequestBodyOpenApi with PrettyJsonToString {
  final String? description;

  final bool required;

  final GroupMediaOpenApi content;

  const RequestBodyOpenApi({
    this.description,
    this.required = false,
    required this.content,
  });

  factory RequestBodyOpenApi.fromJson(Map<dynamic, dynamic> map) =>
      _$RequestBodyOpenApiFromJson(map);
  @override
  Map<String, dynamic> toJson() => _$RequestBodyOpenApiToJson(this);
}

@SpecsSerializable()
class ResponseOpenApi with PrettyJsonToString {
  final String description;

  @JsonKey(toJson: $nullIfEmpty)
  final Map<String, dynamic> headers;

  final GroupMediaOpenApi? content;

  const ResponseOpenApi({
    required this.description,
    this.headers = const {},
    this.content,
  });

  factory ResponseOpenApi.fromJson(Map<dynamic, dynamic> map) => _$ResponseOpenApiFromJson(map);
  @override
  Map<String, dynamic> toJson() => _$ResponseOpenApiToJson(this);
}

@SpecsSerializable()
class ComponentsOpenApi with PrettyJsonToString {
  @JsonKey(toJson: $nullIfEmpty)
  final Map<String, SchemaOpenApi> schemas;
  @JsonKey(toJson: $nullIfEmpty)
  final Map<String, ResponseOpenApi> responses;
  @JsonKey(toJson: $nullIfEmpty)
  final Map<String, ParameterOpenApi> parameters;
  @JsonKey(toJson: $nullIfEmpty)
  final Map<String, dynamic> requestBodies;
  @JsonKey(toJson: $nullIfEmpty)
  final Map<String, SecuritySchemeOpenApi> securitySchemes;

  const ComponentsOpenApi({
    this.schemas = const {},
    this.responses = const {},
    this.parameters = const {},
    this.requestBodies = const {},
    this.securitySchemes = const {},
  });

  factory ComponentsOpenApi.fromJson(Map<dynamic, dynamic> map) => _$ComponentsOpenApiFromJson(map);
  @override
  Map<String, dynamic> toJson() => _$ComponentsOpenApiToJson(this);
}

extension ParameterInOpenApiExtensions on ParameterInOpenApi {
  bool get path => this == ParameterInOpenApi.path;
  bool get query => this == ParameterInOpenApi.query;
  bool get header => this == ParameterInOpenApi.header;
  bool get cookie => this == ParameterInOpenApi.cookie;
}

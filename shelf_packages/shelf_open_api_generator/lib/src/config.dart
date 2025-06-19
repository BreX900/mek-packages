import 'package:json_annotation/json_annotation.dart';
import 'package:open_api_specification/open_api_spec.dart';

part 'config.g.dart';

class ConfigSerializable extends JsonSerializable {
  const ConfigSerializable() : super(createFactory: true, fieldRename: FieldRename.snake);
}

@ConfigSerializable()
class Config {
  final String? infoTitle;
  final String? infoDescription;
  final String? infoVersion;
  final String? infoTermsOfService;
  final String serverUrl;
  final String? serverDescription;
  final Map<String, SecuritySchemeOpenApi> securitySchemes;

  const Config({
    this.infoTitle,
    this.infoDescription,
    this.infoVersion,
    this.infoTermsOfService,
    this.serverUrl = 'http://localhost:8080',
    this.serverDescription,
    this.securitySchemes = const {},
  });

  factory Config.fromJson(Map<String, dynamic> map) => _$ConfigFromJson(map);
}

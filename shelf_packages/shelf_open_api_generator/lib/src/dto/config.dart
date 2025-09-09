import 'package:open_api_specification/open_api_spec.dart';
import 'package:shelf_open_api_generator/src/dto/yaml_serializable.dart';

part 'config.g.dart';

@YamlSerializable(createFactory: true)
class Config {
  final InfoOpenApi? info;
  final List<ServerOpenApi> servers;
  final Map<String, SecuritySchemeOpenApi> securitySchemes;

  const Config({
    this.info,
    this.servers = const [ServerOpenApi(url: 'http://localhost:8080')],
    this.securitySchemes = const {},
  });

  factory Config.fromJson(Map<String, dynamic> map) => _$ConfigFromJson(map);
}

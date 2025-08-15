import 'package:build/build.dart';
import 'package:shelf_open_api_generator/src/dto/yaml_serializable.dart';
import 'package:yaml/yaml.dart';

part 'pubspec.g.dart';

@YamlSerializable(createFactory: true)
class Pubspec {
  final String name;
  final String? description;
  final String? version;
  final Map<String, dynamic> dependencies;

  const Pubspec({
    required this.name,
    required this.description,
    required this.version,
    this.dependencies = const <String, dynamic>{},
  });

  static Future<Pubspec?> read(BuildStep buildStep) async {
    final pubspecAssetId = AssetId(buildStep.inputId.package, 'pubspec.yaml');
    if (!await buildStep.canRead(pubspecAssetId)) return null;

    final rawContent = await buildStep.readAsString(pubspecAssetId);
    final content = loadYaml(rawContent, sourceUrl: pubspecAssetId.uri) as YamlMap;

    return _$PubspecFromJson(content);
  }
}

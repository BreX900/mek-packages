import 'dart:io';

import 'package:open_api_client_generator/src/options/options.dart';
import 'package:open_api_client_generator/src/plugins/plugin.dart';
import 'package:yaml/yaml.dart';
// import 'package:yaml/yaml.dart';

class OpenApiIgnore with Plugin {
  final String? overrideFilePath;

  OpenApiIgnore({
    this.overrideFilePath,
  });

  @override
  Map<dynamic, dynamic> onSpecifications(Map<dynamic, dynamic> specifications) {
    final overrideFile = File(overrideFilePath ?? '.openapiignore');
    if (overrideFilePath == null && !overrideFile.existsSync()) return specifications;

    final lines = overrideFile.readAsStringSync().split('\n');
    final paths = specifications['paths'] as Map;
    return {
      ...specifications,
      'paths': Map.fromEntries(lines.map((e) => MapEntry(e, paths[e]!))),
    };
  }
}

class OpenApiOverride with Plugin {
  final Options options;
  final String overrideFilePath;

  OpenApiOverride({
    required this.options,
    required this.overrideFilePath,
  });

  @override
  Map<dynamic, dynamic> onSpecifications(Map<dynamic, dynamic> specifications) {
    final override = loadYaml(File(overrideFilePath).readAsStringSync());
    return _merge(specifications, override)! as Map;
  }

  static Object? _merge(Object? original, Object? override) {
    if (override is Map) {
      if (override.containsKey(r'$ref')) return override;
      if (original is Map) {
        return Map<dynamic, dynamic>.fromEntries({...override.keys, ...original.keys}.map((key) {
          return MapEntry(key, _merge(original[key], override[key]));
        }));
      }
    }
    return override ?? original;
  }
}

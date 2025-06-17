import 'dart:io';

import 'package:open_api_client_generator/src/options/options.dart';
import 'package:open_api_client_generator/src/plugins/plugin.dart';
import 'package:open_api_client_generator/src/utils/file_utils.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:recase/recase.dart';

class WriteOpenApiPlugin with Plugin {
  final Options options;
  final String? outputFolder;
  final String? outputFileName;

  WriteOpenApiPlugin({
    required this.options,
    this.outputFolder,
    this.outputFileName,
  });

  late String? _fileName;
  late Map<dynamic, dynamic> _specifications;

  @override
  Map<dynamic, dynamic> onSpecifications(Map<dynamic, dynamic> specifications) {
    _specifications = specifications;
    return specifications;
  }

  @override
  OpenApi onOpenApi(OpenApi openApi) {
    _fileName = openApi.info.title.snakeCase;
    return openApi;
  }

  @override
  Future<void> onFinish() async {
    await File('${outputFolder ?? options.outputFolder}/${_fileName ?? outputFileName}.yaml')
        .writeAsString(FileUtils.yamlFrom(_specifications));
  }
}

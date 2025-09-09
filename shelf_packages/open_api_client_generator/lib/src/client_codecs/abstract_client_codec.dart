import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/client_codecs/client_codec.dart';
import 'package:open_api_client_generator/src/options/options.dart';
import 'package:open_api_client_generator/src/plugins/plugin.dart';
import 'package:open_api_client_generator/src/utils/files_contents.dart';

class AbstractClientCodec extends ClientCodec with Plugin {
  final Options options;

  const AbstractClientCodec({
    required this.options,
  });

  @override
  Reference get type => const Reference('ApiClient', './api_client.dart');

  Map<String, String> get filesContents => {'api_client.dart': FilesContents.apiClient};

  @override
  String encodeSendMethod(
    String method,
    String path, {
    String? queryParametersVar,
    String? dataVar,
  }) {
    var sendMethod = "await client.send('$method', '$path'";
    if (queryParametersVar != null) sendMethod += ', queryParameters: $queryParametersVar';
    if (dataVar != null) sendMethod += ', data: $dataVar';
    return sendMethod += ');';
  }

  @override
  String encodeExceptionInstance(String responseVar) => 'ApiClientException.of($responseVar)';

  @override
  Future<void> onFinish() async {
    await Future.wait(filesContents.entries.map((e) async {
      await File('${options.outputFolder}/${e.key}').writeAsString(e.value);
    }));
  }
}

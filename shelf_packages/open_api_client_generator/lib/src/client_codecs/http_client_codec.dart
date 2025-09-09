import 'package:open_api_client_generator/src/client_codecs/abstract_client_codec.dart';
import 'package:open_api_client_generator/src/utils/files_contents.dart';

class HttpClientCodec extends AbstractClientCodec {
  const HttpClientCodec({
    required super.options,
  });

  @override
  Map<String, String> get filesContents => {
        ...super.filesContents,
        'http_api_client.dart': FilesContents.httpApiClient,
      };
}

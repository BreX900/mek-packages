import 'package:open_api_client_generator/src/client_codecs/abstract_client_codec.dart';
import 'package:open_api_client_generator/src/utils/files_contents.dart';

class DartClientCodec extends AbstractClientCodec {
  const DartClientCodec({
    required super.options,
  });

  @override
  Map<String, String> get filesContents => {
        ...super.filesContents,
        'dart_api_client.dart': FilesContents.dartApiClient,
        'io_api_client.dart': FilesContents.ioApiClient,
        'web_api_client.dart': FilesContents.webApiClient,
      };
}

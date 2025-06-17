import 'package:open_api_client_generator/open_api_client_generator.dart';

void main() async {
  await generateApi(
    options: Options(
      input: Uri.file('../example/public/open_api.yaml'),
      outputFolder: 'example/api',
    ),
    clientCodec: const DioClientCodec(),
    serializationCodec: const JsonSerializableSerializationCodec(),
  );
}

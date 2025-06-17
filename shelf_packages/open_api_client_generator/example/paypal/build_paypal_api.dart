import 'dart:io';

import 'package:open_api_client_generator/open_api_client_generator.dart';
import 'package:open_api_client_generator/src/plugins/open_api_ignore.dart';

void main(List<String> args) async {
  const root = './example/paypal';
  final codeDir = Directory('$root/api');
  if (!codeDir.existsSync()) codeDir.createSync();

  final options = Options(
    // input: Uri.file('$root/specification/index.yml'),
    input: Uri.parse(
        'https://raw.githubusercontent.com/paypal/paypal-rest-api-specifications/main/openapi/checkout_orders_v2.json'),
    outputFolder: codeDir.path,
    apiClassName: 'PayPalApi',
  );
  await generateApi(
    options: options,
    clientCodec: const DioClientCodec(),
    serializationCodec: const JsonSerializableSerializationCodec(
      classFieldRename: FieldRename.snake,
    ),
    plugins: [
      OpenApiIgnore(overrideFilePath: '$root/.openapiignore'),
      WriteOpenApiPlugin(options: options)
    ],
  );
}

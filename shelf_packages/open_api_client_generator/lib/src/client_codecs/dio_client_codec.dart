import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/client_codecs/client_codec.dart';

class DioClientCodec extends ClientCodec {
  const DioClientCodec();

  @override
  Reference get type => const Reference('Dio', 'package:dio/dio.dart');

  @override
  String encodeSendMethod(
    String method,
    String path, {
    String? queryParametersVar,
    String? dataVar,
  }) {
    final b = StringBuffer();
    b.write("await client.${method.toLowerCase()}('$path'");
    if (dataVar != null) b.write(', data: $dataVar');
    if (queryParametersVar != null) b.write(', queryParameters: $queryParametersVar');
    b.write(');');
    return b.toString();
  }

  @override
  String encodeExceptionInstance(String responseVar) {
    return '''
DioException.badResponse(
  statusCode: $responseVar.statusCode!,
  requestOptions: $responseVar.requestOptions,
  response: $responseVar,
)''';
  }
}

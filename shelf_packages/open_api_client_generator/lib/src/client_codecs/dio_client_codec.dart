import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/client_codecs/client_codec.dart';
import 'package:open_api_specification/open_api_spec.dart';

class DioClientCodec extends ClientCodec {
  const DioClientCodec();

  @override
  Reference get type => const Reference('Dio', 'package:dio/dio.dart');

  @override
  Method rebuildMethod(Method method, String path, String name, OperationOpenApi operation) {
    return method.rebuild(
      (b) => b
        ..optionalParameters.addAll([
          Parameter(
            (b) => b
              ..named = true
              ..type = const Reference('Options?')
              ..name = r'$options',
          ),
          Parameter(
            (b) => b
              ..named = true
              ..type = const Reference('CancelToken?')
              ..name = r'$cancelToken',
          ),
          if (name != 'DELETE')
            Parameter(
              (b) => b
                ..named = true
                ..type = const Reference('ProgressCallback?')
                ..name = r'$onReceiveProgress',
            ),
        ]),
    );
  }

  @override
  String encodeSendMethod(
    String method,
    String path, {
    String? queryParametersVar,
    String? dataVar,
  }) {
    final b = StringBuffer();
    b.write("await client.${method.toLowerCase()}<dynamic>('$path'");
    if (dataVar != null) b.write(', data: $dataVar');
    if (queryParametersVar != null) b.write(', queryParameters: $queryParametersVar');
    b.write(r', options: $options');
    b.write(r', cancelToken: $cancelToken');
    if (method != 'DELETE') b.write(r', onReceiveProgress: $onReceiveProgress');
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

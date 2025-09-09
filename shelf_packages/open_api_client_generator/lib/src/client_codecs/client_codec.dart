import 'package:code_builder/code_builder.dart';

abstract class ClientCodec {
  const ClientCodec();

  Reference get type;

  String encodeSendMethod(
    String method,
    String path, {
    String? queryParametersVar,
    String? dataVar,
  });

  String encodeExceptionInstance(String responseVar);
}

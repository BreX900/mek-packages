import 'package:code_builder/code_builder.dart';
import 'package:open_api_specification/open_api_spec.dart';

abstract class ClientCodec {
  const ClientCodec();

  Reference get type;

  Class rebuildClass(Class class$, Map<String, ItemPathOpenApi> paths) => class$;

  Method rebuildMethod(Method method, String path, String name, OperationOpenApi operation) =>
      method;

  String encodeSendMethod(
    String method,
    String path, {
    String? queryParametersVar,
    String? dataVar,
  });

  String encodeExceptionInstance(String responseVar);
}

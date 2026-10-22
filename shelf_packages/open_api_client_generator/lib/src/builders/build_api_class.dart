import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:open_api_client_generator/src/builders/build_schema_class.dart';
import 'package:open_api_client_generator/src/client_codecs/client_codec.dart';
import 'package:open_api_client_generator/src/code_utils/code_buffer.dart';
import 'package:open_api_client_generator/src/code_utils/document.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/collection_codecs/collection_codec.dart';
import 'package:open_api_client_generator/src/options/context.dart';
import 'package:open_api_client_generator/src/serialization_codec/serialization_codec.dart';
import 'package:open_api_client_generator/src/utils/extensions.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:recase/recase.dart';

class BuildApiClass with ContextMixin {
  @override
  final Context context;
  final ClientCodec clientCodec;
  final SerializationCodec dataCodec;
  CollectionCodec get collectionCodec => dataCodec.collectionCodec;
  final BuildSchemaClass buildSchemaClass;

  const BuildApiClass({
    required this.context,
    required this.clientCodec,
    required this.dataCodec,
    required this.buildSchemaClass,
  });

  String _encodeOperationMethodName({
    required String? id,
    required String name,
    required String path,
  }) {
    if (id != null) return codecs.encodeName(id);
    return '$name${path.replaceAll('/', '_').replaceAll('{', '').replaceAll('}', '').pascalCase}';
  }

  String encodePath(String path) {
    return path.replaceAllMapped(RegExp(r'\{(\w*)\}'), (match) {
      return '\$${codecs.encodeName(match.group(1)!)}';
    });
  }

  String _buildOperationCode({
    required String method,
    required String path,
    required List<ParameterOpenApi> queryParameters,
    required Reference? requestType,
    required int? successCode,
    required Map<int, Reference> responses,
  }) {
    final b = CodeBuffer();

    if (queryParameters.isNotEmpty) {
      b.write('final _queryParameters = <String, Object?>{\n');
      b.writeAll(
        queryParameters.map((e) {
          final key = codecs.encodeDartValue(e.name);
          final varName = codecs.encodeName(e.name);
          final varEncoder = dataCodec.encodeSerialization(
            buildSchemaClass.build(varName, e.schema!).toNullable(false),
            varName,
          );

          final code = '$key: $varEncoder,\n';
          if (e.required) return code;
          return 'if ($varName != null) $code';
        }),
      );
      b.write('};\n');
    }

    if (requestType != null && !requestType.isBytesStream) {
      b.write('final _data = ${dataCodec.encodeSerialization(requestType, '_request')};');
    }

    if (responses.isNotEmpty) b.write('final _response = ');

    b.writeln(
      clientCodec.encodeSendMethod(
        method.toUpperCase(),
        encodePath(path),
        queryParametersVar: queryParameters.isNotEmpty ? '_queryParameters' : null,
        dataVar: requestType != null ? (requestType.isBytesStream ? '_request' : '_data') : null,
      ),
    );

    if (responses.isNotEmpty) {
      b.write('return switch (_response.statusCode) {\n');

      for (final MapEntry(key: code, value: type) in responses.entries) {
        b.write('$code => ');

        if (type == clientCodec.responseType) {
          b.write('_response');
        } else if (type.isVoid) {
          if (code == successCode) {
            b.write('null');
          } else {
            b.write('throw ${clientCodec.encodeExceptionInstance('_response')}');
          }
        } else {
          final deserialization = dataCodec.encodeDeserialization(type, '_response.data');
          if (code == successCode) {
            b.write(deserialization);
          } else {
            b.write('throw $deserialization');
          }
        }

        b.write(',');
      }
      b.write('_ => throw ${clientCodec.encodeExceptionInstance('_response')},');

      b.write('};\n');
    }

    return b.toString();
  }

  Map<int, Reference> _resolveResponses(String methodName, Map<int, ResponseOpenApi> responses) {
    return responses.map((code, response) {
      if (response.content?.jsonOrAny?.schema case final responseSchema?) {
        final responseClassName = code >= 200 && code < 300
            ? '${methodName}Response'
            : '${methodName}Exception';

        return MapEntry(code, buildSchemaClass.build(responseClassName, responseSchema));
      }
      if (response.content != null) {
        return MapEntry(code, clientCodec.responseType);
      }
      return MapEntry(code, References.void$);
    });
  }

  Method _buildMethod(String path, String name, OperationOpenApi operation) {
    final methodName = _encodeOperationMethodName(
      id: operation.operationId,
      name: name,
      path: path,
    );

    final pathParameters = operation.parameters.where((e) => e.in$.path).toList();
    final queryParameters = operation.parameters.where((e) => e.in$.query).toList();

    Reference? requestType;
    if (operation.requestBody?.content.jsonOrAny?.schema case final requestSchema?) {
      final requestClassName = '${methodName}Request';
      final requestClass = buildSchemaClass.build(requestClassName, requestSchema);
      requestType = requestClass.type;
    } else if (operation.requestBody?.content.octetStream != null) {
      requestType = References.bytesStream;
    } else if (operation.requestBody != null) {
      requestType = References.object;
    }
    requestType = requestType?.toNullable(!(operation.requestBody?.required ?? false));

    final responses = _resolveResponses(methodName, operation.responses);

    final successResponse = responses.entries.firstWhereOrNull((e) {
      return e.key >= 200 && e.key < 300;
    });

    final operationCode = _buildOperationCode(
      method: name,
      path: path,
      queryParameters: queryParameters,
      requestType: requestType,
      successCode: successResponse?.key,
      responses: responses,
    );

    final method = Method(
      (b) => b
        ..docs.addAll(
          Docs.format(
            Docs.documentMethod(
              summary: operation.summary,
              description: operation.description,
              params: operation.parameters.expand((param) {
                return Docs.documentField(
                  name: codecs.encodeName(param.name),
                  description: param.description,
                  example: param.example,
                );
              }),
            ),
          ),
        )
        ..returns = References.future(successResponse?.value)
        ..name = methodName
        ..requiredParameters.addAll(
          pathParameters.map((param) {
            return Parameter(
              (b) => b
                ..type = buildSchemaClass
                    .build(param.name, param.schema!)
                    .toNullable(!param.required)
                ..name = codecs.encodeName(param.name),
            );
          }),
        )
        ..requiredParameters.addAll([
          if (requestType != null)
            Parameter(
              (b) => b
                ..type = requestType
                ..name = '_request',
            ),
        ])
        ..optionalParameters.addAll(
          queryParameters.map((param) {
            return Parameter(
              (b) => b
                ..named = true
                ..required = param.required
                ..type = buildSchemaClass
                    .build(param.name, param.schema!)
                    .toNullable(!param.required)
                ..name = codecs.encodeName(param.name),
            );
          }),
        )
        ..modifier = MethodModifier.async
        ..body = Code(operationCode),
    );
    return clientCodec.rebuildMethod(method, path, name.toUpperCase(), operation);
  }

  Class call(Map<String, ItemPathOpenApi> paths) {
    final fields = <Field>[
      Field(
        (b) => b
          ..modifier = FieldModifier.final$
          ..type = clientCodec.type
          ..name = 'client',
      ),
    ];

    final methods = paths.entries.expandEntry((path, itemPath) {
      return itemPath.operations.entries.mapEntry((name, operation) {
        return _buildMethod(path, name, operation);
      });
    });

    final class$ = Class(
      (b) => b
        ..name = options.apiClassName
        ..fields.addAll(fields)
        ..constructors.add(
          Constructor(
            (b) => b
              ..optionalParameters.addAll(
                fields.map((field) {
                  return Parameter(
                    (b) => b
                      ..named = true
                      ..required = true
                      ..toThis = true
                      ..name = field.name,
                  );
                }),
              ),
          ),
        )
        ..methods.addAll(methods),
    );
    return clientCodec.rebuildClass(class$, paths);
  }
}

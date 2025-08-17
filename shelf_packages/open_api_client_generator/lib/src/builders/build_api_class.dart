import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:open_api_client_generator/src/builders/build_schema_class.dart';
import 'package:open_api_client_generator/src/client_codecs/client_codec.dart';
import 'package:open_api_client_generator/src/code_utils/code_buffer.dart';
import 'package:open_api_client_generator/src/code_utils/document.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/code_utils/schema_to_reference.dart';
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
          final varEncoder = collectionCodec.encodeToCore(ref(e.schema!).toNullable(!e.required));
          return '$key: $varName$varEncoder,\n';
        }),
      );
      b.write('};\n');
    }

    if (requestType != null) {
      b.write('final _data = ${dataCodec.encodeSerialization(requestType, '_request')};');
    }

    if (responses.isNotEmpty) b.write('final _response = ');

    b.writeln(
      clientCodec.encodeSendMethod(
        method.toUpperCase(),
        encodePath(path),
        queryParametersVar: queryParameters.isNotEmpty ? '_queryParameters' : null,
        dataVar: requestType != null ? '_data' : null,
      ),
    );

    if (responses.isNotEmpty) {
      b.write('return switch (_response.statusCode) {\n');
      b.indent(() {
        for (final MapEntry(key: code, value: type) in responses.entries) {
          b.write('$code => ');
          final deserialization = dataCodec.encodeDeserialization(type, '_response.data');
          if (code == successCode) {
            if (type.isVoid) {
              b.write('null');
            } else {
              b.write(deserialization);
            }
          } else {
            if (type.isVoid) {
              b.write('throw ${clientCodec.encodeExceptionInstance('_response')}');
            } else {
              b.write('throw $deserialization');
            }
          }
          b.write(',');
        }
        b.write('_ => throw ${clientCodec.encodeExceptionInstance('_response')},');
      });
      b.write('};\n');
    }

    return b.toString();
  }

  Map<int, Reference> _resolveResponses(String methodName, Map<int, ResponseOpenApi> responses) {
    return responses.map((code, response) {
      final responseMedia = response.content?.jsonOrAny;
      final responseSchema = responseMedia?.schema;
      final responseClassName = code >= 200 && code < 300
          ? '${methodName}Response'
          : '${methodName}Exception';
      final responseClass = responseSchema != null
          ? buildSchemaClass.call(responseClassName, responseSchema.resolve(components))
          : References.void$;
      return MapEntry(code, responseClass);
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

    final request = operation.requestBody;
    final requestSchema = request?.content.jsonOrAny?.schema;
    final requestClassName = '${methodName}Request';
    final requestClass = requestSchema != null
        ? buildSchemaClass.call(requestClassName, requestSchema.resolve(components))
        : null;
    final requestType = requestClass?.type.toNullable(!(request?.required ?? false));

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

    return Method(
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
                ..type = ref(param.schema!).toNullable(!param.required)
                ..name = codecs.encodeName(param.name),
            );
          }),
        )
        ..requiredParameters.addAll([
          if (request != null && requestSchema != null)
            Parameter(
              (b) => b
                ..type = requestType
                ..name = '_request',
            ),
        ])
        ..optionalParameters.addAll(
          queryParameters.map((e) {
            return Parameter(
              (b) => b
                ..named = true
                ..required = e.required
                ..type = ref(e.schema!).toNullable(!e.required)
                ..name = codecs.encodeName(e.name),
            );
          }),
        )
        ..modifier = MethodModifier.async
        ..body = Code(operationCode),
    );
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

    return Class(
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
  }
}

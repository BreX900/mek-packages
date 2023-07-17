import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:one_for_all_generator/src/code_generator.dart';
import 'package:one_for_all_generator/src/emitters/kotlin_emitter.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:recase/recase.dart';

class KotlinGenerator extends CodeGenerator with WriteToOutputFile {
  final KotlinOptions options;
  final _specs = <KotlinSpec>[];

  @override
  String get outputFile => options.outputFile;

  KotlinGenerator(super.pluginOptions, this.options) {
    _specs.add(const KotlinClass(
      name: 'PlatformException',
      initializers: [
        KotlinField(name: 'code', type: 'String'),
        KotlinParameter(name: 'message', type: 'String?'),
        KotlinField(name: 'details', type: 'Any?'),
      ],
      implements: ['RuntimeException(message ?: code)'],
    ));
    _specs.add(const KotlinClass(
      name: 'Result<T>',
      initializers: [
        KotlinField(
          visibility: KotlinVisibility.private,
          name: 'result',
          type: 'MethodChannel.Result',
        ),
        KotlinField(
          visibility: KotlinVisibility.private,
          name: 'serializer',
          type: '(data: T) -> Any?',
        ),
      ],
      body: [
        KotlinMethod(
          name: 'success',
          parameters: [
            KotlinParameter(name: 'data', type: 'T'),
          ],
          body: 'result.success(serializer(data))',
        ),
        KotlinMethod(
          name: 'error',
          parameters: [
            KotlinParameter(name: 'code', type: 'String'),
            KotlinParameter(name: 'message', type: 'String'),
            KotlinParameter(name: 'details', type: 'Any?'),
          ],
          body: 'result.error(code, message, details)',
        ),
      ],
    ));
  }

  @override
  void writeHostApiClass(ClassElement element) {
    _specs.add(KotlinClass(
      modifier: KotlinClassModifier.abstract,
      name: _encodeType(element.thisType, false),
      implements: ['FlutterPlugin', 'MethodChannel.MethodCallHandler'],
      fields: const [
        KotlinField(
          modifier: KotlinFieldModifier.lateInit,
          name: 'channel',
          type: 'MethodChannel',
        ),
      ],
      body: [
        ...element.methods.where((e) => e.isFlutterMethod).map((e) {
          final returnType = e.returnType.singleTypeArg;

          final parameters =
              e.parameters.map((e) => _encodeSerialization(e.type, e.name)).join(', ');

          return KotlinMethod(
            modifiers: {KotlinMethodModifier.suspend},
            name: _encodeMethodName(e.name),
            parameters: e.parameters.map((e) {
              return KotlinParameter(
                name: e.name,
                type: _encodeType(e.type, true),
              );
            }).toList(),
            returnType: returnType is VoidType ? null : _encodeType(returnType, true),
            body: '''
return suspendCoroutine { continuation ->
    channel.invokeMethod(
        "${e.name}",
        listOf<Any?>($parameters),
        object : MethodChannel.Result {
            override fun success(result: Any?) {
                continuation.resume(${returnType is VoidType ? 'Unit' : _encodeDeserialization(returnType, 'result')})
            }
            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                continuation.resumeWithException(PlatformException(errorCode, errorMessage, errorDetails))
            }
            override fun notImplemented() {}
        }
    )
}''',
          );
        }),
        ...element.methods.where((e) => e.isHostMethod).map((e) {
          final returnType = e.returnType.singleTypeArg;

          return KotlinMethod(
            name: _encodeMethodName(e.name),
            parameters: [
              // if (returnType is! VoidType)
              KotlinParameter(
                name: 'result',
                type: 'Result<${_encodeType(returnType, true)}>',
              ),
              ...e.parameters.map((e) {
                return KotlinParameter(
                  name: e.name,
                  type: _encodeType(e.type, true),
                );
              }),
            ],
          );
        }),
        KotlinMethod(
          modifiers: {KotlinMethodModifier.override},
          name: 'onMethodCall',
          parameters: const [
            KotlinParameter(annotations: ['NonNull'], name: 'call', type: 'MethodCall'),
            KotlinParameter(annotations: ['NonNull'], name: 'result', type: 'MethodChannel.Result'),
          ],
          body: 'val args = call.arguments<List<Any?>>()!!\n'
              'when (call.method) {\n${element.methods.where((e) => e.isHostMethod).map((e) {
            final returnType = e.returnType.singleTypeArg;

            final parameters =
                e.parameters.mapIndexed((i, e) => _encodeDeserialization(e.type, 'args[$i]'));

            return '''
    "${e.name}" -> {
        val res = Result<${_encodeType(returnType, true)}>(result) {${returnType is VoidType ? 'null' : _encodeSerialization(returnType, 'it')}}
        ${_encodeMethodName(e.name)}(${['res', ...parameters].join(', ')})
    }''';
          }).join('\n')}\n}',
        ),
        KotlinMethod(
          modifiers: {KotlinMethodModifier.override},
          name: 'onAttachedToEngine',
          parameters: const [
            KotlinParameter(
              annotations: ['NonNull'],
              name: 'flutterPluginBinding',
              type: 'FlutterPlugin.FlutterPluginBinding',
            ),
          ],
          body:
              'channel = MethodChannel(flutterPluginBinding.binaryMessenger, "${element.name.snakeCase}")\n'
              'channel.setMethodCallHandler(this)',
        ),
        const KotlinMethod(
          modifiers: {KotlinMethodModifier.override},
          name: 'onDetachedFromEngine',
          parameters: [
            KotlinParameter(
              annotations: ['NonNull'],
              name: 'flutterPluginBinding',
              type: 'FlutterPlugin.FlutterPluginBinding',
            ),
          ],
          body: 'channel.setMethodCallHandler(null)',
        ),
      ],
    ));
  }

  @override
  void writeDataClass(ClassElement element) {
    final fields = element.fields.where((e) => !e.isStatic && e.isFinal && !e.hasInitializer);

    _specs.add(KotlinClass(
      modifier: KotlinClassModifier.data,
      name: _encodeType(element.thisType, false),
      initializers: fields.map((e) {
        return KotlinField(
          name: _encodeVarName(e.name),
          type: _encodeType(e.type, true),
        );
      }).toList(),
      body: [
        KotlinMethod(
          name: 'serialize',
          returnType: 'List<Any?>',
          body: 'return listOf(\n${fields.map((e) {
            return '    ${_encodeSerialization(e.type, _encodeVarName(e.name))},\n';
          }).join()})',
        ),
        KotlinClass(
          modifier: KotlinClassModifier.companion,
          name: 'object',
          body: [
            KotlinMethod(
              name: 'deserialize',
              parameters: [
                const KotlinParameter(
                  name: 'serialized',
                  type: 'List<Any?>',
                ),
              ],
              returnType: _encodeType(element.thisType, true),
              body: 'return ${_encodeType(element.thisType, false)}(\n${fields.mapIndexed((i, e) {
                return '    ${_encodeVarName(e.name)} = ${_encodeDeserialization(e.type, 'serialized[$i]')},\n';
              }).join()})',
            ),
          ],
        ),
      ],
    ));
  }

  @override
  void writeEnum(EnumElement element) {
    _specs.add(KotlinEnum(
      name: _encodeType(element.thisType, false),
      values: element.fields.where((element) => element.isEnumConstant).map((e) {
        return _encodeVarName(e.name.constantCase);
      }).toList(),
    ));
  }

  String _encodeMethodName(String name) =>
      name.startsWith('_on') ? name.replaceFirst('_on', '').camelCase : 'on${name.pascalCase}';

  String _encodeVarName(String name) {
    return switch (name) {
      'object' => '${name}_',
      _ => name,
    };
  }

  String _encodeType(DartType type, bool withNullability) {
    final questionOrEmpty = withNullability ? type.questionOrEmpty : '';
    if (type.isDartCoreObject || type is DynamicType) return 'Any$questionOrEmpty';
    if (type is VoidType) return 'Unit$questionOrEmpty';
    if (type.isDartCoreNull) return 'null$questionOrEmpty';
    if (type.isDartCoreBool) return 'Boolean$questionOrEmpty';
    if (type.isDartCoreInt) return 'Long$questionOrEmpty';
    if (type.isDartCoreDouble) return 'Double$questionOrEmpty';
    if (type.isDartCoreString) return 'String$questionOrEmpty';
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return 'List<${_encodeType(typeArg, withNullability)}>$questionOrEmpty';
    }
    if (type.isDartCoreMap) {
      final typeArgs = type.doubleTypeArgs;
      return 'HashMap<${_encodeType(typeArgs.$1, withNullability)}, ${_encodeType(typeArgs.$2, withNullability)}>$questionOrEmpty';
    }
    return type
        .getDisplayString(withNullability: withNullability)
        .replaceFirstMapped(RegExp(r'\w+'), (match) => '${match.group(0)}Api');
  }

  String _encodeSerialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('void type no supported');
    if (type.isPrimitive) return varAccess;
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '$varAccess${type.questionOrEmpty}.map{${_encodeSerialization(typeArg, 'it')}}';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      final serializer = 'hashMapOf(*${type.isNullable ? 'it' : varAccess}'
          '.map{(k, v) -> ${_encodeSerialization(typesArgs.$1, 'k')} to ${_encodeDeserialization(typesArgs.$2, 'v')}}'
          '.toTypedArray())';
      return type.isNullable ? '$varAccess?.let{$serializer}' : serializer;
    }
    if (type.isDartCoreEnum || type.element is EnumElement) {
      return '$varAccess${type.questionOrEmpty}.ordinal';
    }
    return '$varAccess${type.questionOrEmpty}.serialize()';
  }

  String _encodeDeserialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('void type no supported');
    if (type.isPrimitive) return '$varAccess as ${_encodeType(type, true)}';
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '($varAccess as List<*>${type.questionOrEmpty})'
          '${type.questionOrEmpty}.map{${_encodeDeserialization(typeArg, 'it')}}';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      final serializer = 'hashMapOf(*(${type.isNullable ? 'it' : varAccess} as HashMap<*, *>)'
          '.map{(k, v) -> ${_encodeDeserialization(typesArgs.$1, 'k')} to ${_encodeDeserialization(typesArgs.$2, 'v')}}'
          '.toTypedArray())';
      return type.isNullable ? '$varAccess?.let{$serializer}' : serializer;
    }

    if (type.isDartCoreEnum || type.element is EnumElement) {
      return '($varAccess as Int${type.questionOrEmpty})'
          '${type.questionOrEmpty}.let{${_encodeType(type, false)}.values()[it]}';
    }
    return '($varAccess as List<Any?>${type.questionOrEmpty})'
        '${type.questionOrEmpty}.let{${_encodeType(type, false)}.deserialize(it)}';
  }

  @override
  String toString() => '${KotlinEmitter().encode(KotlinLibrary(
        package: options.package,
        imports: [
          'io.flutter.embedding.engine.plugins.FlutterPlugin',
          'io.flutter.plugin.common.MethodCall',
          'io.flutter.plugin.common.MethodChannel',
          // 'io.flutter.plugin.common.MethodChannel.MethodCallHandler',
          // 'io.flutter.plugin.common.MethodChannel.Result',
          'kotlin.coroutines.resume',
          'kotlin.coroutines.resumeWithException',
          'kotlin.coroutines.suspendCoroutine',
        ],
        body: _specs,
      ))}';
}

extension on DartType {
  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;
  String get questionOrEmpty => isNullable ? '?' : '';
  // String get exclamationOrEmpty => isNullable ? '!!' : '';
}

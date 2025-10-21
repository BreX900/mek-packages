import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';
import 'package:one_for_all_generator/src/emitters/kotlin_emitter.dart';
import 'package:one_for_all_generator/src/handlers.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:one_for_all_generator/src/utils.dart';
import 'package:recase/recase.dart';

class KotlinApiBuilder extends ApiBuilder {
  final KotlinOptions options;
  final ApiCodecs codecs;
  final _specs = <KotlinTopLevelSpec>[];
  // var _needResultClass = false;
  // var _needControllerSink = false;
  // var _needRunAsync = true;

  @override
  String get outputFile => options.outputFile;

  KotlinApiBuilder(super.pluginOptions, this.options, this.codecs) {
    _specs.add(const KotlinClass(
      name: 'PlatformError',
      initializers: [
        KotlinField(name: 'code', type: 'String'),
        KotlinParameter(name: 'message', type: 'String?'),
        KotlinField(name: 'details', type: 'Any?', assignment: 'null'),
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
          parameters: [KotlinParameter(name: 'data', type: 'T')],
          lambda: true,
          body: 'result.success(serializer(data))',
        ),
        KotlinMethod(
          name: 'error',
          parameters: [
            KotlinParameter(name: 'error', type: 'PlatformError'),
          ],
          body: 'result.error(error.code, error.message, error.details)',
        ),
      ],
    ));
    _specs.add(const KotlinClass(
      name: 'ControllerSink<T>',
      initializers: [
        KotlinField(
          visibility: KotlinVisibility.private,
          name: 'sink',
          type: 'EventChannel.EventSink',
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
          parameters: [KotlinParameter(name: 'data', type: 'T')],
          lambda: true,
          body: 'sink.success(serializer(data))',
        ),
        KotlinMethod(
          name: 'error',
          parameters: [
            KotlinParameter(name: 'error', type: 'PlatformError'),
          ],
          lambda: true,
          body: 'sink.error(error.code, error.message, error.details)',
        ),
        KotlinMethod(
          name: 'endOfStream',
          lambda: true,
          body: 'sink.endOfStream()',
        ),
      ],
    ));
  }

  @override
  void writeHostApiClass(HostApiHandler handler) {
    final HostApiHandler(:element, kotlinMethods: methods) = handler;

    _specs.add(KotlinInterface(
      name: codecs.encodeName(element.displayName),
      body: [
        ...methods.map((_) {
          final MethodHandler(element: e, kotlin: methodType) = _;
          final returnType = e.returnType.singleTypeArg;

          return KotlinMethod(
            modifiers: {if (methodType == MethodApiType.async) KotlinMethodModifier.suspend},
            name: _encodeMethodName(e.displayName),
            parameters: [
              if (methodType == MethodApiType.callbacks)
                KotlinParameter(
                  name: 'result',
                  type: 'Result<${codecs.encodeType(returnType)}>',
                ),
              ...e.formalParameters.map((e) {
                return KotlinParameter(
                  name: e.displayName,
                  type: codecs.encodeType(e.type),
                );
              }),
            ],
            returns: methodType == MethodApiType.callbacks
                ? null
                : (returnType is VoidType ? null : codecs.encodeType(returnType)),
          );
        }),
        KotlinMethod(
          visibility: KotlinVisibility.private,
          name: 'onMethodCall',
          parameters: const [
            KotlinParameter(
              name: 'call',
              type: 'MethodCall',
            ),
            KotlinParameter(
              name: 'result',
              type: 'MethodChannel.Result',
            ),
          ],
          body: '''
try {
    val args = call.arguments<List<Any?>>()!!
    fun runAsync(callback: suspend () -> Any?) {
        coroutineScope.launch {
            val res = callback()
            withContext(Dispatchers.Main) { result.success(res) }
        }
    }
    when (call.method) {
${methods.map((_) {
            final MethodHandler(element: e, kotlin: methodType) = _;
            final returnType = e.returnType.singleTypeArg;

            final parameters = e.formalParameters
                .mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]'));

            return '''
        "${e.displayName}" -> ${switch (methodType) {
              MethodApiType.sync => '''{
            ${returnType is VoidType ? '' : 'val res = '}${_encodeMethodName(e.displayName)}(${parameters.join(', ')})
            result.success(${returnType is VoidType ? 'null' : codecs.encodeSerialization(returnType, 'res')})
        }''',
              MethodApiType.callbacks => '''{
            val res = Result<${codecs.encodeType(returnType)}>(result) { ${returnType is VoidType ? 'null' : codecs.encodeSerialization(returnType, 'it')} }
            ${_encodeMethodName(e.displayName)}(${['res', ...parameters].join(', ')})
        }''',
              MethodApiType.async => '''runAsync {
            ${returnType is VoidType ? '' : 'val res = '}${_encodeMethodName(e.displayName)}(${parameters.join(', ')})
            return@runAsync ${returnType is VoidType ? 'null' : codecs.encodeSerialization(returnType, 'res')}
        }''',
            }}''';
          }).join('\n')}
    }
} catch (e: PlatformError) {
    result.error(e.code, e.message, e.details)
}''',
        ),
        KotlinClass(
          modifier: KotlinClassModifier.companion,
          name: 'object',
          fields: const [
            KotlinField(
              visibility: KotlinVisibility.private,
              modifier: KotlinFieldModifier.lateInit,
              name: 'channel',
              type: 'MethodChannel',
            ),
            KotlinField(
              visibility: KotlinVisibility.private,
              modifier: KotlinFieldModifier.lateInit,
              name: 'coroutineScope',
              type: 'CoroutineScope',
            ),
          ],
          body: [
            KotlinMethod(
              name: 'setHandler',
              parameters: [
                const KotlinParameter(name: 'binaryMessenger', type: 'BinaryMessenger'),
                KotlinParameter(name: 'api', type: codecs.encodeName(element.displayName)),
                const KotlinParameter(
                    name: 'coroutineScope', type: 'CoroutineScope?', defaultTo: 'null'),
              ],
              body: '''
channel = MethodChannel(binaryMessenger, "${handler.methodChannelName()}")
this.coroutineScope = coroutineScope ?: MainScope()
channel.setMethodCallHandler(api::onMethodCall)''',
            ),
            const KotlinMethod(
              name: 'removeHandler',
              body: '''
channel.setMethodCallHandler(null)
coroutineScope.cancel()''',
            ),
          ],
        )
      ],
    ));

    _specs.addAll(element.methods2.where((e) => e.isHostApiEvent).map((e) {
      final returnType = e.returnType.singleTypeArg;

      final parametersType = [
        'sink: ControllerSink<${codecs.encodeType(returnType)}>',
        ...e.formalParameters.map((e) => '${e.displayName}: ${codecs.encodeType(e.type)}')
      ].join(', ');
      final parameters = [
        'sink',
        ...e.formalParameters
            .mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]')),
      ].join(', ');

      return KotlinClass(
        name: codecs.encodeName('${e.displayName}Controller'),
        initializers: const [
          KotlinParameter(name: 'binaryMessenger', type: 'BinaryMessenger'),
        ],
        fields: [
          KotlinField(
            visibility: KotlinVisibility.private,
            name: 'channel',
            type: 'EventChannel',
            assignment: 'EventChannel(binaryMessenger, "${handler.eventChannelName(e)}")',
          ),
        ],
        body: [
          KotlinMethod(
            name: 'setHandler',
            parameters: [
              KotlinParameter(
                name: 'onListen',
                type: '($parametersType) -> Unit',
              ),
              const KotlinParameter(
                name: 'onCancel',
                type: '() -> Unit',
              ),
            ],
            body: '''
channel.setStreamHandler(object : EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val args = arguments as List<Any?>
        val sink = ControllerSink<${codecs.encodeType(returnType)}>(events) {${returnType is VoidType ? 'null' : codecs.encodeSerialization(returnType, 'it')}}
        onListen($parameters)
    }
    override fun onCancel(arguments: Any?) = onCancel()
})''',
          ),
          const KotlinMethod(
            name: 'removeHandler',
            lambda: true,
            body: 'channel.setStreamHandler(null)',
          ),
        ],
      );
    }));
  }

  @override
  void writeFlutterApiClass(FlutterApiHandler handler) {
    final FlutterApiHandler(:element, kotlinMethods: methods) = handler;

    _specs.add(KotlinClass(
      name: codecs.encodeName(element.displayName),
      initializers: const [
        KotlinParameter(
          name: 'binaryMessenger',
          type: 'BinaryMessenger',
        ),
      ],
      fields: [
        KotlinField(
          visibility: KotlinVisibility.private,
          name: 'channel',
          type: 'MethodChannel',
          assignment: 'MethodChannel(binaryMessenger, "${handler.methodChannelName()}")',
        ),
      ],
      body: methods.map((_) {
        final MethodHandler(element: e, kotlin: methodType) = _;
        final returnType = e.returnType.thisOrSingleTypeArg;

        final parameters = e.formalParameters
            .map((e) => codecs.encodeSerialization(e.type, e.displayName))
            .join(', ');

        return KotlinMethod(
          modifiers: {if (methodType == MethodApiType.async) KotlinMethodModifier.suspend},
          name: _encodeMethodName(e.displayName),
          parameters: [
            ...e.formalParameters.map((e) {
              return KotlinParameter(
                name: e.displayName,
                type: codecs.encodeType(e.type),
              );
            }),
            if (methodType == MethodApiType.callbacks) ...[
              const KotlinParameter(
                name: 'onError',
                type: '(error: PlatformError) -> Unit',
              ),
              KotlinParameter(
                name: 'onSuccess',
                type: '(data: ${codecs.encodeType(returnType)}) -> Unit',
              ),
            ],
          ],
          returns: methodType == MethodApiType.async
              ? (returnType is VoidType ? null : codecs.encodeType(returnType))
              : null,
          body: switch (methodType) {
            MethodApiType.callbacks => '''
channel.invokeMethod(
    "${handler.methodChannelName(e)}",
    listOf<Any?>($parameters),
    object : MethodChannel.Result {
        override fun notImplemented() {}
        override fun error(code: String, message: String?, details: Any?) = 
            onError(PlatformError(code, message, details))
        override fun success(result: Any?) =
            onSuccess(${returnType is VoidType ? 'Unit' : codecs.encodeDeserialization(returnType, 'result')})
    }
)''',
            MethodApiType.sync => '''
channel.invokeMethod("${handler.methodChannelName(e)}", listOf<Any?>($parameters))''',
            MethodApiType.async => '''
return suspendCoroutine { continuation ->
    channel.invokeMethod(
        "${handler.methodChannelName(e)}",
        listOf<Any?>($parameters),
        object : MethodChannel.Result {
            override fun notImplemented() {}
            override fun error(code: String, message: String?, details: Any?) =
                continuation.resumeWithException(PlatformError(code, message, details))
            override fun success(result: Any?) =
                continuation.resume(${returnType is VoidType ? 'Unit' : codecs.encodeDeserialization(returnType, 'result')})
        }
    )
}''',
          },
        );
      }).toList(),
    ));
  }

  @override
  void writeSerializableClass(SerializableClassHandler handler, {ClassElement2? extend}) {
    if (!handler.kotlinGeneration) return;
    final SerializableClassHandler(:element, :flutterToHost, :hostToFlutter, :params, :children) =
        handler;

    if (children != null) {
      _specs.add(KotlinClass(
        modifier: KotlinClassModifier.sealed,
        name: codecs.encodeName(element.displayName),
        body: [
          if (flutterToHost)
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
                  returns: codecs.encodeType(element.thisType),
                  body: 'return when (serialized[0]) {\n'
                      '${children.map((h) {
                    return '    "${h.element.displayName}" -> ${codecs.encodeName(h.element.displayName)}.deserialize(serialized.drop(1))\n';
                  }).join()}'
                      '    else -> throw Error()\n'
                      '}',
                ),
              ],
            ),
        ],
      ));
      for (final child in children) {
        writeSerializableClass(child, extend: element);
      }
      return;
    }

    _specs.add(KotlinClass(
      modifier: params.isNotEmpty ? KotlinClassModifier.data : null,
      name: codecs.encodeName(element.displayName),
      extend: extend != null ? '${codecs.encodeName(extend.displayName)}()' : null,
      initializers: params.map((e) {
        return KotlinField(
          name: _encodeVarName(e.name),
          type: codecs.encodeType(e.type),
        );
      }).toList(),
      body: [
        if (hostToFlutter)
          KotlinMethod(
            name: 'serialize',
            returns: 'List<Any?>',
            body: 'return listOf(\n${params.map((e) {
              return '    ${codecs.encodeSerialization(e.type, _encodeVarName(e.name))},\n';
            }).join()})',
          ),
        if (flutterToHost)
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
                returns: codecs.encodeType(element.thisType),
                body:
                    'return ${codecs.encodeName(element.displayName)}(\n${params.mapIndexed((i, e) {
                  return '    ${_encodeVarName(e.name)} = ${codecs.encodeDeserialization(e.type, 'serialized[$i]')},\n';
                }).join()})',
              ),
            ],
          ),
      ],
    ));
  }

  @override
  void writeSerializableEnum(SerializableEnumHandler handler) {
    final SerializableEnumHandler(:element) = handler;

    _specs.add(KotlinEnum(
      name: codecs.encodeName(element.displayName),
      values: element.fields2.where((element) => element.isEnumConstant).map((e) {
        return _encodeVarName(e.displayName.constantCase);
      }).toList(),
    ));
  }

  String _encodeMethodName(String name) {
    name = name.replaceFirst('_', '');
    return name.startsWith('on') ? name.replaceFirst('on', '').camelCase : 'on${name.pascalCase}';
  }

  String _encodeVarName(String name) {
    return switch (name) {
      'object' => '${name}_',
      _ => name,
    };
  }

  @override
  void writeException(EnumElement2 element) {
    // final name = element.name.replaceFirst('Code', '');
    // _specs.add(KotlinEnum(
    //   name: element.name,
    //   values: element.fields.where((e) => e.isEnumConstant).map((e) => e.name).toList(),
    // ));
    // _specs.add(KotlinClass(
    //   name: name,
    //   initializers: [
    //     KotlinField(name: 'code', type: 'String'),
    //     KotlinParameter(name: 'message', type: 'String?'),
    //     KotlinField(name: 'details', type: 'Any?'),
    //   ],
    //   implements: ['RuntimeException(if (message != null) "\$code: \$message" else code)'],
    //   body: [
    //     // KotlinClass(
    //     //   modifier: KotlinClassModifier.companion,
    //     //   name: 'object',
    //     //   body: element.fields.where((e) => e.isEnumConstant).map((e) {
    //     //     return KotlinMethod(
    //     //       name: e.name,
    //     //       parameters: [
    //     //         KotlinParameter(name: 'message', type: 'Any?', defaultTo: 'null'),
    //     //         KotlinParameter(name: 'details', type: 'Any?', defaultTo: 'null'),
    //     //       ],
    //     //       lambda: true,
    //     //       body:
    //     //           'throw $name("${e.name}", ${e.documentationComment != null ? '"${e.documentationComment}"' : 'null'}, details)',
    //     //     );
    //     //   }).toList(),
    //     // ),
    //   ],
    // ));
  }

  @override
  String build() => '${KotlinEmitter().encode(KotlinLibrary(
        comments: const [generatedCodeComment],
        package: options.package,
        imports: const [
          'io.flutter.plugin.common.BinaryMessenger',
          'io.flutter.plugin.common.EventChannel',
          'io.flutter.plugin.common.MethodCall',
          'io.flutter.plugin.common.MethodChannel',
          'kotlinx.coroutines.CoroutineScope',
          'kotlin.coroutines.resume',
          'kotlin.coroutines.resumeWithException',
          'kotlin.coroutines.suspendCoroutine',
          'kotlinx.coroutines.Dispatchers',
          'kotlinx.coroutines.MainScope',
          'kotlinx.coroutines.cancel',
          'kotlinx.coroutines.launch',
          'kotlinx.coroutines.withContext',
        ],
        body: _specs,
      ))}';
}

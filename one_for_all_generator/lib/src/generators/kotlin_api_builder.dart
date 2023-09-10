import 'package:analyzer/dart/element/element.dart';
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
    _specs.add(KotlinClass(
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
          parameters: [KotlinParameter(name: 'data', type: 'T')],
          lambda: true,
          body: 'result.success(serializer(data))',
        ),
        KotlinMethod(
          name: 'error',
          parameters: [
            KotlinParameter(name: 'code', type: 'String'),
            KotlinParameter(name: 'message', type: 'String?'),
            KotlinParameter(name: 'details', type: 'Any?', defaultTo: 'null'),
          ],
          body: 'result.error(code, message, details)',
        ),
      ],
    ));
    _specs.add(KotlinClass(
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
            KotlinParameter(name: 'code', type: 'String'),
            KotlinParameter(name: 'message', type: 'String?'),
            KotlinParameter(name: 'details', type: 'Any?'),
          ],
          lambda: true,
          body: 'sink.error(code, message, details)',
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
      name: codecs.encodeName(element.name),
      body: [
        ...methods.map((_) {
          final MethodHandler(element: e, kotlin: methodType) = _;
          final returnType = e.returnType.singleTypeArg;

          return KotlinMethod(
            modifiers: {if (methodType == MethodApiType.async) KotlinMethodModifier.suspend},
            name: _encodeMethodName(e.name),
            parameters: [
              if (methodType == MethodApiType.callbacks)
                KotlinParameter(
                  name: 'result',
                  type: 'Result<${codecs.encodeType(returnType)}>',
                ),
              ...e.parameters.map((e) {
                return KotlinParameter(
                  name: e.name,
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

            final parameters =
                e.parameters.mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]'));

            return '''
        "${e.name}" -> ${switch (methodType) {
              MethodApiType.sync => '''{
            ${returnType is VoidType ? '' : 'val res = '}${_encodeMethodName(e.name)}(${parameters.join(', ')})
            result.success(${returnType is VoidType ? 'null' : codecs.encodeSerialization(returnType, 'res')})
        }''',
              MethodApiType.callbacks => '''{
            val res = Result<${codecs.encodeType(returnType)}>(result) { ${returnType is VoidType ? 'null' : codecs.encodeSerialization(returnType, 'it')} }
            ${_encodeMethodName(e.name)}(${['res', ...parameters].join(', ')})
        }''',
              MethodApiType.async => '''runAsync {
            ${returnType is VoidType ? '' : 'val res = '}${_encodeMethodName(e.name)}(${parameters.join(', ')})
            return@runAsync ${returnType is VoidType ? 'null' : codecs.encodeSerialization(returnType, 'res')}
        }''',
            }}''';
          }).join('\n')}
    }
} catch (e: PlatformException) {
    result.error(e.code, e.message, e.details)
}''',
        ),
        KotlinClass(
          modifier: KotlinClassModifier.companion,
          name: 'object',
          fields: [
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
                KotlinParameter(name: 'api', type: codecs.encodeName(element.name)),
                const KotlinParameter(
                    name: 'coroutineScope', type: 'CoroutineScope?', defaultTo: 'null'),
              ],
              body: '''
channel = MethodChannel(binaryMessenger, "${handler.channelName()}")
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

    _specs.addAll(element.methods.where((e) => e.isHostApiEvent).map((e) {
      final returnType = e.returnType.singleTypeArg;

      final parametersType = [
        'sink: ControllerSink<${codecs.encodeType(returnType)}>',
        ...e.parameters.map((e) => '${e.name}: ${codecs.encodeType(e.type)}')
      ].join(', ');
      final parameters = [
        'sink',
        ...e.parameters.mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]')),
      ].join(', ');

      return KotlinClass(
        name: codecs.encodeName('${e.name}Controller'),
        initializers: [
          KotlinParameter(name: 'binaryMessenger', type: 'BinaryMessenger'),
        ],
        fields: [
          KotlinField(
            visibility: KotlinVisibility.private,
            name: 'channel',
            type: 'EventChannel',
            assignment: 'EventChannel(binaryMessenger, "${handler.controllerChannelName(e)}")',
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
              KotlinParameter(
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
          KotlinMethod(
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
      name: codecs.encodeName(element.name),
      initializers: [
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
          assignment: 'MethodChannel(binaryMessenger, "${handler.channelName()}")',
        ),
      ],
      body: methods.map((_) {
        final MethodHandler(element: e, kotlin: methodType) = _;
        final returnType = e.returnType.thisOrSingleTypeArg;

        final parameters =
            e.parameters.map((e) => codecs.encodeSerialization(e.type, e.name)).join(', ');

        return KotlinMethod(
          modifiers: {if (methodType == MethodApiType.async) KotlinMethodModifier.suspend},
          name: _encodeMethodName(e.name),
          parameters: [
            ...e.parameters.map((e) {
              return KotlinParameter(
                name: e.name,
                type: codecs.encodeType(e.type),
              );
            }).toList(),
            if (methodType == MethodApiType.callbacks) ...[
              KotlinParameter(
                name: 'onError',
                type: '(code: String, message: String?, details: Any?) -> Unit',
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
    "${handler.channelName(e)}",
    listOf<Any?>($parameters),
    object : MethodChannel.Result {
        override fun notImplemented() {}
        override fun error(code: String, message: String?, details: Any?) = 
            onError(code, message, details)
        override fun success(result: Any?) =
            onSuccess(${returnType is VoidType ? 'Unit' : codecs.encodeDeserialization(returnType, 'result')})
    }
)''',
            MethodApiType.sync => '''
channel.invokeMethod("${handler.channelName(e)}", listOf<Any?>($parameters))''',
            MethodApiType.async => '''
return suspendCoroutine { continuation ->
    channel.invokeMethod(
        "${handler.channelName(e)}",
        listOf<Any?>($parameters),
        object : MethodChannel.Result {
            override fun notImplemented() {}
            override fun error(code: String, message: String?, details: Any?) =
                continuation.resumeWithException(PlatformException(code, message, details))
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
  void writeSerializableClass(SerializableClassHandler handler, {ClassElement? extend}) {
    if (!handler.kotlinGeneration) return;
    final SerializableClassHandler(:element, :flutterToHost, :hostToFlutter, :children) = handler;
    final fields = element.fields.where((e) => !e.isStatic && e.isFinal && !e.hasInitializer);

    if (children != null) {
      _specs.add(KotlinClass(
        modifier: KotlinClassModifier.sealed,
        name: codecs.encodeName(element.name),
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
                    return '    "${h.element.name}" -> ${codecs.encodeName(h.element.name)}.deserialize(serialized.drop(1))\n';
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
      modifier: fields.isNotEmpty ? KotlinClassModifier.data : null,
      name: codecs.encodeName(element.name),
      extend: extend != null ? '${codecs.encodeName(extend.name)}()' : null,
      initializers: fields.map((e) {
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
            body: 'return listOf(\n${fields.map((e) {
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
                body: 'return ${codecs.encodeName(element.name)}(\n${fields.mapIndexed((i, e) {
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
      name: codecs.encodeName(element.name),
      values: element.fields.where((element) => element.isEnumConstant).map((e) {
        return _encodeVarName(e.name.constantCase);
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
  void writeException(EnumElement element) {
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

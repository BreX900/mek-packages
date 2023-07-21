import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';
import 'package:one_for_all_generator/src/emitters/kotlin_emitter.dart';
import 'package:one_for_all_generator/src/handlers.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:recase/recase.dart';

class KotlinApiBuilder extends ApiBuilder {
  final KotlinOptions options;
  final ApiCodecs codecs;
  final _specs = <KotlinSpec>[];

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
            KotlinParameter(name: 'details', type: 'Any?'),
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
    final HostApiHandler(:element) = handler;

    _specs.add(KotlinClass(
      modifier: KotlinClassModifier.abstract,
      name: handler.className,
      implements: ['FlutterPlugin', 'MethodChannel.MethodCallHandler'],
      fields: const [
        KotlinField(
          modifier: KotlinFieldModifier.lateInit,
          name: 'channel',
          type: 'MethodChannel',
        ),
      ],
      body: [
        ...element.methods.where((e) => e.isHostApiMethod).map((e) {
          final returnType = e.returnType.singleTypeArg;

          return KotlinMethod(
            name: _encodeMethodName(e.name),
            parameters: [
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
          );
        }),
        KotlinMethod(
          modifiers: {KotlinMethodModifier.override},
          name: 'onMethodCall',
          parameters: const [
            KotlinParameter(
              annotations: ['NonNull'],
              name: 'call',
              type: 'MethodCall',
            ),
            KotlinParameter(
              annotations: ['NonNull'],
              name: 'result',
              type: 'MethodChannel.Result',
            ),
          ],
          body: 'val args = call.arguments<List<Any?>>()!!\n'
              'when (call.method) {\n${element.methods.where((e) => e.isHostApiMethod).map((e) {
            final returnType = e.returnType.singleTypeArg;

            final parameters =
                e.parameters.mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]'));

            return '''
    "${e.name}" -> {
        val res = Result<${codecs.encodeType(returnType)}>(result) {${returnType is VoidType ? 'null' : codecs.encodeSerialization(returnType, 'it')}}
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
              'channel = MethodChannel(flutterPluginBinding.binaryMessenger, "${handler.channelName()}")\n'
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
        name: handler.controllerName(e),
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
    final FlutterApiHandler(:element) = handler;

    _specs.add(KotlinClass(
      name: handler.className,
      initializers: [
        KotlinParameter(
          name: 'binaryMessenger',
          type: 'BinaryMessenger',
        ),
      ],
      fields: [
        KotlinField(
          name: 'channel',
          type: 'MethodChannel',
          assignment: 'MethodChannel(binaryMessenger, "${handler.channelName()}")',
        ),
      ],
      body: element.methods.where((e) => e.isFlutterApiMethod).map((e) {
        final returnType = e.returnType.singleTypeArg;

        final parameters =
            e.parameters.map((e) => codecs.encodeSerialization(e.type, e.name)).join(', ');

        return KotlinMethod(
          modifiers: {KotlinMethodModifier.suspend},
          name: _encodeMethodName(e.name),
          parameters: e.parameters.map((e) {
            return KotlinParameter(
              name: e.name,
              type: codecs.encodeType(e.type),
            );
          }).toList(),
          returns: returnType is VoidType ? null : codecs.encodeType(returnType),
          body: '''
return suspendCoroutine { continuation ->
    channel.invokeMethod(
        "${handler.channelName(e)}",
        listOf<Any?>($parameters),
        object : MethodChannel.Result {
            override fun success(result: Any?) {
                continuation.resume(${returnType is VoidType ? 'Unit' : codecs.encodeDeserialization(returnType, 'result')})
            }
            override fun error(code: String, message: String?, details: Any?) {
                continuation.resumeWithException(PlatformException(code, message, details))
            }
            override fun notImplemented() {}
        }
    )
}''',
        );
      }).toList(),
    ));
  }

  @override
  void writeSerializableClass(SerializableClassHandler handler) {
    if (!handler.kotlinGeneration) return;
    final SerializableClassHandler(:element, :flutterToHost, :hostToFlutter) = handler;
    final fields = element.fields.where((e) => !e.isStatic && e.isFinal && !e.hasInitializer);

    _specs.add(KotlinClass(
      modifier: KotlinClassModifier.data,
      name: codecs.encodeName(element.name),
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

  String _encodeMethodName(String name) =>
      name.startsWith('_on') ? name.replaceFirst('_on', '').camelCase : 'on${name.pascalCase}';

  String _encodeVarName(String name) {
    return switch (name) {
      'object' => '${name}_',
      _ => name,
    };
  }

  // String _encodeType(DartType type, bool withNullability) {
  //   final questionOrEmpty = withNullability ? type.questionOrEmpty : '';
  //   final codec = pluginOptions.findCodec(PlatformApi.kotlin, type);
  //   if (codec != null) {
  //     return '${codec.encodeType(type)}$questionOrEmpty';
  //   }
  //   if (type.isDartCoreObject || type is DynamicType) return 'Any$questionOrEmpty';
  //   if (type is VoidType) return 'Unit$questionOrEmpty';
  //   if (type.isDartCoreNull) return 'null$questionOrEmpty';
  //   if (type.isDartCoreBool) return 'Boolean$questionOrEmpty';
  //   if (type.isDartCoreInt) return 'Long$questionOrEmpty';
  //   if (type.isDartCoreDouble) return 'Double$questionOrEmpty';
  //   if (type.isDartCoreString) return 'String$questionOrEmpty';
  //   if (type.isDartCoreList) {
  //     final typeArg = type.singleTypeArg;
  //     return 'List<${_encodeType(typeArg, withNullability)}>$questionOrEmpty';
  //   }
  //   if (type.isDartCoreMap) {
  //     final typeArgs = type.doubleTypeArgs;
  //     return 'HashMap<${_encodeType(typeArgs.$1, withNullability)}, ${_encodeType(typeArgs.$2, withNullability)}>$questionOrEmpty';
  //   }
  //   return type
  //       .getDisplayString(withNullability: withNullability)
  //       .replaceFirstMapped(RegExp(r'\w+'), (match) => '${match.group(0)}Api');
  // }
  //
  // String _encodeSerialization(DartType type, String varAccess) {
  //   if (type is VoidType) throw StateError('void type no supported');
  //   final codec = pluginOptions.findCodec(PlatformApi.kotlin, type);
  //   if (codec != null) {
  //     final serializer = codec.encodeSerialization(type, type.isNullable ? 'it' : varAccess);
  //     return type.isNullable ? '$varAccess?.let{$serializer}' : serializer;
  //   }
  //   if (type.isPrimitive) return varAccess;
  //   if (type.isDartCoreList) {
  //     final typeArg = type.singleTypeArg;
  //     return '$varAccess${type.questionOrEmpty}.map{${_encodeSerialization(typeArg, 'it')}}';
  //   }
  //   if (type.isDartCoreMap) {
  //     final typesArgs = type.doubleTypeArgs;
  //     final serializer = 'hashMapOf(*${type.isNullable ? 'it' : varAccess}'
  //         '.map{(k, v) -> ${_encodeSerialization(typesArgs.$1, 'k')} to ${_encodeSerialization(typesArgs.$2, 'v')}}'
  //         '.toTypedArray())';
  //     return type.isNullable ? '$varAccess?.let{$serializer}' : serializer;
  //   }
  //   if (type.isDartCoreEnum || type.element is EnumElement) {
  //     return '$varAccess${type.questionOrEmpty}.ordinal';
  //   }
  //   return '$varAccess${type.questionOrEmpty}.serialize()';
  // }
  //
  // String _encodeDeserialization(DartType type, String varAccess) {
  //   if (type is VoidType) throw StateError('void type no supported');
  //   final codec = pluginOptions.findCodec(PlatformApi.kotlin, type);
  //   if (codec != null) {
  //     final deserializer = codec.encodeDeserialization(type, type.isNullable ? 'it' : varAccess);
  //     return type.isNullable ? '$varAccess?.let{$deserializer}' : deserializer;
  //   }
  //   if (type.isPrimitive) return '$varAccess as ${_encodeType(type, true)}';
  //   if (type.isDartCoreList) {
  //     final typeArg = type.singleTypeArg;
  //     return '($varAccess as List<*>${type.questionOrEmpty})'
  //         '${type.questionOrEmpty}.map{${_encodeDeserialization(typeArg, 'it')}}';
  //   }
  //   if (type.isDartCoreMap) {
  //     final typesArgs = type.doubleTypeArgs;
  //     final serializer = 'hashMapOf(*(${type.isNullable ? 'it' : varAccess} as HashMap<*, *>)'
  //         '.map{(k, v) -> ${_encodeDeserialization(typesArgs.$1, 'k')} to ${_encodeDeserialization(typesArgs.$2, 'v')}}'
  //         '.toTypedArray())';
  //     return type.isNullable ? '$varAccess?.let{$serializer}' : serializer;
  //   }
  //
  //   if (type.isDartCoreEnum || type.element is EnumElement) {
  //     return '($varAccess as Int${type.questionOrEmpty})'
  //         '${type.questionOrEmpty}.let{${_encodeType(type, false)}.values()[it]}';
  //   }
  //   return '($varAccess as List<Any?>${type.questionOrEmpty})'
  //       '${type.questionOrEmpty}.let{${_encodeType(type, false)}.deserialize(it)}';
  // }

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
        package: options.package,
        imports: [
          'io.flutter.embedding.engine.plugins.FlutterPlugin',
          'io.flutter.plugin.common.BinaryMessenger',
          'io.flutter.plugin.common.EventChannel',
          'io.flutter.plugin.common.MethodCall',
          'io.flutter.plugin.common.MethodChannel',
          'kotlin.coroutines.resume',
          'kotlin.coroutines.resumeWithException',
          'kotlin.coroutines.suspendCoroutine',
        ],
        body: _specs,
      ))}';
}

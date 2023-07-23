import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';
import 'package:one_for_all_generator/src/emitters/swift_emitter.dart';
import 'package:one_for_all_generator/src/handlers.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:recase/recase.dart';

class SwiftApiBuilder extends ApiBuilder {
  final SwiftOptions options;
  final ApiCodecs codecs;
  final _specs = <SwiftSpec>[];

  @override
  String get outputFile => options.outputFile;

  SwiftApiBuilder(super.pluginOptions, this.options, this.codecs) {
    _specs.add(SwiftStruct(
      name: 'PlatformError',
      implements: ['Error'],
      fields: [
        SwiftField(name: 'code', type: 'String'),
        SwiftField(name: 'message', type: 'String?'),
        SwiftField(name: 'details', type: 'String?'),
      ],
    ));

    final resultFields = [
      SwiftField(
        visibility: SwiftVisibility.private,
        name: 'result',
        type: 'FlutterResult',
      ),
      SwiftField(
        visibility: SwiftVisibility.private,
        name: 'serializer',
        type: '(T) -> Any?',
      ),
    ];
    _specs.add(SwiftClass(
      name: 'Result<T>',
      fields: resultFields,
      init: SwiftInit(
        parameters:
            resultFields.map((e) => e.toInitParameter(label: '_', annotation: 'escaping')).toList(),
      ),
      methods: [
        SwiftMethod(
          name: 'success',
          parameters: [
            SwiftParameter(label: '_', name: 'data', type: 'T'),
          ],
          lambda: true,
          body: 'result(serializer(data))',
        ),
        SwiftMethod(
          name: 'error',
          parameters: [
            SwiftParameter(label: '_', name: 'code', type: 'String'),
            SwiftParameter(label: '_', name: 'message', type: 'String'),
            SwiftParameter(label: '_', name: 'details', type: 'Any?'),
          ],
          body: 'result(FlutterError(code: code, message: message, details: details))',
        ),
      ],
    ));

    final controllerSinkFields = [
      SwiftField(
        visibility: SwiftVisibility.private,
        name: 'sink',
        type: 'FlutterEventSink',
      ),
      SwiftField(
        visibility: SwiftVisibility.private,
        name: 'serializer',
        type: '(T) -> Any?',
      ),
    ];
    _specs.add(SwiftClass(
      name: 'ControllerSink<T>',
      fields: controllerSinkFields,
      init: SwiftInit(
        parameters: controllerSinkFields
            .map((e) => e.toInitParameter(label: '_', annotation: 'escaping'))
            .toList(),
      ),
      methods: [
        SwiftMethod(
          name: 'success',
          parameters: [
            SwiftParameter(label: '_', name: 'data', type: 'T'),
          ],
          lambda: true,
          body: 'sink(serializer(data))',
        ),
        SwiftMethod(
          name: 'error',
          parameters: [
            SwiftParameter(label: '_', name: 'code', type: 'String'),
            SwiftParameter(label: '_', name: 'message', type: 'String'),
            SwiftParameter(label: '_', name: 'details', type: 'Any?'),
          ],
          body: 'sink(FlutterError(code: code, message: message, details: details))',
        ),
        SwiftMethod(
          name: 'endOfStream',
          lambda: true,
          body: 'sink(FlutterEndOfEventStream)',
        ),
      ],
    ));

    final controllerHandlerFields = [
      SwiftField(
        visibility: SwiftVisibility.private,
        name: '_onListen',
        type: '(_ arguments: Any?, _ events: @escaping FlutterEventSink) -> FlutterError?',
      ),
      SwiftField(
        visibility: SwiftVisibility.private,
        name: '_onCancel',
        type: '(_ arguments: Any?) -> FlutterError?',
      ),
    ];
    _specs.add(SwiftClass(
      name: 'ControllerHandler',
      implements: ['NSObject', 'FlutterStreamHandler'],
      fields: controllerHandlerFields,
      init: SwiftInit(
        parameters: controllerHandlerFields
            .map((e) => e.toInitParameter(label: '_', annotation: 'escaping'))
            .toList(),
      ),
      methods: [
        SwiftMethod(
          name: 'onListen',
          parameters: [
            SwiftParameter(label: 'withArguments', name: 'arguments', type: 'Any?'),
            SwiftParameter(
              label: 'eventSink',
              name: 'events',
              annotation: 'escaping',
              type: 'FlutterEventSink',
            ),
          ],
          returns: 'FlutterError?',
          lambda: true,
          body: '_onListen(arguments, events)',
        ),
        SwiftMethod(
          name: 'onCancel',
          parameters: [SwiftParameter(label: 'withArguments', name: 'arguments', type: 'Any?')],
          returns: 'FlutterError?',
          lambda: true,
          body: '_onCancel(arguments)',
        ),
      ],
    ));
  }

  @override
  void writeHostApiClass(HostApiHandler handler) {
    final HostApiHandler(:element, :methods) = handler;

    _specs.add(SwiftProtocol(
      name: handler.className,
      methods: methods.map((_) {
        final MethodHandler(element: e, :swiftMethodType) = _;
        final returnType = codecs.encodeType(e.returnType.singleTypeArg);

        return SwiftMethod(
          name: _encodeMethodName(e.name),
          parameters: [
            if (swiftMethodType == SwiftMethodType.result)
              SwiftParameter(
                label: '_',
                name: 'result',
                type: 'Result<$returnType>',
              ),
            ...e.parameters.map((e) {
              return SwiftParameter(
                label: '_',
                name: e.name,
                type: codecs.encodeType(e.type),
              );
            }),
          ],
          throws: true,
          async: swiftMethodType == SwiftMethodType.async,
          returns: swiftMethodType == SwiftMethodType.async ? returnType : null,
        );
      }).toList(),
    ));

    _specs.addAll(element.methods.where((e) => e.isHostApiEvent).map((e) {
      final returnType = e.returnType.singleTypeArg;

      final parametersType = e.parameters.map((e) => '_ ${e.name}: ${codecs.encodeType(e.type)}');
      final parameters =
          e.parameters.mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]'));

      return SwiftClass(
        name: handler.controllerName(e),
        init: SwiftInit(
          parameters: [SwiftParameter(name: 'binaryMessenger', type: 'FlutterBinaryMessenger')],
          body:
              'channel = FlutterEventChannel(name: "${handler.controllerChannelName(e)}", binaryMessenger: binaryMessenger)',
        ),
        fields: [
          SwiftField(
            visibility: SwiftVisibility.private,
            name: 'channel',
            type: 'FlutterEventChannel',
          ),
        ],
        methods: [
          SwiftMethod(
            name: 'setHandler',
            parameters: [
              SwiftParameter(
                label: '_',
                name: 'onListen',
                annotation: 'escaping',
                type: '(${[
                  '_ sink: ControllerSink<${codecs.encodeType(returnType)}>',
                  ...parametersType
                ].join(', ')}) -> FlutterError?',
              ),
              SwiftParameter(
                label: '_',
                name: 'onCancel',
                annotation: 'escaping',
                type: '(${parametersType.join(', ')}) -> FlutterError?',
              ),
            ],
            body: '''
channel.setStreamHandler(ControllerHandler({ arguments, events in
    let args = arguments as! [Any?]
    let sink = ControllerSink<${codecs.encodeType(returnType)}>(events) { ${returnType is VoidType ? 'nil' : codecs.encodeSerialization(returnType, '\$0')} }
    return onListen(${['sink', ...parameters].join(', ')})
}, { arguments in
    let args = arguments as! [Any?]
    return onCancel(${parameters.join(', ')})
}))''',
          ),
          SwiftMethod(
            name: 'removeHandler',
            lambda: true,
            body: 'channel.setStreamHandler(nil)',
          ),
        ],
      );
    }));

//     final hostMethods = element.methods.where((e) => e.isHostApiMethod);
//     final hostResultMethods =
//         hostMethods.where((e) => swiftMethodType == SwiftMethodType.result).toList();
//     final hostAsyncMethods =
//         hostMethods.where((e) => swiftMethodType == SwiftMethodType.async).toList();
//
//     String encodeAsyncMethods() {
//       return '''
//     Task {
//         do {
//             let args = call.arguments as! [Any?]
//
//             switch call.method {
//     ${hostAsyncMethods.where((e) => e.isHostApiMethod).map((e) {
//         final returnType = e.returnType.singleTypeArg;
//
//         final parameters =
//             e.parameters.mapIndexed((i, e) => _encodeDeserialization(e.type, 'args[$i]'));
//
//         return '''
//             case "${e.name}":
//                     ${returnType is VoidType ? '' : 'let res = '}try await hostApi.${_encodeMethodName(e.name)}(${parameters.join(', ')})
//                     DispatchQueue.main.async { result(${returnType is VoidType ? 'nil' : _encodeSerialization(returnType, 'res')}) }
//                 ''';
//       }).join('\n')}
//             default:
//                 result(FlutterMethodNotImplemented)
//             }
//         } catch let error as PlatformError {
//             result(FlutterError(code: error.code, message: error.message, details: error.details))
//         } catch {
//             result(FlutterError(code: "", message: error.localizedDescription, details: nil))
//         }
//     }''';
//     }
//
//     String encodeResultMethods() {
//       return '''
//     do {
//         let args = call.arguments as! [Any?]
//
//         switch call.method {
// ${hostResultMethods.map((e) {
//         final returnType = e.returnType.singleTypeArg;
//
//         final parameters =
//             e.parameters.mapIndexed((i, e) => _encodeDeserialization(e.type, 'args[$i]'));
//
//         return '''
//         case "${e.name}":
//             let res = Result<${_encodeType(returnType, true)}>(result) { ${returnType is VoidType ? 'nil' : _encodeSerialization(returnType, '\$0')} }
//             try hostApi.${_encodeMethodName(e.name)}(${['res', ...parameters].join(', ')})''';
//       }).join('\n')}
//         default:
//             result(FlutterMethodNotImplemented)
//         }
//     } catch let error as PlatformError {
//         result(FlutterError(code: error.code, message: error.message, details: error.details))
//     } catch {
//         result(FlutterError(code: "", message: error.localizedDescription, details: nil))
//     }''';
//     }

    _specs.add(SwiftMethod(
      name: 'setup${codecs.encodeName(element.name)}',
      parameters: [
        const SwiftParameter(label: '_', name: 'binaryMessenger', type: 'FlutterBinaryMessenger'),
        SwiftParameter(label: '_', name: 'hostApi', type: handler.className),
      ],
      body: '''
let channel = FlutterMethodChannel(name: "${handler.channelName()}", binaryMessenger: binaryMessenger)
channel.setMethodCallHandler { call, result in

    let runAsync = { (function: @escaping () async throws -> Any?) -> Void in
        Task {
            do {
                let res = try await function()
                DispatchQueue.main.async { result(res) }
            } catch let error as PlatformError {
                DispatchQueue.main.async { result(FlutterError(code: error.code, message: error.message, details: error.details)) }
            } catch {
                DispatchQueue.main.async { result(FlutterError(code: "", message: error.localizedDescription, details: nil)) }
            }
        }
    }

    do {
        let args = call.arguments as! [Any?]
                    
        switch call.method {
${methods.map((_) {
        final MethodHandler(element: e, :swiftMethodType) = _;
        final returnType = e.returnType.singleTypeArg;

        final parameters =
            e.parameters.mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]'));

        return '''
        case "${e.name}":
${switch (swiftMethodType) {
          SwiftMethodType.result => '''
            let res = Result<${codecs.encodeType(returnType)}>(result) { ${returnType is VoidType ? 'nil' : codecs.encodeSerialization(returnType, '\$0')} }
            try hostApi.${_encodeMethodName(e.name)}(${['res', ...parameters].join(', ')})''',
          SwiftMethodType.async => '''
            runAsync {
                ${returnType is VoidType ? '' : 'let res = '}try await hostApi.${_encodeMethodName(e.name)}(${parameters.join(', ')}) 
                return ${returnType is VoidType ? 'nil' : codecs.encodeSerialization(returnType, 'res')}
            }''',
        }}''';
      }).join('\n')}
        default:
            result(FlutterMethodNotImplemented)
        }
    } catch let error as PlatformError {
        result(FlutterError(code: error.code, message: error.message, details: error.details))
    } catch {
        result(FlutterError(code: "", message: error.localizedDescription, details: nil))
    }
}''',
    ));
  }

  @override
  void writeFlutterApiClass(FlutterApiHandler handler) {
    final FlutterApiHandler(:element) = handler;

    _specs.add(SwiftClass(
      name: handler.className,
      fields: const [
        SwiftField(
          name: 'channel',
          type: 'FlutterMethodChannel',
        ),
      ],
      init: SwiftInit(parameters: [
        SwiftParameter(
          label: '_',
          name: 'binaryMessenger',
          type: 'FlutterBinaryMessenger',
        ),
      ], body: '''
channel = FlutterMethodChannel(
    name: "${handler.channelName()}",
    binaryMessenger: binaryMessenger
)'''),
      methods: element.methods.where((e) => e.isFlutterApiMethod).map((e) {
        final returnType = e.returnType.singleTypeArg;

        final parameters =
            e.parameters.map((e) => codecs.encodeSerialization(e.type, e.name)).join(', ');

        return SwiftMethod(
          name: _encodeMethodName(e.name),
          parameters: e.parameters.map((e) {
            return SwiftParameter(
              name: e.name,
              type: codecs.encodeType(e.type),
            );
          }).toList(),
          async: true,
          throws: true,
          returns: returnType is VoidType ? null : codecs.encodeType(returnType),
          body: '''
return try await withCheckedThrowingContinuation { continuation in
    channel.invokeMethod("${handler.channelName(e)}", arguments: ${parameters.isNotEmpty ? '[$parameters]' : 'nil'}) { result in
        if let result = result as? [AnyHashable?: Any?] {
            continuation.resume(throwing: PlatformError(
                code: result["code"] as! String,
                message: result["message"] as? String,
                details: result["details"] as? String
            ))
        } else {
            continuation.resume(returning: ${returnType is VoidType ? '()' : codecs.encodeDeserialization(returnType, 'result')})
        }
    }
}''',
        );
      }).toList(),
    ));
  }

  @override
  void writeSerializableClass(SerializableClassHandler handler) {
    if (!handler.swiftGeneration) return;
    final SerializableClassHandler(:element, :flutterToHost, :hostToFlutter) = handler;
    final fields = element.fields.where((e) => !e.isStatic && e.isFinal && !e.hasInitializer);

    _specs.add(SwiftStruct(
      name: codecs.encodeName(element.name),
      fields: fields.map((e) {
        return SwiftField(
          name: _encodeVarName(e.name),
          type: codecs.encodeType(e.type),
        );
      }).toList(),
      methods: [
        if (hostToFlutter)
          SwiftMethod(
            name: 'serialize',
            returns: '[Any?]',
            body: 'return [\n${fields.map((e) {
              return '    ${codecs.encodeSerialization(e.type, _encodeVarName(e.name))},\n';
            }).join()}]',
          ),
        if (flutterToHost)
          SwiftMethod(
            modifier: SwiftMethodModifier.static,
            name: 'deserialize',
            parameters: [
              const SwiftParameter(
                label: '_',
                name: 'serialized',
                type: '[Any?]',
              ),
            ],
            returns: codecs.encodeType(element.thisType),
            body: 'return ${codecs.encodeName(element.name)}(\n${fields.mapIndexed((i, e) {
              return '    ${_encodeVarName(e.name)}: ${codecs.encodeDeserialization(e.type, 'serialized[$i]')}';
            }).join(',\n')}\n)',
          ),
      ],
    ));
  }

  @override
  void writeSerializableEnum(SerializableEnumHandler handler) {
    final SerializableEnumHandler(:element) = handler;

    _specs.add(SwiftEnum(
      name: codecs.encodeName(element.name),
      implements: [
        switch (handler.type) {
          SerializableEnumType.int => 'Int',
          SerializableEnumType.string => 'String',
        },
      ],
      values: element.fields.where((element) => element.isEnumConstant).map((e) {
        return _encodeVarName(e.name);
      }).toList(),
    ));
  }

  String _encodeMethodName(String name) =>
      name.startsWith('_on') ? name.replaceFirst('_on', '').camelCase : 'on${name.pascalCase}';

  String _encodeVarName(String name) => name;

  // String _encodeType(DartType type, bool withNullability) {
  //   final questionOrEmpty = withNullability ? type.questionOrEmpty : '';
  //   final codec = pluginOptions.findCodec(PlatformApi.kotlin, type);
  //   if (codec != null) {
  //     return codec.encodeType(type);
  //   }
  //   if (type.isDartCoreObject || type is DynamicType) return 'Any$questionOrEmpty';
  //   if (type is VoidType) return 'Void$questionOrEmpty';
  //   if (type.isDartCoreNull) return 'nil$questionOrEmpty';
  //   if (type.isDartCoreBool) return 'Bool$questionOrEmpty';
  //   if (type.isDartCoreInt) return 'Int$questionOrEmpty';
  //   if (type.isDartCoreDouble) return 'Double$questionOrEmpty';
  //   if (type.isDartCoreString) return 'String$questionOrEmpty';
  //   if (type.isDartCoreList) {
  //     final typeArg = type.singleTypeArg;
  //     return '[${_encodeType(typeArg, withNullability)}]$questionOrEmpty';
  //   }
  //   if (type.isDartCoreMap) {
  //     final typeArgs = type.doubleTypeArgs;
  //     return '[${_encodeType(typeArgs.$1, withNullability)}: ${_encodeType(typeArgs.$2, withNullability)}]$questionOrEmpty';
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
  //     final deserializer = codec.encodeSerialization(type, varAccess);
  //     return type.isNullable ? '$varAccess != nil ? $deserializer : nil' : deserializer;
  //   }
  //   if (type.isPrimitive) return varAccess;
  //   if (type.isDartCoreList) {
  //     final typeArg = type.singleTypeArg;
  //     return '$varAccess${type.questionOrEmpty}.map { ${_encodeSerialization(typeArg, '\$0')} }';
  //   }
  //   if (type.isDartCoreMap) {
  //     final typesArgs = type.doubleTypeArgs;
  //     return _encodeTernaryOperator(
  //       type,
  //       varAccess,
  //       'Dictionary(uniqueKeysWithValues: $varAccess${type.exclamationOrEmpty}.map { k, v in '
  //       '(${_encodeSerialization(typesArgs.$1, 'k')}, ${_encodeSerialization(typesArgs.$2, 'v')}) })',
  //     );
  //   }
  //   if (type.isDartCoreEnum || type.element is EnumElement) {
  //     return '$varAccess${type.questionOrEmpty}.rawValue';
  //   }
  //   return '$varAccess${type.questionOrEmpty}.serialize()';
  // }
  //
  // String _encodeDeserialization(DartType type, String varAccess) {
  //   if (type is VoidType) throw StateError('void type no supported');
  //   final codec = pluginOptions.findCodec(PlatformApi.kotlin, type);
  //   if (codec != null) {
  //     final deserializer = codec.encodeDeserialization(type, varAccess);
  //     return type.isNullable ? '$varAccess != null ? $deserializer : nil' : deserializer;
  //   }
  //   if (type.isPrimitive) {
  //     return '$varAccess as${type.questionOrExclamation} ${_encodeType(type, false)}';
  //   }
  //   if (type.isDartCoreList) {
  //     final typeArg = type.singleTypeArg;
  //     return '($varAccess as${type.questionOrExclamation} [Any?])'
  //         '${type.questionOrEmpty}.map { ${_encodeDeserialization(typeArg, '\$0')} }';
  //   }
  //
  //   String encodeDeserializer() {
  //     if (type.isDartCoreMap) {
  //       final typesArgs = type.doubleTypeArgs;
  //       return 'Dictionary(uniqueKeysWithValues: ($varAccess as! [AnyHashable: Any])'
  //           '.map { k, v in (${_encodeDeserialization(typesArgs.$1, 'k')}, ${_encodeDeserialization(typesArgs.$2, 'v')}) })';
  //     }
  //     if (type.isDartCoreEnum || type.element is EnumElement) {
  //       return '${_encodeType(type, false)}(rawValue: $varAccess as! Int)!';
  //     }
  //     return '${_encodeType(type, false)}.deserialize($varAccess as! [Any?])';
  //   }
  //
  //   return _encodeTernaryOperator(type, varAccess, encodeDeserializer());
  // }
  //
  // String _encodeTernaryOperator(DartType type, String varAccess, String exsist) =>
  //     type.isNullable ? '$varAccess != nil ? $exsist : nil' : exsist;

  @override
  String build() => '${SwiftEmitter().encode(SwiftLibrary(
        imports: [
          'Flutter',
        ],
        body: _specs,
      ))}';

  @override
  void writeException(EnumElement element) {
    // TODO: implement writeException
  }
}

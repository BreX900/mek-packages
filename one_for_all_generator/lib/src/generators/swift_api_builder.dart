import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';
import 'package:one_for_all_generator/src/emitters/swift_emitter.dart';
import 'package:one_for_all_generator/src/handlers.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:one_for_all_generator/src/utils.dart';
import 'package:recase/recase.dart';

class SwiftApiBuilder extends ApiBuilder {
  final SwiftOptions options;
  final ApiCodecs codecs;
  final _specs = <SwiftTopLevelSpec>[];

  @override
  String get outputFile => options.outputFile;

  SwiftApiBuilder(super.pluginOptions, this.options, this.codecs) {
    const requiredPlatformErrorField = SwiftField(name: 'code', type: 'String');
    const optionalPlatformErrorFields = [
      SwiftField(name: 'message', type: 'String?'),
      SwiftField(name: 'details', type: 'Any?'),
    ];
    _specs.add(SwiftClass(
      name: 'PlatformError',
      implements: ['Error'],
      fields: [
        requiredPlatformErrorField,
        ...optionalPlatformErrorFields,
      ],
      init: SwiftInit(
        parameters: [
          requiredPlatformErrorField.toInitParameter(label: '_'),
          ...optionalPlatformErrorFields
              .map((e) => e.toInitParameter(label: '_', defaultTo: 'nil')),
        ],
      ),
      methods: const [
        SwiftMethod(
          name: 'toFlutterError',
          returns: 'FlutterError',
          lambda: true,
          body: 'FlutterError(code: code, message: message, details: details)',
        )
      ],
    ));

    const resultFields = [
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
      methods: const [
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
            SwiftParameter(label: '_', name: 'error', type: 'PlatformError'),
          ],
          body: 'result(error.toFlutterError())',
        ),
      ],
    ));

    const controllerSinkFields = [
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
      methods: const [
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
            SwiftParameter(label: '_', name: 'error', type: 'PlatformError'),
          ],
          body: 'sink(error.toFlutterError())',
        ),
        SwiftMethod(
          name: 'endOfStream',
          lambda: true,
          body: 'sink(FlutterEndOfEventStream)',
        ),
      ],
    ));

    const controllerHandlerFields = [
      SwiftField(
        visibility: SwiftVisibility.private,
        name: '_onListen',
        type: '(_ arguments: Any?, _ events: @escaping FlutterEventSink) -> PlatformError?',
      ),
      SwiftField(
        visibility: SwiftVisibility.private,
        name: '_onCancel',
        type: '(_ arguments: Any?) -> PlatformError?',
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
        const SwiftMethod(
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
          body: '_onListen(arguments, events)?.toFlutterError()',
        ),
        const SwiftMethod(
          name: 'onCancel',
          parameters: [SwiftParameter(label: 'withArguments', name: 'arguments', type: 'Any?')],
          returns: 'FlutterError?',
          lambda: true,
          body: '_onCancel(arguments)?.toFlutterError()',
        ),
      ],
    ));
  }

  @override
  void writeHostApiClass(HostApiHandler handler) {
    final HostApiHandler(:element, swiftMethods: methods) = handler;

    _specs.add(SwiftProtocol(
      name: codecs.encodeName(element.displayName),
      methods: methods.map((_) {
        final MethodHandler(element: e, swift: methodType) = _;
        final returnType = codecs.encodeType(e.returnType.singleTypeArg);

        return SwiftMethod(
          name: _encodeMethodName(e.displayName),
          parameters: [
            if (methodType == MethodApiType.callbacks)
              SwiftParameter(
                label: '_',
                name: 'result',
                type: 'Result<$returnType>',
              ),
            ...e.formalParameters.map((e) {
              return SwiftParameter(
                label: '_',
                name: e.displayName,
                type: codecs.encodeType(e.type),
              );
            }),
          ],
          throws: true,
          async: methodType == MethodApiType.async,
          returns: methodType == MethodApiType.callbacks ? null : returnType,
        );
      }).toList(),
    ));

    _specs.addAll(element.methods2.where((e) => e.isHostApiEvent).map((e) {
      final returnType = e.returnType.singleTypeArg;

      final parametersType =
          e.formalParameters.map((e) => '_ ${e.displayName}: ${codecs.encodeType(e.type)}');
      final parameters =
          e.formalParameters.mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]'));

      return SwiftClass(
        name: codecs.encodeName('${e.displayName}Controller'),
        init: SwiftInit(
          parameters: [
            const SwiftParameter(name: 'binaryMessenger', type: 'FlutterBinaryMessenger')
          ],
          body:
              'channel = FlutterEventChannel(name: "${handler.eventChannelName(e)}", binaryMessenger: binaryMessenger)',
        ),
        fields: [
          const SwiftField(
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
                ].join(', ')}) -> PlatformError?',
              ),
              SwiftParameter(
                label: '_',
                name: 'onCancel',
                annotation: 'escaping',
                type: '(${parametersType.join(', ')}) -> PlatformError?',
              ),
            ],
            body: '''
channel.setStreamHandler(ControllerHandler({ arguments, events in
    let args = arguments as! [Any?]
    let sink = ControllerSink<${codecs.encodeType(returnType)}>(events) { ${returnType is VoidType ? 'nil' : codecs.encodeSerialization(returnType, r'$0')} }
    return onListen(${['sink', ...parameters].join(', ')})
}, { arguments in
    let args = arguments as! [Any?]
    return onCancel(${parameters.join(', ')})
}))''',
          ),
          const SwiftMethod(
            name: 'removeHandler',
            lambda: true,
            body: 'channel.setStreamHandler(nil)',
          ),
        ],
      );
    }));

    final channelVarAccess = 'channel${codecs.encodeName(element.displayName)}';
    _specs.add(SwiftField(
      visibility: SwiftVisibility.private,
      modifier: SwiftFieldModifier.var$,
      name: channelVarAccess,
      type: 'FlutterMethodChannel?',
      assignment: 'nil',
    ));
    _specs.add(SwiftMethod(
      name: 'set${codecs.encodeName(element.displayName)}Handler',
      parameters: [
        const SwiftParameter(label: '_', name: 'binaryMessenger', type: 'FlutterBinaryMessenger'),
        SwiftParameter(label: '_', name: 'hostApi', type: codecs.encodeName(element.displayName)),
      ],
      body: '''
$channelVarAccess = FlutterMethodChannel(name: "${handler.methodChannelName()}", binaryMessenger: binaryMessenger)
$channelVarAccess!.setMethodCallHandler { call, result in
    let runAsync = { (function: @escaping () async throws -> Any?) -> Void in
        Task {
            do {
                let res = try await function()
                DispatchQueue.main.async { result(res) }
            } catch let error as PlatformError {
                DispatchQueue.main.async { result(error.toFlutterError()) }
            } catch {
                DispatchQueue.main.async { result(FlutterError(code: "", message: error.localizedDescription, details: nil)) }
            }
        }
    }

    do {
        let args = call.arguments as! [Any?]
                    
        switch call.method {
${methods.map((_) {
        final MethodHandler(element: e, swift: methodType) = _;
        final returnType = e.returnType.singleTypeArg;

        final parameters = e.formalParameters
            .mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]'));

        return '''
        case "${e.displayName}":
${switch (methodType) {
          MethodApiType.callbacks => '''
            let res = Result<${codecs.encodeType(returnType)}>(result) { ${returnType is VoidType ? 'nil' : codecs.encodeSerialization(returnType, r'$0')} }
            try hostApi.${_encodeMethodName(e.displayName)}(${[
              'res',
              ...parameters
            ].join(', ')})''',
          MethodApiType.sync => '''
            let res = try hostApi.${_encodeMethodName(e.displayName)}(${parameters.join(', ')})
            result(${returnType is VoidType ? 'nil' : codecs.encodeSerialization(returnType, 'res')})''',
          MethodApiType.async => '''
            runAsync {
                ${returnType is VoidType ? '' : 'let res = '}try await hostApi.${_encodeMethodName(e.displayName)}(${parameters.join(', ')})
                return ${returnType is VoidType ? 'nil' : codecs.encodeSerialization(returnType, 'res')}
            }''',
        }}''';
      }).join('\n')}
        default:
            result(FlutterMethodNotImplemented)
        }
    } catch let error as PlatformError {
        result(error.toFlutterError())
    } catch {
        result(FlutterError(code: "", message: error.localizedDescription, details: nil))
    }
}''',
    ));
    _specs.add(SwiftMethod(
      name: 'remove${codecs.encodeName(element.displayName)}Handler',
      body: '$channelVarAccess?.setMethodCallHandler(nil)',
    ));
  }

  @override
  void writeFlutterApiClass(FlutterApiHandler handler) {
    final FlutterApiHandler(:element, swiftMethods: methods) = handler;

    _specs.add(SwiftClass(
      name: codecs.encodeName(element.displayName),
      fields: const [
        SwiftField(
          name: 'channel',
          type: 'FlutterMethodChannel',
        ),
      ],
      init: SwiftInit(parameters: [
        const SwiftParameter(
          label: '_',
          name: 'binaryMessenger',
          type: 'FlutterBinaryMessenger',
        ),
      ], body: '''
channel = FlutterMethodChannel(
    name: "${handler.methodChannelName()}",
    binaryMessenger: binaryMessenger
)'''),
      methods: methods.map((_) {
        final MethodHandler(element: e, swift: methodType) = _;
        final returnType = e.returnType.thisOrSingleTypeArg;

        final parameters = e.formalParameters
            .map((e) => codecs.encodeSerialization(e.type, e.displayName))
            .join(', ');

        return SwiftMethod(
          name: _encodeMethodName(e.displayName),
          parameters: e.formalParameters.map((e) {
            return SwiftParameter(
              name: e.displayName,
              type: codecs.encodeType(e.type),
            );
          }).toList(),
          async: methodType == MethodApiType.async,
          throws: methodType == MethodApiType.async,
          returns: methodType == MethodApiType.async
              ? (returnType is VoidType ? null : codecs.encodeType(returnType))
              : null,
          body: switch (methodType) {
            MethodApiType.callbacks => throw UnsupportedError(
                'Not supported method ${MethodApiType.callbacks} on ${element.displayName}.${e.displayName}'),
            MethodApiType.sync => '''
channel.invokeMethod("${handler.methodChannelName(e)}", arguments: [$parameters])''',
            MethodApiType.async => '''
return try await withCheckedThrowingContinuation { continuation in
    DispatchQueue.main.async {
        self.channel.invokeMethod("${handler.methodChannelName(e)}", arguments: [$parameters]) { result in
            if let result = result as? FlutterError {
                continuation.resume(throwing: PlatformError(result.code, result.message, result.details))
            } else {
                continuation.resume(returning: ${returnType is VoidType ? '()' : codecs.encodeDeserialization(returnType, 'result')})
            }
        }
    }
}''',
          },
        );
      }).toList(),
    ));
  }

  @override
  void writeSerializableClass(SerializableClassHandler handler, {ClassElement2? extend}) {
    if (!handler.swiftGeneration) return;
    final SerializableClassHandler(:element, :flutterToHost, :hostToFlutter, :params, :children) =
        handler;

    if (children != null) {
      _specs.add(SwiftProtocol(
        name: codecs.encodeName(element.displayName),
      ));
      if (flutterToHost) {
        _specs.add(SwiftMethod(
          name: 'deserialize${codecs.encodeName(element.displayName)}',
          parameters: [
            const SwiftParameter(
              label: '_',
              name: 'serialized',
              type: '[Any?]',
            ),
          ],
          returns: codecs.encodeType(element.thisType),
          body: 'switch serialized[0] as! String {\n'
              '${children.map((h) {
            return 'case "${h.element.displayName}":\n'
                '    return ${codecs.encodeName(h.element.displayName)}.deserialize(Array(serialized.dropFirst()))\n';
          }).join()}'
              'default:\n'
              '    fatalError()\n'
              '}',
        ));
      }
      for (final child in children) {
        writeSerializableClass(child, extend: element);
      }
      return;
    }

    _specs.add(SwiftStruct(
      name: codecs.encodeName(element.displayName),
      implements: [if (extend != null) codecs.encodeName(extend.displayName)],
      fields: params.map((e) {
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
            body: 'return [\n${params.map((e) {
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
            body: 'return ${codecs.encodeName(element.displayName)}(\n${params.mapIndexed((i, e) {
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
      name: codecs.encodeName(element.displayName),
      implements: [
        switch (handler.type) {
          SerializableEnumType.int => 'Int',
          SerializableEnumType.string => 'String',
        },
      ],
      values: element.fields2.where((element) => element.isEnumConstant).map((e) {
        return _encodeVarName(e.displayName);
      }).toList(),
    ));
  }

  String _encodeMethodName(String name) {
    name = name.replaceFirst('_', '');
    return name.startsWith('on') ? name.replaceFirst('on', '').camelCase : 'on${name.pascalCase}';
  }

  String _encodeVarName(String name) => name;

  @override
  String build() => '${SwiftEmitter().encode(SwiftLibrary(
        comments: const [generatedCodeComment],
        imports: const [
          'Flutter',
        ],
        body: _specs,
      ))}';

  @override
  void writeException(EnumElement2 element) {
    // TODO: implement writeException
  }
}

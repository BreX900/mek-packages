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
  final _specs = <SwiftTopLevelSpec>[];

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
    final HostApiHandler(:element, swiftMethods: methods) = handler;

    _specs.add(SwiftProtocol(
      name: codecs.encodeName(element.name),
      methods: methods.map((_) {
        final MethodHandler(element: e, swift: methodType) = _;
        final returnType = codecs.encodeType(e.returnType.singleTypeArg);

        return SwiftMethod(
          name: _encodeMethodName(e.name),
          parameters: [
            if (methodType == MethodApiType.callbacks)
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
          async: methodType == MethodApiType.async,
          returns: methodType == MethodApiType.callbacks ? null : returnType,
        );
      }).toList(),
    ));

    _specs.addAll(element.methods.where((e) => e.isHostApiEvent).map((e) {
      final returnType = e.returnType.singleTypeArg;

      final parametersType = e.parameters.map((e) => '_ ${e.name}: ${codecs.encodeType(e.type)}');
      final parameters =
          e.parameters.mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]'));

      return SwiftClass(
        name: codecs.encodeName('${e.name}Controller'),
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

    _specs.add(SwiftMethod(
      name: 'setup${codecs.encodeName(element.name)}',
      parameters: [
        const SwiftParameter(label: '_', name: 'binaryMessenger', type: 'FlutterBinaryMessenger'),
        SwiftParameter(label: '_', name: 'hostApi', type: codecs.encodeName(element.name)),
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
        final MethodHandler(element: e, swift: methodType) = _;
        final returnType = e.returnType.singleTypeArg;

        final parameters =
            e.parameters.mapIndexed((i, e) => codecs.encodeDeserialization(e.type, 'args[$i]'));

        return '''
        case "${e.name}":
${switch (methodType) {
          MethodApiType.callbacks => '''
            let res = Result<${codecs.encodeType(returnType)}>(result) { ${returnType is VoidType ? 'nil' : codecs.encodeSerialization(returnType, '\$0')} }
            try hostApi.${_encodeMethodName(e.name)}(${['res', ...parameters].join(', ')})''',
          MethodApiType.sync => '''
            let res = try hostApi.${_encodeMethodName(e.name)}(${['res', ...parameters].join(', ')})
            result(${returnType is VoidType ? 'nil' : codecs.encodeSerialization(returnType, 'res')})''',
          MethodApiType.async => '''
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
    final FlutterApiHandler(:element, swiftMethods: methods) = handler;

    _specs.add(SwiftClass(
      name: codecs.encodeName(element.name),
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
      methods: methods.map((_) {
        final MethodHandler(element: e, swift: methodType) = _;
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
          async: methodType == MethodApiType.async,
          throws: methodType == MethodApiType.async,
          returns: methodType == MethodApiType.async
              ? (returnType is VoidType ? null : codecs.encodeType(returnType))
              : null,
          body: switch (methodType) {
            MethodApiType.callbacks => throw UnsupportedError(
                'Not supported method ${MethodApiType.callbacks} on ${element.name}.${e.name}'),
            MethodApiType.sync => '''
channel.invokeMethod("${handler.channelName(e)}", arguments: ${parameters.isNotEmpty ? '[$parameters]' : 'nil'})''',
            MethodApiType.async => '''
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
          },
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

  String _encodeMethodName(String name) {
    name = name.replaceFirst('_', '');
    return name.startsWith('on') ? name.replaceFirst('on', '').camelCase : 'on${name.pascalCase}';
  }

  String _encodeVarName(String name) => name;

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

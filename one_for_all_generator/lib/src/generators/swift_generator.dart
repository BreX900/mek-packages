import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:one_for_all_generator/src/code_generator.dart';
import 'package:one_for_all_generator/src/emitters/swift_emitter.dart';
import 'package:one_for_all_generator/src/handlers/api_class_handler.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:recase/recase.dart';

class SwiftGenerator extends CodeGenerator with WriteToOutputFile {
  final SwiftOptions options;
  final _specs = <SwiftSpec>[];

  @override
  String get outputFile => options.outputFile;

  SwiftGenerator(super.pluginOptions, this.options) {
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
        parameters: resultFields.map((e) {
          return e.toParameter(label: '_', annotation: 'escaping');
        }).toList(),
      ),
      methods: [
        SwiftMethod(
          name: 'success',
          parameters: [
            SwiftParameter(label: '_', name: 'data', type: 'T'),
          ],
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
  }

  @override
  void writeHostApiClass(ApiClassHandler handler) {
    final ApiClassHandler(:element) = handler;

    final className = '${element.name}HostApi';

    _specs.add(SwiftProtocol(
      name: className,
      methods: element.methods.where((e) => e.isHostMethod).map((e) {
        final returnType = e.returnType.singleTypeArg;

        return SwiftMethod(
          name: _encodeMethodName(e.name),
          parameters: [
            SwiftParameter(
              label: '_',
              name: 'result',
              type: 'Result<${_encodeType(returnType, true)}>',
            ),
            ...e.parameters.map((e) {
              return SwiftParameter(
                label: '_',
                name: e.name,
                type: _encodeType(e.type, true),
              );
            }),
          ],
        );
      }).toList(),
    ));
    _specs.add(SwiftMethod(
      name: 'setup${_encodeType(element.thisType, false)}',
      parameters: [
        const SwiftParameter(label: '_', name: 'binaryMessenger', type: 'FlutterBinaryMessenger'),
        SwiftParameter(label: '_', name: 'hostApi', type: className),
      ],
      body: '''
let channel = FlutterMethodChannel(name: "${element.name.snakeCase}", binaryMessenger: binaryMessenger)
channel.setMethodCallHandler { call, result in
    do {
        let args = call.arguments as! [Any?]
                    
        switch call.method {
        ${element.methods.where((e) => e.isHostMethod).map((e) {
        final returnType = e.returnType.singleTypeArg;

        final parameters =
            e.parameters.mapIndexed((i, e) => _encodeDeserialization(e.type, 'args[$i]'));

        return '''
        case "${e.name}":
          let res = Result<${_encodeType(returnType, true)}>(result: result) { \$0.serialize() }
          hostApi.${_encodeMethodName(e.name)}(${['res', ...parameters].join(', ')})''';
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

//     _specs.add(SwiftClass(
//       name: _encodeType(element.thisType, false),
//       fields: const [
//         SwiftField(
//           name: 'channel',
//           type: 'MethodChannel',
//         ),
//       ],
//       init: SwiftInit(parameters: [
//         SwiftParameter(
//           label: '_',
//           name: 'binaryMessenger',
//           type: 'FlutterBinaryMessenger',
//         ),
//       ], body: '''
// channel = FlutterMethodChannel(
//     name: ${element.name.snakeCase},
//     binaryMessenger: binaryMessenger
// )'''),
//       methods: element.methods.where((e) => e.isFlutterMethod).map((e) {
//         final returnType = e.returnType.singleTypeArg;
//
//         final parameters = e.parameters.map((e) => _encodeSerialization(e.type, e.name)).join(', ');
//
//         return SwiftMethod(
//           name: _encodeMethodName(e.name),
//           parameters: e.parameters.map((e) {
//             return SwiftParameter(
//               name: e.name,
//               type: _encodeType(e.type, true),
//             );
//           }).toList(),
//           async: true,
//           throws: true,
//           returnType: returnType is VoidType ? null : _encodeType(returnType, true),
//           body: '''
// return try await withCheckedThrowingContinuation { continuation in
//     channel.invokeMethod(
//         "${e.name}",
//         [$parameters],
//         object : MethodChannel.Result {
//             override fun success(result: Any?) {
//                 continuation.resume(${returnType is VoidType ? 'Unit' : _encodeDeserialization(returnType, 'result')})
//             }
//             override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
//                 continuation.resumeWithException(PlatformException(errorCode, errorMessage, errorDetails))
//             }
//             override fun notImplemented() {}
//         }
//     )
// }''',
//         );
//       }).toList(),
//     ));
  }

  @override
  void writeDataClass(ClassElement element) {
    final fields = element.fields.where((e) => !e.isStatic && e.isFinal && !e.hasInitializer);

    _specs.add(SwiftStruct(
      name: _encodeType(element.thisType, false),
      fields: fields.map((e) {
        return SwiftField(
          name: _encodeVarName(e.name),
          type: _encodeType(e.type, true),
        );
      }).toList(),
      methods: [
        SwiftMethod(
          name: 'serialize',
          returnType: '[Any?]',
          body: 'return [\n${fields.map((e) {
            return '    ${_encodeSerialization(e.type, _encodeVarName(e.name))},\n';
          }).join()}]',
        ),
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
          returnType: _encodeType(element.thisType, true),
          body: 'return ${_encodeType(element.thisType, false)}(\n${fields.mapIndexed((i, e) {
            return '    ${_encodeVarName(e.name)}: ${_encodeDeserialization(e.type, 'serialized[$i]')}';
          }).join(',\n')}\n)',
        ),
      ],
    ));
  }

  @override
  void writeEnum(EnumElement element) {
    _specs.add(SwiftEnum(
      name: _encodeType(element.thisType, false),
      implements: ['Int'],
      values: element.fields.where((element) => element.isEnumConstant).map((e) {
        return _encodeVarName(e.name);
      }).toList(),
    ));
  }

  String _encodeMethodName(String name) =>
      name.startsWith('_on') ? name.replaceFirst('_on', '').camelCase : 'on${name.pascalCase}';

  String _encodeVarName(String name) => name;

  String _encodeType(DartType type, bool withNullability) {
    final questionOrEmpty = withNullability ? type.questionOrEmpty : '';
    if (type.isDartCoreObject || type is DynamicType) return 'Any$questionOrEmpty';
    if (type is VoidType) return 'Unit$questionOrEmpty';
    if (type.isDartCoreNull) return 'nil$questionOrEmpty';
    if (type.isDartCoreBool) return 'Bool$questionOrEmpty';
    if (type.isDartCoreInt) return 'Int$questionOrEmpty';
    if (type.isDartCoreDouble) return 'Double$questionOrEmpty';
    if (type.isDartCoreString) return 'String$questionOrEmpty';
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '[${_encodeType(typeArg, withNullability)}]$questionOrEmpty';
    }
    if (type.isDartCoreMap) {
      final typeArgs = type.doubleTypeArgs;
      return '[${_encodeType(typeArgs.$1, withNullability)}: ${_encodeType(typeArgs.$2, withNullability)}]$questionOrEmpty';
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
      return '$varAccess${type.questionOrEmpty}.map { ${_encodeSerialization(typeArg, '\$0')} }';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      return _encodeTernaryOperator(
        type,
        varAccess,
        'Dictionary(uniqueKeysWithValues: $varAccess${type.exclamationOrEmpty}.map { k, v in '
        '(${_encodeSerialization(typesArgs.$1, 'k')}, ${_encodeSerialization(typesArgs.$2, 'v')}) })',
      );
    }
    if (type.isDartCoreEnum || type.element is EnumElement) {
      return '$varAccess${type.questionOrEmpty}.rawValue';
    }
    return '$varAccess${type.questionOrEmpty}.serialize()';
  }

  String _encodeDeserialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('void type no supported');
    if (type.isPrimitive) {
      return '$varAccess as${type.questionOrExclamation} ${_encodeType(type, false)}';
    }
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '($varAccess as${type.questionOrExclamation} [Any?])'
          '${type.questionOrEmpty}.map { ${_encodeDeserialization(typeArg, '\$0')} }';
    }

    String encodeDeserializer() {
      if (type.isDartCoreMap) {
        final typesArgs = type.doubleTypeArgs;
        return 'Dictionary(uniqueKeysWithValues: ($varAccess as! [AnyHashable: Any])'
            '.map { k, v in (${_encodeDeserialization(typesArgs.$1, 'k')}, ${_encodeDeserialization(typesArgs.$2, 'v')}) })';
      }
      if (type.isDartCoreEnum || type.element is EnumElement) {
        return '${_encodeType(type, false)}(rawValue: $varAccess as! Int)!';
      }
      return '${_encodeType(type, false)}.deserialize($varAccess as! [Any?])';
    }

    return _encodeTernaryOperator(type, varAccess, encodeDeserializer());
  }

  String _encodeTernaryOperator(DartType type, String varAccess, String exsist) =>
      type.isNullable ? '$varAccess != nil ? $exsist : nil' : exsist;

  @override
  String toString() => '${SwiftEmitter().encode(SwiftLibrary(
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

extension on DartType {
  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;
  String get questionOrEmpty => isNullable ? '?' : '';
  String get questionOrExclamation => isNullable ? '?' : '!';
  String get exclamationOrEmpty => isNullable ? '!' : '';
}

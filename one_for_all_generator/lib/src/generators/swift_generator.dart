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
    // _specs.add(SwiftClass(
    //   name: 'PlatformException',
    //   fields: [
    //     SwiftField(name: 'code', type: 'String'),
    //     SwiftParameter(name: 'message', type: 'String?'),
    //     SwiftField(name: 'details', type: 'Any?'),
    //   ],
    //   superTypes: ['RuntimeException(message ?: code)'],
    // ));
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
          body: 'result.success(serializer(data))',
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
    // final ApiClassHandler(:element, :hostExceptionElement) = handler;
//     _specs.add(KotlinClass(
//       modifier: KotlinClassModifier.abstract,
//       name: _encodeType(element.thisType, false),
//       superTypes: ['FlutterPlugin', 'MethodChannel.MethodCallHandler'],
//       fields: const [
//         KotlinField(
//           modifier: KotlinFieldModifier.lateInit,
//           name: 'channel',
//           type: 'MethodChannel',
//         ),
//       ],
//       methods: [
//         ...element.methods.where((e) => e.isFlutterMethod).map((e) {
//           final returnType = e.returnType.singleTypeArg;
//
//           final parameters =
//               e.parameters.map((e) => _encodeSerialization(e.type, e.name)).join(', ');
//
//           return KotlinMethod(
//             modifiers: {KotlinMethodModifier.suspend},
//             name: _encodeMethodName(e.name),
//             parameters: e.parameters.map((e) {
//               return KotlinParameter(
//                 name: e.name,
//                 type: _encodeType(e.type, true),
//               );
//             }).toList(),
//             returnType: returnType is VoidType ? null : _encodeType(returnType, true),
//             body: '''
// return suspendCoroutine { continuation ->
//     channel.invokeMethod(
//         "${e.name}",
//         listOf<Any?>($parameters),
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
//           );
//         }),
//         ...element.methods.where((e) => e.isHostMethod).map((e) {
//           final returnType = e.returnType.singleTypeArg;
//
//           return KotlinMethod(
//             name: _encodeMethodName(e.name),
//             parameters: [
//               // if (returnType is! VoidType)
//               KotlinParameter(
//                 name: 'result',
//                 type: 'Result<${_encodeType(returnType, true)}>',
//               ),
//               ...e.parameters.map((e) {
//                 return KotlinParameter(
//                   name: e.name,
//                   type: _encodeType(e.type, true),
//                 );
//               }),
//             ],
//           );
//         }),
//         KotlinMethod(
//           modifiers: {KotlinMethodModifier.override},
//           name: 'onMethodCall',
//           parameters: const [
//             KotlinParameter(annotations: ['NonNull'], name: 'call', type: 'MethodCall'),
//             KotlinParameter(annotations: ['NonNull'], name: 'result', type: 'MethodChannel.Result'),
//           ],
//           body: 'val args = call.arguments<List<Any?>>()!!\n'
//               'when (call.method) {\n${element.methods.where((e) => e.isHostMethod).map((e) {
//             final returnType = e.returnType.singleTypeArg;
//
//             final parameters =
//                 e.parameters.mapIndexed((i, e) => _encodeDeserialization(e.type, 'args[$i]'));
//
//             return '''
//     "${e.name}" -> {
//         val res = Result<${_encodeType(returnType, true)}>(result) {${returnType is VoidType ? 'null' : _encodeSerialization(returnType, 'it')}}
//         ${_encodeMethodName(e.name)}(${['res', ...parameters].join(', ')})
//     }''';
//           }).join('\n')}\n}',
//         ),
//         KotlinMethod(
//           modifiers: {KotlinMethodModifier.override},
//           name: 'onAttachedToEngine',
//           parameters: const [
//             KotlinParameter(
//               annotations: ['NonNull'],
//               name: 'flutterPluginBinding',
//               type: 'FlutterPlugin.FlutterPluginBinding',
//             ),
//           ],
//           body:
//               'channel = MethodChannel(flutterPluginBinding.binaryMessenger, "${element.name.snakeCase}")\n'
//               'channel.setMethodCallHandler(this)',
//         ),
//         const KotlinMethod(
//           modifiers: {KotlinMethodModifier.override},
//           name: 'onDetachedFromEngine',
//           parameters: [
//             KotlinParameter(
//               annotations: ['NonNull'],
//               name: 'flutterPluginBinding',
//               type: 'FlutterPlugin.FlutterPluginBinding',
//             ),
//           ],
//           body: 'channel.setMethodCallHandler(null)',
//         ),
//       ],
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
          returnType: 'Array<Any?>',
          body: 'return [\n${fields.map((e) {
            return '    ${_encodeSerialization(e.type, _encodeVarName(e.name))},\n';
          }).join()}]',
        ),
        SwiftMethod(
          static: true,
          name: 'deserialize',
          parameters: [
            const SwiftParameter(
              label: '_',
              name: 'serialized',
              type: 'Array<Any?>',
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
      return 'Array<${_encodeType(typeArg, withNullability)}>$questionOrEmpty';
    }
    if (type.isDartCoreMap) {
      final typeArgs = type.doubleTypeArgs;
      return 'Dictionary<${_encodeType(typeArgs.$1, withNullability)}, ${_encodeType(typeArgs.$2, withNullability)}>$questionOrEmpty';
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
      return '$varAccess${type.questionOrEmpty}.map{${_encodeSerialization(typeArg, '\$0')}}';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      return _encodeTernaryOperator(
        type,
        varAccess,
        'Dictionary(uniqueKeysWithValues: $varAccess${type.exclamationOrEmpty}.map{ k, v in '
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
      return '($varAccess as${type.questionOrExclamation} Array<Any?>)'
          '${type.questionOrEmpty}.map{${_encodeDeserialization(typeArg, '\$0')}}';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      return _encodeTernaryOperator(
        type,
        varAccess,
        'Dictionary(uniqueKeysWithValues: ($varAccess as! Dictionary<AnyHashable, Any>)'
        '.map{ (k, v) in (${_encodeDeserialization(typesArgs.$1, 'k')}, ${_encodeDeserialization(typesArgs.$2, 'v')}) })',
      );
    }
    if (type.isDartCoreEnum || type.element is EnumElement) {
      return _encodeTernaryOperator(
        type,
        varAccess,
        '${_encodeType(type, false)}(rawValue: $varAccess as! Int)',
      );
    }
    return _encodeTernaryOperator(
      type,
      varAccess,
      '${_encodeType(type, false)}.deserialize($varAccess as! Array<Any?>)',
    );
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

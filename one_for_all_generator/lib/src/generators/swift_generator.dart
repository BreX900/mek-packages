import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all_generator/src/code_generator.dart';
import 'package:one_for_all_generator/src/emitters/swift_emitter.dart';
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
  void writeHostApiClass(ClassElement element) {
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

    // _specs.add(KotlinClass(
    //   modifier: KotlinClassModifier.data,
    //   name: _encodeType(element.thisType, false),
    //   initializers: fields.map((e) {
    //     return KotlinField(
    //       name: _encodeVarName(e.name),
    //       type: _encodeType(e.type, true),
    //     );
    //   }).toList(),
    //   methods: [
    //     KotlinMethod(
    //       name: 'serialize',
    //       returnType: 'List<Any?>',
    //       body: 'return listOf(\n${fields.map((e) {
    //         return '    ${_encodeSerialization(e.type, _encodeVarName(e.name))},\n';
    //       }).join()})',
    //     ),
    //   ],
    //   classes: [
    //     KotlinClass(
    //       modifier: KotlinClassModifier.companion,
    //       name: 'object',
    //       methods: [
    //         KotlinMethod(
    //           name: 'deserialize',
    //           parameters: [
    //             const KotlinParameter(
    //               name: 'serialized',
    //               type: 'List<Any?>',
    //             ),
    //           ],
    //           returnType: _encodeType(element.thisType, true),
    //           body: 'return ${_encodeType(element.thisType, false)}(\n${fields.mapIndexed((i, e) {
    //             return '    ${_encodeVarName(e.name)} = ${_encodeDeserialization(e.type, 'serialized[$i]')},\n';
    //           }).join()});',
    //         ),
    //       ],
    //     ),
    //   ],
    // ));
  }

  @override
  void writeEnum(EnumElement element) {
    // _specs.add(KotlinEnum(
    //   name: _encodeType(element.thisType, false),
    //   values: element.fields.where((element) => element.isEnumConstant).map((e) {
    //     return _encodeVarName(e.name.constantCase);
    //   }).toList(),
    // ));
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
  String toString() => '${SwiftEmitter().encode(SwiftLibrary(
        imports: [
          'Flutter',
        ],
        body: _specs,
      ))}';
}

extension on DartType {
  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;
  String get questionOrEmpty => isNullable ? '?' : '';
  // String get exclamationOrEmpty => isNullable ? '!' : '';
}

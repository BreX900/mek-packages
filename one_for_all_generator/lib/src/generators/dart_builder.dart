import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:one_for_all_generator/src/code_generator.dart';
import 'package:one_for_all_generator/src/handlers/api_class_handler.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:path/path.dart';
import 'package:recase/recase.dart';

class DartGenerator extends CodeGenerator with WriteToOutputFile {
  final DartOptions options;
  final _library = LibraryBuilder();

  @override
  String get outputFile {
    final path = pluginOptions.apiFile;
    return '${dirname(path)}/${basenameWithoutExtension(basenameWithoutExtension(path))}.api.dart';
  }

  DartGenerator(super.pluginOptions, this.options) {
    _library.directives.add(Directive.partOf(basename(pluginOptions.apiFile)));
  }

  Code? _buildFlutterApiConstructorCode(ClassElement element) {
    final methods = element.methods.where((e) => e.isFlutterMethod);
    if (methods.isEmpty) return null;

    return Code('''
      _channel.setMethodCallHandler((call) async {
        final args = call.arguments as List<Object?>;
        return switch (call.method) {
        ${methods.map((e) {
      return '''
          '${e.name}' => await ${e.name}(${e.parameters.mapIndexed((i, e) => _encodeDeserialization(e.type, 'args[$i]')).join(', ')}),
              ''';
    }).join('\n')}
         _ => throw StateError('Not supported: \${call.method}'),
        };
      });
      ''');
  }

  @override
  void writeException(EnumElement element) {
    _library.body.add(Class((b) => b
      ..name = element.name.replaceFirst('Code', '')
      ..fields.add(Field((b) => b
        ..modifier = FieldModifier.final$
        ..type = Reference(element.name)
        ..name = 'code'))
      ..fields.add(Field((b) => b
        ..modifier = FieldModifier.final$
        ..type = Reference('String?')
        ..name = 'message'))
      ..fields.add(Field((b) => b
        ..modifier = FieldModifier.final$
        ..type = Reference('String?')
        ..name = 'details'))
      ..constructors.add(Constructor((b) => b
        ..name = '_'
        ..requiredParameters.add(Parameter((b) => b
          ..toThis = true
          ..name = 'code'))
        ..requiredParameters.add(Parameter((b) => b
          ..toThis = true
          ..name = 'message'))
        ..requiredParameters.add(Parameter((b) => b
          ..toThis = true
          ..name = 'details'))))
      ..methods.add(Method((b) => b
        ..annotations.add(CodeExpression(Code('override')))
        ..returns = Reference('String')
        ..name = 'toString'
        ..lambda = true
        ..body = Code('['
            '\'\$runtimeType: \${code.name}\', '
            'code.message, '
            'message, '
            'details'
            '].nonNulls.join(\'\\n\')')))));
  }

  @override
  void writeHostApiClass(ApiClassHandler handler) {
    final ApiClassHandler(:element, :hostExceptionElement) = handler;

    _library.body.add(Class((b) => b
      ..name = '_\$${element.name}'
      ..extend = Reference(element.name)
      ..fields.add(Field((b) => b
        ..static = true
        ..modifier = FieldModifier.constant
        ..name = '_channel'
        ..assignment = Code('MethodChannel(\'${element.name.snakeCase}\')')))
      ..constructors.add(Constructor((b) => b
        ..initializers.add(const Code('super._()'))
        ..body = _buildFlutterApiConstructorCode(element)))
      ..methods.addAll([
        Method((b) => b
          ..returns = Reference('void')
          ..name = 'throwIfIsHostException'
          ..requiredParameters.add(Parameter((b) => b
            ..type = Reference('PlatformException')
            ..name = 'exception'))
          ..body = Code('''
final snakeCaseCode = exception.code.camelCase;
final code = ${hostExceptionElement.name}.values.firstWhereOrNull((e) => e.name == snakeCaseCode);
if (code == null) return;
throw ${hostExceptionElement.name.replaceFirst('Code', '')}._(code, exception.message, exception.details);
''')),
      ])
      ..methods.addAll(element.methods.where((e) => e.isHostMethod).map((e) {
        final returnType = e.returnType.singleTypeArg;

        final invocationParameters = '[${e.parameters.map((e) {
          if (e.type.isSupported) return '${e.name},\n';
          return '_\$serialize${e.type.getDisplayString(withNullability: false)}(${e.name}),\n';
        }).join()}]';

        void updateParameter(ParameterElement e, ParameterBuilder b) => b
          ..type = Reference('${e.type}')
          ..name = e.name;

        String parseResult() {
          final code = 'await _channel.invokeMethod(\'${e.name}\', $invocationParameters);';
          if (returnType is VoidType) return code;
          if (returnType.isPrimitive) return 'return $code';
          return 'final result = $code'
              'return ${_encodeDeserialization(returnType, 'result')};';
        }

        String tryParseResult() {
          // if (hostExceptionElement == null) return parseResult();
          return '''
try {
  ${parseResult()}
} on PlatformException catch(exception) {
  throwIfIsHostException(exception);
  rethrow;
}''';
        }

        return Method((b) => b
          ..annotations.add(const CodeExpression(Code('override')))
          ..returns = Reference('${e.returnType}')
          ..name = e.name
          ..requiredParameters
              .addAll(e.parameters.where((e) => !e.isNamed && e.isRequired).map((e) {
            return Parameter((b) => b..update((b) => updateParameter(e, b)));
          }))
          ..optionalParameters
              .addAll(e.parameters.where((e) => e.isNamed || !e.isRequired).map((e) {
            return Parameter((b) => b
              ..update((b) => updateParameter(e, b))
              ..required = e.isRequired
              ..named = e.isNamed
              ..defaultTo = e.defaultValueCode != null ? Code(e.defaultValueCode!) : null);
          }))
          ..modifier = MethodModifier.async
          ..body = Code(tryParseResult()));
      }))));
  }

  @override
  void writeDataClass(ClassElement element) {
    final fields = element.fields.where((e) => !e.isStatic && e.isFinal && !e.hasInitializer);

    final serializedRef = const Reference('List<Object?>');
    final deserializedRef = Reference(element.name);

    _library.body.add(Method((b) => b
      ..returns = serializedRef
      ..name = '_\$serialize${element.name}'
      ..requiredParameters.add(Parameter((b) => b
        ..type = deserializedRef
        ..name = 'deserialized'))
      ..lambda = true
      ..body = Code('[${fields.map((e) {
        return _encodeSerialization(e.type, 'deserialized.${e.name}');
      }).join(',')}]')));

    _library.body.add(Method((b) => b
      ..returns = deserializedRef
      ..name = '_\$deserialize${element.name}'
      ..requiredParameters.add(Parameter((b) => b
        ..type = serializedRef
        ..name = 'serialized'))
      ..lambda = true
      ..body = Code('${element.name}(${fields.mapIndexed((i, e) {
        return '${e.name}: ${_encodeDeserialization(e.type, 'serialized[$i]')}';
      }).join(',')})')));
  }

  @override
  void writeEnum(EnumElement element) {}

  String _encodeDeserialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('void type no supported');
    if (type.isPrimitive) return '$varAccess as ${type.displayNameNullable}';
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '($varAccess as List${type.questionOrEmpty})'
          '${type.questionOrEmpty}.map((e) => ${_encodeDeserialization(typeArg, 'e')}).toList()';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      return '($varAccess as Map${type.questionOrEmpty})'
          '${type.questionOrEmpty}.map((k, v) => MapEntry(${_encodeDeserialization(typesArgs.$1, 'k')}, ${_encodeDeserialization(typesArgs.$2, 'v')}))';
    }
    final String deserializer;
    if (type.isDartCoreEnum || type.element is EnumElement) {
      deserializer = '${type.displayName}.values[$varAccess as int]';
    } else {
      deserializer = '_\$deserialize${type.displayName}($varAccess as List)';
    }
    return type.isNullable ? '$varAccess != null ? $deserializer : null' : deserializer;
  }

  String _encodeSerialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('void type no supported');
    if (type.isPrimitive) return varAccess;
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '$varAccess'
          '${type.questionOrEmpty}.map((e) => ${_encodeSerialization(typeArg, 'e')}).toList()';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      return '$varAccess'
          '${type.questionOrEmpty}.map((k, v) => MapEntry(${_encodeSerialization(typesArgs.$1, 'k')}, ${_encodeSerialization(typesArgs.$2, 'v')}))';
    }
    if (type.isDartCoreEnum || type.element is EnumElement) {
      return '$varAccess${type.questionOrEmpty}.index';
    }
    final serializer = '_\$serialize${type.displayName}';
    return type.isNullable
        ? '$varAccess != null ? $serializer($varAccess!) : null'
        : '$serializer($varAccess)';
  }

  @override
  String toString() => DartFormatter().format('${_library.build().accept(DartEmitter())}');
}

extension on DartType {
  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;
  String get questionOrEmpty => isNullable ? '?' : '';
  String get exclamationOrEmpty => isNullable ? '!' : '';

  String get displayName => getDisplayString(withNullability: false);
  String get displayNameNullable => getDisplayString(withNullability: true);
}

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:one_for_all_generator/src/code_builder.dart';
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
  void writeHostApiClass(ClassElement element) {
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
          ..body = Code(parseResult()));
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

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:shelf_open_api_generator/src/utils/doc.dart';
import 'package:shelf_open_api_generator/src/utils/json_annotation.dart';
import 'package:shelf_open_api_generator/src/utils/utils.dart';
import 'package:source_gen/source_gen.dart';

class SchemasRegistry {
  static const _dateTimeType = TypeChecker.typeNamed(DateTime, inSdk: true);
  static const _uriType = TypeChecker.typeNamed(Uri, inSdk: true);
  static const _decimalType = TypeChecker.any([
    TypeChecker.typeNamedLiterally('Decimal', inPackage: 'decimal'),
    TypeChecker.typeNamedLiterally('Rational', inPackage: 'rational'),
    TypeChecker.typeNamedLiterally('Fixed', inPackage: 'fixed'),
  ]);

  final Map<String, InterfaceElement> _elements = {};
  final Map<String, SchemaOpenApi> _schemas = {};

  Map<String, SchemaOpenApi> get schemas => _schemas;

  SchemaOrRef register({
    bool object = true,
    bool iterables = true,
    Doc doc = Doc.none,
    required DartType dartType,
    SchemaOpenApi fallback = const SchemaOpenApi(description: 'Unknown value type.'),
  }) {
    final schema = _buildAndRegister(_Context(object: object, iterables: iterables), doc, dartType);
    if (schema != null) return schema;

    log.warning('I cant create "$dartType" component schema!');
    return fallback;
  }

  SchemaOrRef? _buildAndRegister(_Context context, Doc doc, DartType dartType) {
    final simpleSchema = _buildSimpleSchema(context, doc, dartType);
    if (simpleSchema != null) return simpleSchema;

    if (dartType.element case final InterfaceElement element) {
      final identifier = element.displayName;

      if (_elements[identifier] case final previousElement?) {
        if (element != previousElement) {
          throw InvalidGenerationSourceError(
            'Already exist schema with "$identifier" name but have different dart type',
            element: element,
          );
        }
      } else {
        _elements[identifier] = element;
        _schemas[identifier] =
            _buildComplexSchema(context, doc, element.thisType) ??
            const SchemaOpenApi(description: 'Unknown value type.');
      }
      return SchemaRef.from(identifier);
    }

    return null;
  }

  SchemaOpenApi? _buildSimpleSchema(_Context context, Doc doc, DartType dartType) {
    final result = _resolveSingleType(dartType);
    if (result != null) {
      return SchemaOpenApi(
        description: doc.summaryAndDescription, // ?? 'Support any json value type.',
        example: doc.example,
        type: result.$1,
        format: result.$2,
      );
    }

    if (context.iterables && (dartType.isDartCoreList || dartType.isDartCoreSet)) {
      final typeArgument = (dartType as ParameterizedType).typeArguments.single;

      return SchemaOpenApi(
        description: doc.summaryAndDescription,
        example: doc.example,
        type: TypeOpenApi.array,
        uniqueItems: dartType.isDartCoreSet,
        items: _buildAndRegister(context, Doc.none, typeArgument),
      );
    }

    if (context.object && dartType.isDartCoreMap) {
      final [keyType, valueType] = (dartType as ParameterizedType).typeArguments;

      if (!keyType.isDartCoreString && keyType.element is! EnumElement) {
        throw StateError('Invalid map type. The key type must be a `String` type.');
      }

      return SchemaOpenApi(
        description: doc.summaryAndDescription,
        example: doc.example,
        type: TypeOpenApi.object,
        propertyNames: _buildAndRegister(context, doc, keyType),
        additionalProperties: _buildAndRegister(context, doc, valueType),
      );
    }

    return null;
  }

  SchemaOpenApi? _buildComplexSchema(_Context context, Doc doc, InterfaceType dartType) {
    final element = _resolveElement(dartType.element);

    if (element is EnumElement) {
      final doc = Doc.from(element.documentationComment);
      final values = element.constants.map((field) {
        return JsonAnnotation.getEnumValue(element, field);
      }).toList();

      return SchemaOpenApi(
        title: element.displayName,
        description: doc.summaryAndDescription,
        example: doc.example,
        type: switch (values) {
          List<int>() => TypeOpenApi.integer,
          List<num>() => TypeOpenApi.number,
          _ => TypeOpenApi.string,
        },
        enum$: values,
      );
    }

    if (context.object && element is ClassElement) {
      final doc = Doc.from(element.documentationComment);

      final toJsonType = element.getMethod('toJson')?.returnType;
      final fromJsonType = element.getMethod('fromJson')?.formalParameters.single.type;
      if (toJsonType != null || fromJsonType != null) {
        if (toJsonType != null && fromJsonType != null && toJsonType != fromJsonType) {
          log.warning('Unknown serialization type for "toJson"/"fromJson" methods on "$element" ');
        }

        if (!(toJsonType?.isDartCoreMap ?? true) || !(fromJsonType?.isDartCoreMap ?? true)) {
          final dartType = (toJsonType ?? fromJsonType)!;
          return _buildComplexSchema(context, doc, dartType as InterfaceType);
        }
      }

      final parameters = element.requireUnnamedConstructor.formalParameters;
      final fields = element.getters;
      final names = <String, String>{
        for (final e in parameters)
          if (JsonAnnotation.getFieldName(e) case final name?) e.displayName: name,
        for (final e in element.fields)
          if (JsonAnnotation.getFieldName(e) case final name?) e.displayName: name,
        for (final e in fields)
          if (JsonAnnotation.getFieldName(e) case final name?) e.displayName: name,
      };

      final List<_ClassProperty> properties;

      if (fromJsonType != null) {
        final parameters = element.requireUnnamedConstructor.formalParameters;

        properties = parameters.map((e) {
          return _ClassProperty(
            isRequired: e.type.nullabilitySuffix == NullabilitySuffix.none,
            name: e.displayName,
            type: e.type,
          );
        }).toList();
      } else {
        properties = element.getters.map((e) {
          return _ClassProperty(
            isRequired: e.returnType.nullabilitySuffix == NullabilitySuffix.none,
            name: e.displayName,
            type: e.returnType,
          );
        }).toList();
      }

      return SchemaOpenApi(
        title: element.displayName,
        type: TypeOpenApi.object,
        description: doc.summaryAndDescription,
        example: doc.example,
        required: properties
            .where((e) => e.isRequired)
            .map((e) => names[e.name] ?? e.name)
            .toList(),
        properties: {
          for (final property in properties)
            names[property.name] ?? property.name:
                _buildAndRegister(
                  context,
                  Doc.from(
                    element.fields
                        .firstWhereOrNull((e) => e.name == property.name)
                        ?.documentationComment,
                  ),
                  property.type,
                ) ??
                const SchemaOpenApi(description: 'Unknown value type.'),
        },
      );
    }

    return null;
  }

  Element? _resolveElement(Element? element) {
    if (element is ExtensionTypeElement) return element.typeErasure.element;
    return element;
  }

  (TypeOpenApi?, FormatOpenApi?)? _resolveSingleType(DartType dartType) {
    if (dartType.isDartCoreEnum) {
      return null;
    }
    if (dartType.isDartCoreObject) {
      return (null, null);
    }
    if (dartType.isDartCoreBool) {
      return (TypeOpenApi.boolean, null);
    }
    if (dartType.isDartCoreNum || dartType.isDartCoreDouble) {
      return (TypeOpenApi.number, dartType.isDartCoreDouble ? FormatOpenApi.double : null);
    }
    if (dartType.isDartCoreInt) {
      return (TypeOpenApi.integer, FormatOpenApi.int64);
    }
    if (dartType.isDartCoreString && !dartType.isDartCoreEnum) {
      return (TypeOpenApi.string, null);
    }
    if (_uriType.isAssignableFromType(dartType)) {
      return (TypeOpenApi.string, FormatOpenApi.uri);
    }
    if (_dateTimeType.isAssignableFromType(dartType)) {
      return (TypeOpenApi.string, FormatOpenApi.dateTime);
    }
    if (_decimalType.isAssignableFromType(dartType)) {
      return (TypeOpenApi.string, FormatOpenApi.decimal);
    }
    return null;
  }
}

class _ClassProperty {
  final bool isRequired;
  final DartType type;
  final String name;

  const _ClassProperty({required this.isRequired, required this.type, required this.name});
}

class _Context {
  final bool object;
  final bool iterables;

  const _Context({required this.object, required this.iterables});
}

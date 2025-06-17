import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:shelf_open_api_generator/src/utils/doc.dart';
import 'package:source_gen/source_gen.dart';

class SchemasRegistry {
  final Map<String, Set<DartType>> _schemas = {};

  SchemaOpenApi tryRegister({
    bool isBidirectional = true,
    Doc doc = Doc.none,
    required DartType dartType,
  }) {
    return _SchemaResolver(
      object: true,
      iterables: true,
      isBidirectional: isBidirectional,
      registry: this,
    ).resolve(dartType: dartType, doc: doc);
  }

  SchemaOpenApi? tryRegisterV2({
    bool object = true,
    bool iterables = true,
    bool isBidirectional = true,
    Doc doc = Doc.none,
    required DartType? dartType,
  }) {
    if (dartType == null) return null;
    try {
      return _SchemaResolver(
        object: object,
        iterables: iterables,
        isBidirectional: isBidirectional,
        registry: this,
      ).resolve(dartType: dartType, doc: doc);
    } on _UnsupportedRegistrationType {
      return null;
    }
  }

  void _checkRegistration({required DartType dartType, required String name}) {
    final prevDartTypes = _schemas[name];

    if (prevDartTypes == null) {
      _schemas[name] = {dartType};
    } else if (!prevDartTypes.contains(dartType)) {
      log.warning(
        'Already exist $name component schema with different type!\n'
        '$prevDartTypes | $dartType',
      );
      _schemas[name] = {...prevDartTypes, dartType};
    }
  }
}

class _SchemaResolver {
  static final _dateTimeType = TypeChecker.fromRuntime(DateTime);
  static final _uriType = TypeChecker.fromRuntime(Uri);

  final bool object;
  final bool iterables;
  final bool isBidirectional;
  final SchemasRegistry registry;

  _SchemaResolver({
    required this.object,
    required this.iterables,
    required this.isBidirectional,
    required this.registry,
  });

  SchemaOpenApi resolve({Doc doc = Doc.none, required DartType dartType}) {
    final element = dartType.element;

    final description = doc.summaryAndDescription;
    final example = doc.example;

    if (element is EnumElement) {
      final doc = Doc.from(element.documentationComment);
      final enumValues = element.fields.where((element) => element.isEnumConstant);

      registry._checkRegistration(dartType: dartType, name: element.name);
      return SchemaOpenApi(
        title: element.name,
        description: doc.summaryAndDescription,
        example: doc.example,
        type: TypeOpenApi.string,
        enum$: enumValues.map((e) => e.name).toList(),
      );
    }

    if (dartType.isDartCoreObject) {
      return SchemaOpenApi(
        description: description ?? 'Support any json value type.',
        example: example,
      );
    } else if (dartType.isDartCoreBool) {
      return SchemaOpenApi(description: description, example: example, type: TypeOpenApi.boolean);
    } else if (dartType.isDartCoreNum || dartType.isDartCoreDouble) {
      return SchemaOpenApi(
        description: description,
        example: example,
        type: TypeOpenApi.number,
        format: dartType.isDartCoreDouble ? FormatOpenApi.double : null,
      );
    } else if (dartType.isDartCoreInt) {
      return SchemaOpenApi(
        description: description,
        example: example,
        type: TypeOpenApi.integer,
        format: FormatOpenApi.int64,
      );
    } else if (dartType.isDartCoreString ||
        _uriType.isAssignableFromType(dartType) ||
        _dateTimeType.isAssignableFromType(dartType)) {
      return SchemaOpenApi(
        description: description,
        example: example,
        type: TypeOpenApi.string,
        format: _dateTimeType.isAssignableFromType(dartType)
            ? FormatOpenApi.dateTime
            : (_uriType.isAssignableFromType(dartType) ? FormatOpenApi.uri : null),
      );
    }

    if (!iterables) throw _UnsupportedRegistrationType();
    if (dartType.isDartCoreIterable || dartType.isDartCoreList) {
      final typeArgument = (dartType as ParameterizedType).typeArguments.single;

      return SchemaOpenApi(
        description: description,
        example: example,
        type: TypeOpenApi.array,
        items: resolve(doc: Doc.none, dartType: typeArgument),
      );
    }

    if (!object) throw _UnsupportedRegistrationType();
    if (dartType.isDartCoreMap) {
      final typeArguments = (dartType as ParameterizedType).typeArguments;

      if (!typeArguments[0].isDartCoreString) {
        throw StateError('Invalid map type. The key type must be a `String` type.');
      }

      return SchemaOpenApi(
        description: description,
        example: example,
        type: TypeOpenApi.object,
        additionalProperties: resolve(dartType: typeArguments[1]),
      );
    } else if (element is ClassElement) {
      final List<_ClassProperty> properties;

      if (isBidirectional) {
        final parameters = element.constructors.firstWhere((e) => e.name.isEmpty).parameters;

        properties = parameters.map((e) {
          return _ClassProperty(
            isRequired: e.type.nullabilitySuffix == NullabilitySuffix.none,
            name: e.name,
            type: e.type,
          );
        }).toList();
      } else {
        properties = element.accessors.where((e) => e.isGetter).map((e) {
          return _ClassProperty(
            isRequired: e.returnType.nullabilitySuffix == NullabilitySuffix.none,
            name: e.name,
            type: e.returnType,
          );
        }).toList();
      }

      registry._checkRegistration(dartType: dartType, name: element.name);

      return SchemaOpenApi(
        title: element.name,
        type: TypeOpenApi.object,
        format: null,
        required: properties.where((e) => e.isRequired).map((e) => e.name).toList(),
        properties: {
          for (final property in properties)
            property.name: resolve(
              doc: Doc.from(
                element.fields.firstWhereOrNull((e) {
                  return e.name == property.name;
                })?.documentationComment,
              ),
              dartType: property.type,
            ),
        },
      );
    }

    log.warning('I cant create $dartType component schema!');
    return SchemaOpenApi(description: 'Unknown value type.');
  }
}

class _ClassProperty {
  final bool isRequired;
  final DartType type;
  final String name;

  const _ClassProperty({required this.isRequired, required this.type, required this.name});
}

class _UnsupportedRegistrationType implements Exception {}

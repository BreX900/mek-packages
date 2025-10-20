import 'package:analyzer/dart/element/element2.dart';
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
  final Map<String, Set<DartType>> _schemas = {};

  RefOr<SchemaOpenApi> tryRegister({
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

  RefOr<SchemaOpenApi>? tryRegisterV2({
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
  static final _dateTimeType = TypeChecker.typeNamed(DateTime, inSdk: true);
  static final _uriType = TypeChecker.typeNamed(Uri, inSdk: true);

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

  RefOr<SchemaOpenApi> resolve({Doc doc = Doc.none, required DartType dartType}) {
    final element = dartType.element3;

    if (registry._schemas[element?.requireName]?.contains(dartType) ?? false) {
      return RefOpenApi('#/components/schemas/${element!.requireName}', (_) {
        throw UnsupportedError('');
      });
    }

    final description = doc.summaryAndDescription;
    final example = doc.example;

    if (element is EnumElement2) {
      registry._checkRegistration(dartType: dartType, name: element.requireName);

      final doc = Doc.from(element.documentationComment);
      final values = element.constants2.map((field) {
        return JsonAnnotation.getEnumValue(element, field);
      }).toList();

      return SchemaOpenApi(
        title: element.requireName,
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
    } else if (element is ClassElement2) {
      final doc = Doc.from(element.documentationComment);
      final parameters = element.requireUnnamedConstructor.formalParameters;
      final fields = element.getters2;
      final names = <String, String>{
        for (final e in parameters)
          if (JsonAnnotation.getFieldName(e) case final name?) e.requireName: name,
        for (final e in element.fields2)
          if (JsonAnnotation.getFieldName(e) case final name?) e.requireName: name,
        for (final e in fields)
          if (JsonAnnotation.getFieldName(e) case final name?) e.requireName: name,
      };

      final List<_ClassProperty> properties;

      if (isBidirectional) {
        final parameters = element.requireUnnamedConstructor.formalParameters;

        properties = parameters.map((e) {
          return _ClassProperty(
            isRequired: e.type.nullabilitySuffix == NullabilitySuffix.none,
            name: e.requireName,
            type: e.type,
          );
        }).toList();
      } else {
        properties = element.getters2.map((e) {
          return _ClassProperty(
            isRequired: e.returnType.nullabilitySuffix == NullabilitySuffix.none,
            name: e.requireName,
            type: e.returnType,
          );
        }).toList();
      }

      registry._checkRegistration(dartType: dartType, name: element.requireName);

      return SchemaOpenApi(
        title: element.requireName,
        type: TypeOpenApi.object,
        description: doc.summaryAndDescription,
        example: doc.example,
        format: null,
        required: properties
            .where((e) => e.isRequired)
            .map((e) => names[e.name] ?? e.name)
            .toList(),
        properties: {
          for (final property in properties)
            names[property.name] ?? property.name: resolve(
              doc: Doc.from(
                element.fields2
                    .firstWhereOrNull((e) => e.name3 == property.name)
                    ?.documentationComment,
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

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';
import 'package:recase/recase.dart';

class DartApiCodes extends ApiCodecs {
  DartApiCodes(super.pluginOptions, super.codecs);

  @override
  String encodeName(String name) => name.pascalCase;

  @override
  String encodeType(DartType type) => findCodec(type)?.encodeType(this, type) ?? type.displayName;

  @override
  String encodeDeserialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('Void type no supported');

    final questionOrEmpty = type.isNullable ? '?' : '';

    if (type.isPrimitive) return '$varAccess as ${type.displayNameNullable}';
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '($varAccess as List$questionOrEmpty)'
          '$questionOrEmpty.map((e) => ${encodeDeserialization(typeArg, 'e')}).toList()';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      return '($varAccess as Map$questionOrEmpty)'
          '$questionOrEmpty.map((k, v) => MapEntry(${encodeDeserialization(typesArgs.$1, 'k')}, ${encodeDeserialization(typesArgs.$2, 'v')}))';
    }
    if (type.isDartCoreEnum || type.element is EnumElement) {
      final deserializer = '${encodeName(type.displayName)}.values[$varAccess as int]';
      return type.isNullable ? '$varAccess != null ? $deserializer : null' : deserializer;
    }

    final codec = findCodec(type);
    if (codec != null) {
      if (!type.isNullable || codec.hasNullSafeDeserialization) {
        return codec.encodeDeserialization(this, type, varAccess);
      } else {
        return '$varAccess != null ? ${codec.encodeDeserialization(this, type, varAccess)} : null';
      }
    }

    final deserializer = '_\$deserialize${encodeName(type.displayName)}($varAccess as List)';
    return type.isNullable ? '$varAccess != null ? $deserializer : null' : deserializer;
  }

  @override
  String encodeSerialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('Void type no supported');

    final questionOrEmpty = type.isNullable ? '?' : '';

    if (type.isPrimitive) return varAccess;
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '$varAccess'
          '$questionOrEmpty.map((e) => ${encodeSerialization(typeArg, 'e')}).toList()';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      return '$varAccess'
          '$questionOrEmpty.map((k, v) => MapEntry(${encodeSerialization(typesArgs.$1, 'k')}, ${encodeSerialization(typesArgs.$2, 'v')}))';
    }
    if (type.isDartCoreEnum || type.element is EnumElement) {
      return '$varAccess$questionOrEmpty.index';
    }

    final codec = findCodec(type);
    if (codec != null) {
      if (!type.isNullable || codec.hasNullSafeSerialization) {
        return codec.encodeSerialization(this, type, varAccess);
      } else {
        return '$varAccess != null ? ${codec.encodeSerialization(this, type, '$varAccess!')} : null';
      }
    }

    final serializer = '_\$serialize${type.displayName}';
    return type.isNullable
        ? '$varAccess != null ? $serializer($varAccess!) : null'
        : '$serializer($varAccess)';
  }
}

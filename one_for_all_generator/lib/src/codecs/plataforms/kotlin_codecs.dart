import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';

class KotlinApiCodes extends HostApiCodecs {
  KotlinApiCodes(super.pluginOptions, super.codecs);

  @override
  String? encodePrimitiveType(DartType type, [bool withNullability = true]) {
    final questionOrEmpty = withNullability && type.isNullable ? '?' : '';

    if (type.isDartCoreObject || type is DynamicType) return 'Any$questionOrEmpty';
    if (type is VoidType) return 'Unit$questionOrEmpty';
    if (type.isDartCoreNull) return 'null$questionOrEmpty';
    if (type.isDartCoreBool) return 'Boolean$questionOrEmpty';
    if (type.isDartCoreInt) return 'Long$questionOrEmpty';
    if (type.isDartCoreDouble) return 'Double$questionOrEmpty';
    if (type.isDartCoreString) return 'String$questionOrEmpty';
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return 'List<${encodeType(typeArg)}>$questionOrEmpty';
    }
    if (type.isDartCoreMap) {
      final typeArgs = type.doubleTypeArgs;
      return 'HashMap<${encodeType(typeArgs.$1)}, ${encodeType(typeArgs.$2)}>$questionOrEmpty';
    }

    return null;
  }

  @override
  String encodeDeserialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('Void type no supported');

    final questionOrEmpty = type.isNullable ? '?' : '';

    if (type.isDartCoreInt) {
      return '($varAccess as$questionOrEmpty Number)$questionOrEmpty.toLong()';
    }
    if (type.isPrimitive) return '$varAccess as ${encodeType(type)}';
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '($varAccess as List<*>$questionOrEmpty)'
          '$questionOrEmpty.map { ${encodeDeserialization(typeArg, 'it')} }';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      final serializer = 'hashMapOf(*(${type.isNullable ? 'it' : varAccess} as HashMap<*, *>)'
          '.map { (k, v) -> ${encodeDeserialization(typesArgs.$1, 'k')} to ${encodeDeserialization(typesArgs.$2, 'v')} }'
          '.toTypedArray())';
      return type.isNullable ? '$varAccess?.let { $serializer }' : serializer;
    }
    if (type.isDartCoreEnum || type.element is EnumElement) {
      return '($varAccess as Int$questionOrEmpty)'
          '$questionOrEmpty.let { ${encodeName(type.displayName)}.values()[it] }';
    }

    final codec = findCodec(type);
    if (codec != null) {
      if (!type.isNullable || codec.hasNullSafeDeserialization) {
        return codec.encodeSerialization(this, type, varAccess);
      } else {
        return '$varAccess?.let { ${codec.encodeSerialization(this, type, 'it')} }';
      }
    }

    return '($varAccess as List<Any?>$questionOrEmpty)'
        '$questionOrEmpty.let { ${encodeName(type.displayName)}.deserialize(it) }';
  }

  @override
  String encodeSerialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('Void type no supported');

    final questionOrEmpty = type.isNullable ? '?' : '';

    if (type.isPrimitive) return varAccess;
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '$varAccess$questionOrEmpty.map { ${encodeSerialization(typeArg, 'it')}} ';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      final serializer = 'hashMapOf(*${type.isNullable ? 'it' : varAccess}'
          '.map { (k, v) -> ${encodeSerialization(typesArgs.$1, 'k')} to ${encodeSerialization(typesArgs.$2, 'v')} }'
          '.toTypedArray())';
      return type.isNullable ? '$varAccess?.let { $serializer }' : serializer;
    }
    if (type.isDartCoreEnum || type.element is EnumElement) {
      return '$varAccess$questionOrEmpty.ordinal';
    }

    final codec = findCodec(type);
    if (codec != null) {
      if (!type.isNullable || codec.hasNullSafeSerialization) {
        return codec.encodeSerialization(this, type, varAccess);
      } else {
        return '$varAccess?.let { ${codec.encodeSerialization(this, type, 'it')} }';
      }
    }

    return '$varAccess$questionOrEmpty.serialize()';
  }
}

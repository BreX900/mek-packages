import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';

class SwiftApiCodes extends HostApiCodecs {
  SwiftApiCodes(super.pluginOptions, super.codecs);

  @override
  String? encodePrimitiveType(DartType type, [bool withNullability = true]) {
    final questionOrEmpty = withNullability && type.isNullable ? '?' : '';

    if (type.isDartCoreObject || type is DynamicType) return 'Any$questionOrEmpty';
    if (type is VoidType) return 'Void$questionOrEmpty';
    if (type.isDartCoreNull) return 'nil$questionOrEmpty';
    if (type.isDartCoreBool) return 'Bool$questionOrEmpty';
    if (type.isDartCoreInt) return 'Int$questionOrEmpty';
    if (type.isDartCoreDouble) return 'Double$questionOrEmpty';
    if (type.isDartCoreString) return 'String$questionOrEmpty';
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '[${encodeType(typeArg)}]$questionOrEmpty';
    }
    if (type.isDartCoreMap) {
      final typeArgs = type.doubleTypeArgs;
      return '[${encodeType(typeArgs.$1)}: ${encodeType(typeArgs.$2)}]$questionOrEmpty';
    }

    return null;
  }

  @override
  String encodeDeserialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('Void type no supported');

    final questionOrEmpty = type.isNullable ? '?' : '';
    final questionOrExclamation = type.isNullable ? '?' : '!';

    if (type.isPrimitive) {
      return '$varAccess as$questionOrExclamation ${encodeType(type, false)}';
    }
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '($varAccess as$questionOrExclamation [Any?])'
          '$questionOrEmpty.map { ${encodeDeserialization(typeArg, '\$0')} }';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      final deserializer = 'Dictionary(uniqueKeysWithValues: ($varAccess as! [AnyHashable?: Any?])'
          '.map { k, v in (${encodeDeserialization(typesArgs.$1, 'k')}, ${encodeDeserialization(typesArgs.$2, 'v')}) })';
      return type.isNullable ? '$varAccess != nil ? $deserializer : nil' : deserializer;
    }
    if (type.isDartCoreEnum || type.element is EnumElement) {
      final deserializer = '${encodeName(type.displayName)}(rawValue: $varAccess as! Int)!';
      return type.isNullable ? '$varAccess != nil ? $deserializer : nil' : deserializer;
    }

    final codec = findCodec(type);
    if (codec != null) {
      if (!type.isNullable || codec.hasNullSafeDeserialization) {
        return codec.encodeDeserialization(this, type, varAccess);
      } else {
        return '$varAccess != nil ? ${codec.encodeDeserialization(this, type, varAccess)} : nil';
      }
    }

    final element = type.element;

    final deserializerMethod = element is ClassElement && element.isSealed
        ? 'deserialize${encodeName(type.displayName)}'
        : '${encodeName(type.displayName)}.deserialize';
    final deserializer = '$deserializerMethod($varAccess as! [Any?])';
    return type.isNullable ? '$varAccess != nil ? $deserializer : nil' : deserializer;
  }

  @override
  String encodeSerialization(DartType type, String varAccess) {
    if (type is VoidType) throw StateError('Void type no supported');

    final questionOrEmpty = type.isNullable ? '?' : '';
    final exclamationOrEmpty = type.isNullable ? '!' : '';

    if (type.isPrimitive) return varAccess;
    if (type.isDartCoreList) {
      final typeArg = type.singleTypeArg;
      return '$varAccess$questionOrEmpty.map { ${encodeSerialization(typeArg, '\$0')} }';
    }
    if (type.isDartCoreMap) {
      final typesArgs = type.doubleTypeArgs;
      final serializer =
          'Dictionary(uniqueKeysWithValues: $varAccess$exclamationOrEmpty.map { k, v in '
          '(${encodeSerialization(typesArgs.$1, 'k')}, ${encodeSerialization(typesArgs.$2, 'v')}) })';
      return '$varAccess != nil ? $serializer : nil';
    }
    if (type.isDartCoreEnum || type.element is EnumElement) {
      return '$varAccess$questionOrEmpty.rawValue';
    }

    final codec = findCodec(type);
    if (codec != null) {
      if (!type.isNullable || codec.hasNullSafeSerialization) {
        return codec.encodeSerialization(this, type, varAccess);
      } else {
        return '$varAccess != nil ? ${codec.encodeSerialization(this, type, '$varAccess!')} : nil';
      }
    }

    return '$varAccess$questionOrEmpty.serialize()';
  }
}

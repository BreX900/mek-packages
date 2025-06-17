import 'package:diacritic/diacritic.dart';
import 'package:meta/meta.dart';
import 'package:open_api_client_generator/src/options/options.dart';
import 'package:recase/recase.dart';

class Codecs {
  const Codecs();

  @protected
  String encodeType(String name) {
    // Don't start the string with a number
    if (name.startsWith(RegExp('[0-9]'))) name = '\$$name';
    return name;
  }

  String encodeName(String str) => _encodeName(str);

  String encodeDartValue(Object value) {
    if (value is String) return "'${value.replaceAll(r'$', r'\$')}'";
    return '$value';
  }

  String encodeEnumValue(Object value) => value is String ? encodeName(value) : 'vl$value';

  /// Encode variable name, field name and method name
  @protected
  String _encodeName(String str) {
    if (_keywords.contains(str)) return '$str\$';
    // Remove symbols
    str = str.replaceAllMapped(RegExp(r'([^0-9\w])'), (match) => '_');
    // Don't start the string with a number
    if (str.startsWith(RegExp('[0-9]'))) str = '\$$str';
    return str;
  }
}

class ApiCodecs extends Codecs {
  final Options options;

  ApiCodecs({required this.options});

  @override
  String encodeType(String name) =>
      '${removeDiacritics(super.encodeType(name)).pascalCase}${options.dataClassesPostfix ?? ''}';

  @override
  String _encodeName(String str) => super._encodeName(removeDiacritics(str).camelCase);
}

final _keywords = {
  'else',
  'enum',
  'in',
  'assert',
  'super',
  'extends',
  'is',
  'switch',
  'break',
  'this',
  'case',
  'throw',
  'catch',
  'false',
  'new',
  'true',
  'class',
  'final',
  'null',
  'try',
  'const',
  'finally',
  'continue',
  'for',
  'var',
  'void',
  'default',
  'while',
  'rethrow',
  'with',
  'do',
  'if',
  'return',
};

import 'dart:convert';

/// Why has custom implementation?
/// fhir_yaml: ^0.9.0 package not convert string with "\n" to multiline string
/// yaml_writer: ^1.0.2 package add empty "random" line on yaml generated
// TODO: Try replace with yaml_writer
class YamlEncoder extends Converter<Map<String, dynamic>, String> {
  final int indent;
  final bool shouldMultilineStringInBlock;
  final int? maxStringLineWidth; // TODO: Add support to maxStringLineWidth
  final Object? Function(dynamic)? toEncodable;

  const YamlEncoder({
    this.indent = 2,
    this.shouldMultilineStringInBlock = true,
    this.maxStringLineWidth,
    this.toEncodable,
  });

  @override
  String convert(Map<String, dynamic> input) {
    final output = StringBuffer();
    _YamlWriter(
      sink: output,
      shouldMultilineStringInBlock: shouldMultilineStringInBlock,
      indent: indent,
      toEncodable: toEncodable,
    ).write(input);
    return output.toString();
  }
}

/// Please dev follow [_JsonStringStringifier] code style
class _YamlWriter {
  final StringSink _sink;

  final int indent;
  final bool shouldMultilineStringInBlock;
  final Object? Function(dynamic)? toEncodable;

  bool _canWriteBlock = false;
  int _indentLevel = -1;

  bool get isInitialLine => _indentLevel == -1;

  _YamlWriter({
    required this.indent,
    required this.shouldMultilineStringInBlock,
    required this.toEncodable,
    required StringSink sink,
  }) : _sink = sink;

  void write(Object? object) {
    if (object == null) {
      // Nothing to write
    } else if (object is bool) {
      writeBoolean(object);
    } else if (object is num) {
      writeNumber(object);
    } else if (object is String) {
      writeString(object);
    } else if (object is List<dynamic>) {
      writeList(object);
    } else if (object is Map<String, dynamic>) {
      writeMap(object);
    } else if (toEncodable != null) {
      write(toEncodable!(object));
    } else {
      throw 'Not support $object';
    }
  }

  void writeBoolean(bool boolean) {
    if (!isInitialLine) _writeValueIndentation();
    _sink.write(boolean);
  }

  void writeNumber(num number) {
    if (!isInitialLine) _writeValueIndentation();
    _sink.write(number);
  }

  // https://stackoverflow.com/questions/3790454/how-do-i-break-a-string-in-yaml-over-multiple-lines
  void writeString(String string) {
    if (!isInitialLine) _writeValueIndentation();

    if (string.contains('\n') && shouldMultilineStringInBlock) {
      final hasNewLineEnd = string.endsWith('\n');
      _sink.write(hasNewLineEnd ? '|\n' : '|-\n');

      _indentLevel += 1;
      final lines = string.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final isLastLine = (i + 1) == lines.length;

        if (hasNewLineEnd && isLastLine) continue;

        writeIndentation();
        _sink.write(lines[i]);

        if (!isLastLine) _sink.write('\n');
      }
      _indentLevel -= 1;
    } else {
      final hasSpecialCharacters = _specialCharacters.any((e) => string.contains(e));
      final isSpecialKeyword = _spacialKeywords.contains(string) || num.tryParse(string) != null;
      final isSpecial = hasSpecialCharacters || isSpecialKeyword;

      if (isSpecial) _sink.write('"');
      _sink.write(_stringWithEscapes(string));
      if (isSpecial) _sink.write('"');
    }
  }

  // Using Quotes with YAML Special Characters
  final _specialCharacters = r'{}[],&:*#?|-<>=!%@\'.split('');
  final _spacialKeywords = ['null', 'true', 'false'];

  String _stringWithEscapes(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll('\r', r'\r')
      .replaceAll('\t', r'\t')
      .replaceAll('\n', r'\n')
      .replaceAll('"', r'\"')
      .replaceAll('', '\x99')
      .replaceAll('', '\x9D');

  void writeList(List<dynamic> list) {
    if (list.isEmpty) {
      if (!isInitialLine) _writeValueIndentation();
      _sink.write('[ ]');
    } else {
      var isInitialLine = this.isInitialLine;

      _indentLevel += 1;
      for (final element in list) {
        if (!isInitialLine) _writeBlockIndentation();
        isInitialLine = false;

        _canWriteBlock = true;
        _sink.write('-');
        write(element);
      }
      _indentLevel -= 1;
    }
  }

  void writeMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      if (!isInitialLine) _writeValueIndentation();
      _sink.write('{ }');
    } else {
      var isInitialLine = this.isInitialLine;

      _indentLevel += 1;
      map.forEach((key, value) {
        if (!isInitialLine) _writeBlockIndentation();
        isInitialLine = false;

        _canWriteBlock = false;
        _sink.write(key);
        _sink.write(':');
        write(value);
      });
      _indentLevel -= 1;
    }
  }

  void writeIndentation() {
    _sink.write((' ' * indent) * _indentLevel);
  }

  void _writeValueIndentation() {
    _sink.write(' ');
    _canWriteBlock = false;
  }

  void _writeBlockIndentation() {
    if (_canWriteBlock) {
      _sink.write(' ');
    } else {
      _sink.writeln();
      writeIndentation();
    }
  }
}

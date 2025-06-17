class CodeBuffer {
  final _buffer = StringBuffer();
  var _indent = 0;

  String get space => '  ' * _indent;

  void write(Object? object) {
    _buffer.write(space);
    _buffer.write(object);
  }

  void writeln(Object? object) {
    _buffer.write(space);
    _buffer.writeln(object);
  }

  void writeAll(Iterable<Object?> objects, [String separator = '']) {
    _buffer.writeAll(objects, separator);
  }

  void indent(void Function() body) {
    _indent += 1;
    body();
    _indent -= 1;
  }

  @override
  String toString() => _buffer.toString();
}

extension StringBufferExtensions on StringBuffer {
  void writeAllWith(Object prefix, Iterable<Object?> objects, String separator) {
    write(prefix);
    writeAll(objects, '$separator$prefix');
  }
}

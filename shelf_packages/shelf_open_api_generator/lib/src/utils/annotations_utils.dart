import 'package:analyzer/dart/constant/value.dart';
import 'package:source_gen/source_gen.dart';

extension ConstantReaderExtensions on ConstantReader {
  Map<ConstantReader, ConstantReader> get mapReader =>
      mapValue.map((key, value) => MapEntry(ConstantReader(key), ConstantReader(value)));

  Iterable<ConstantReader> get listReader => listValue.map(ConstantReader.new);
}

extension TypeCheckerExtensions on DartObject? {
  ConstantReader get asReader => ConstantReader(this);
}

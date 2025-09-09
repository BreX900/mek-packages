import 'package:recase/recase.dart';

class Options {
  final Uri input;

  final String apiClassName;
  final String? dataClassesPostfix;

  final String outputFolder;

  const Options({
    required this.input,
    this.apiClassName = 'Api',
    this.dataClassesPostfix,
    required this.outputFolder,
  }) : assert(apiClassName != '');

  String get outputApiFileTitle => apiClassName.snakeCase;
}

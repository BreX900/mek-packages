import 'package:open_api_specification/open_api_spec.dart';
import 'package:recase/recase.dart';

class Options {
  final Uri input;

  final String apiClassName;
  final String? dataClassesPostfix;

  final String outputFolder;

  final bool Function(int statusCode, ResponseOpenApi response) shouldReturns;

  const Options({
    required this.input,
    this.apiClassName = 'Api',
    this.dataClassesPostfix,
    required this.outputFolder,
    this.shouldReturns = _shouldReturns,
  }) : assert(apiClassName != '');

  String get outputApiFileTitle => apiClassName.snakeCase;

  static bool _shouldReturns(int statusCode, ResponseOpenApi response) =>
      statusCode >= 200 && statusCode < 300;
}

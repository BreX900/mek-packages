import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_routing/shelf_routing.dart';

/// Generator utils
T $parsePathParameter<T>(String value, T Function(String vl) parser) {
  try {
    return parser(value);
  } catch (error, stackTrace) {
    throw BadRequestException.path(error, stackTrace);
  }
}

/// Generator utils
T $parseQueryParameters<T>(Request request, String name, T Function(List<String> vls) parser) {
  try {
    return parser(request.url.queryParametersAll[name] ?? const <String>[]);
  } catch (error, stackTrace) {
    throw BadRequestException.queryParameter(error, stackTrace, name);
  }
}

/// Generator utils
void $ensureHasHeader(Request request, String name) {
  try {
    ArgumentError.checkNotNull(request.headersAll[name], name);
  } catch (error, stackTrace) {
    throw BadRequestException.header(error, stackTrace, name);
  }
}

/// Generator utils
Future<T> $readBodyAs<T>(Request request, T Function(Map<String, dynamic> data) converter) async {
  try {
    final data = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    return converter(data);
  } catch (error, stackTrace) {
    throw BadRequestException.body(error, stackTrace);
  }
}

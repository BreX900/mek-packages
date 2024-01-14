// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unnecessary_raw_strings

part of 'query_parameters.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

Router get _$queryParametersControllerRouter => Router()
  ..add('GET', r'/single', (Request request) async {
    final $ = request.get<QueryParametersController>();
    return $.single(
      request,
      integer: $parseQueryParameters(
          request, 'integer', (vls) => int.parse(vls.single)),
      double: $parseQueryParameters(request, 'double',
          (vls) => vls.isNotEmpty ? double.parse(vls.single) : null),
      string: $parseQueryParameters(request, 'string', (vls) => vls.single),
      stringOrNull: $parseQueryParameters(request, 'string-or-null',
          (vls) => vls.isNotEmpty ? vls.single : null),
      customParser: $parseQueryParameters(request, 'custom-parser',
          (vls) => vls.isNotEmpty ? DateTime.parse(vls.single) : null),
    );
  })
  ..add('GET', r'/list', (Request request) async {
    final $ = request.get<QueryParametersController>();
    return $.list(
      request,
      stringList: $parseQueryParameters(request, 'string-list', (vls) => vls),
      integerList: $parseQueryParameters(
          request, 'integer-list', (vls) => vls.map(int.parse).toList()),
      customParserList: $parseQueryParameters(request, 'custom-parser-list',
          (vls) => vls.map(DateTime.parse).toList()),
    );
  });

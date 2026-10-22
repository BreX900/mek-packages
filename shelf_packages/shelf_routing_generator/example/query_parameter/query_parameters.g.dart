// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unnecessary_raw_strings

part of 'query_parameters.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$QueryParametersControllerRouter(
  QueryParametersController service,
) => Router()
  ..add('GET', '/single', (Request request) {
    return service.single(
      request,
      integer: $parseQueryParameters(
        request,
        'integer',
        (data) => int.parse(data.single),
      ),
      double: $parseQueryParameters(
        request,
        'double',
        (data) => data.isNotEmpty ? double.parse(data.single) : null,
      ),
      string: $parseQueryParameters(request, 'string', (data) => data.single),
      stringOrNull: $parseQueryParameters(
        request,
        'stringOrNull',
        (data) => data.isNotEmpty ? data.single : null,
      ),
      customParser: $parseQueryParameters(
        request,
        'customParser',
        (data) => data.isNotEmpty ? DateTime.parse(data.single) : null,
      ),
    );
  })
  ..add('GET', '/list', (Request request) {
    return service.list(
      request,
      stringList: $parseQueryParameters(request, 'stringList', (data) => data),
      integerList: $parseQueryParameters(
        request,
        'integerList',
        (data) => data.map(int.parse).toList(),
      ),
      customParserList: $parseQueryParameters(
        request,
        'customParserList',
        (data) => data.map(DateTime.parse).toList(),
      ),
    );
  });

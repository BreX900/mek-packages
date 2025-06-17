// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unnecessary_raw_strings

part of 'body_parameters.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

Router get _$pathParametersControllerRouter => Router()
  ..add('POST', r'/integer', (Request request) async {
    final $ = request.get<PathParametersController>();
    return $.integer(
      request,
      await $parseBodyAs(request, (data) => data! as int),
    );
  })
  ..add('POST', r'/fromJson', (Request request) async {
    final $ = request.get<PathParametersController>();
    return $.fromJson(
      request,
      await $parseBodyAs(request, (data) => Decimal.fromJson(data! as String)),
    );
  })
  ..add('POST', r'/listDouble', (Request request) async {
    final $ = request.get<PathParametersController>();
    return $.listDouble(
      request,
      await $parseBodyAs(
        request,
        (data) => (data! as List<dynamic>).map((data) {
          return data! as double;
        }).toList(),
      ),
    );
  })
  ..add('POST', r'/listFromJson', (Request request) async {
    final $ = request.get<PathParametersController>();
    return $.listFromJson(
      request,
      await $parseBodyAs(
        request,
        (data) => (data! as List<dynamic>).map((data) {
          return Decimal.fromJson(data! as String);
        }).toList(),
      ),
    );
  })
  ..add('POST', r'/mapNum', (Request request) async {
    final $ = request.get<PathParametersController>();
    return $.mapNum(
      request,
      await $parseBodyAs(
        request,
        (data) => (data! as Map<String, dynamic>).map((k, data) {
          return MapEntry(k, data! as num);
        }),
      ),
    );
  })
  ..add('POST', r'/mapFromJson', (Request request) async {
    final $ = request.get<PathParametersController>();
    return $.mapFromJson(
      request,
      await $parseBodyAs(
        request,
        (data) => (data! as Map<String, dynamic>).map((k, data) {
          return MapEntry(k, Decimal.fromJson(data! as String));
        }),
      ),
    );
  });

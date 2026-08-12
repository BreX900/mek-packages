// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unnecessary_raw_strings

part of 'body_parameters.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$PathParametersControllerRouter(PathParametersController service) =>
    Router()
      ..add('POST', '/integer', (Request request) async {
        return service.integer(
          request,
          await $readBodyAs(request, (data) => data! as int),
        );
      })
      ..add('POST', '/fromJson', (Request request) async {
        return service.fromJson(
          request,
          await $readBodyAs(
            request,
            (data) => Decimal.fromJson(data! as String),
          ),
        );
      })
      ..add('POST', '/listDouble', (Request request) async {
        return service.listDouble(
          request,
          await $readBodyAs(
            request,
            (data) => (data! as List<dynamic>).map((data) {
              return data! as double;
            }).toList(),
          ),
        );
      })
      ..add('POST', '/listFromJson', (Request request) async {
        return service.listFromJson(
          request,
          await $readBodyAs(
            request,
            (data) => (data! as List<dynamic>).map((data) {
              return Decimal.fromJson(data! as String);
            }).toList(),
          ),
        );
      })
      ..add('POST', '/mapNum', (Request request) async {
        return service.mapNum(
          request,
          await $readBodyAs(
            request,
            (data) => (data! as Map<String, dynamic>).map((k, data) {
              return MapEntry(k, data! as num);
            }),
          ),
        );
      })
      ..add('POST', '/mapFromJson', (Request request) async {
        return service.mapFromJson(
          request,
          await $readBodyAs(
            request,
            (data) => (data! as Map<String, dynamic>).map((k, data) {
              return MapEntry(k, Decimal.fromJson(data! as String));
            }),
          ),
        );
      });

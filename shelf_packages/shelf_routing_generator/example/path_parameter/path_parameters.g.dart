// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unnecessary_raw_strings

part of 'path_parameters.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$PathParametersControllerRouter(PathParametersController service) => Router()
  ..add('GET', '/<integer>', (Request request, String $integer) async {
    return service.fetchMessages(request, int.parse($integer));
  })
  ..add('POST', '/<string>', (Request request, String $string) async {
    return service.createMessage(request, $string);
  })
  ..add('PUT', '/<decimal>', (Request request, String $decimal) async {
    return service.updateMessage(request, Decimal.parse($decimal));
  });

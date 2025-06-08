// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unnecessary_raw_strings

part of 'path_parameters.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

Router get _$pathParametersControllerRouter => Router()
  ..add('GET', r'/<integer>', (Request request, String integer) async {
    final $ = request.get<PathParametersController>();
    return $.fetchMessages(request, int.parse(integer));
  })
  ..add('POST', r'/<string>', (Request request, String string) async {
    final $ = request.get<PathParametersController>();
    return $.createMessage(request, string);
  })
  ..add('PUT', r'/<decimal>', (Request request, String decimal) async {
    final $ = request.get<PathParametersController>();
    return $.updateMessage(request, Decimal.parse(decimal));
  });

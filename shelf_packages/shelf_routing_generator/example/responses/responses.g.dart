// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unnecessary_raw_strings

part of 'responses.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

Router get _$responsesControllerRouter => Router()
  ..add('GET', r'/sync', (Request request) async {
    final $ = request.get<ResponsesController>();
    return $.sync(
      request,
    );
  })
  ..add('POST', r'/async', (Request request) async {
    final $ = request.get<ResponsesController>();
    return await $.async(
      request,
    );
  })
  ..add('PUT', r'/json', (Request request) async {
    final $ = request.get<ResponsesController>();
    final $data = await $.json(
      request,
    );
    return JsonResponse.ok($data);
  })
  ..add('HEAD', r'/json-dto', (Request request) async {
    final $ = request.get<ResponsesController>();
    final $data = await $.jsonClass(
      request,
    );
    return JsonResponse.ok($data);
  })
  ..add('DELETE', r'/json-response', (Request request) async {
    final $ = request.get<ResponsesController>();
    return await $.jsonResponse(
      request,
    );
  });

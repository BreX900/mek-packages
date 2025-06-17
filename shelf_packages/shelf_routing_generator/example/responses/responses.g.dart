// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unnecessary_raw_strings

part of 'responses.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$ResponsesControllerRouter(ResponsesController service) => Router()
  ..add('GET', '/sync', (Request request) async {
    return service.sync(request);
  })
  ..add('POST', '/async', (Request request) async {
    return await service.async(request);
  })
  ..add('PUT', '/json', (Request request) async {
    final body = await service.json(request);
    return JsonResponse.ok(body);
  })
  ..add('HEAD', '/json-dto', (Request request) async {
    final body = await service.jsonClass(request);
    return JsonResponse.ok(body);
  })
  ..add('DELETE', '/json-response', (Request request) async {
    return await service.jsonResponse(request);
  });

// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable

part of 'files_controller.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$FilesControllerRouter(FilesController service) => Router()
  ..add('GET', '/', (Request request) async {
    final data = await service.download(request);
    return Response.ok(data);
  })
  ..add('GET', '/via-response', (Request request) async {
    return await service.downloadViaResponse(request);
  })
  ..add('POST', '/', (Request request) async {
    await service.upload(request, request.read());
    return Response.ok(null);
  });

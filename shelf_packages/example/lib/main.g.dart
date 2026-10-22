// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable

part of 'main.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$ApiControllerRouter(ApiController service) => Router()
  ..mount('/api-v1/chats', service.chats.router.call)
  ..mount('/api-v1/messages', service.messages.router.call)
  ..mount('/api-v1/files', service.files.router.call)
  ..mount('/api-v1/collections', service.collections.router.call);

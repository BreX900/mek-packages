// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$ApiControllerRouter(ApiController service) => Router()
  ..mount('/api-v1/chats', service.chats.router.call)
  ..mount('/api-v1/messages', service.messages.router.call);

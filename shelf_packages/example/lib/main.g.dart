// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$ApiControllerRouter(ApiController service) => Router()
  ..mount('/v1', service.chats.router.call)
  ..mount('/v1', service.messages.router.call);

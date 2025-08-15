// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$ApiControllerRouter(ApiController service) {
  final router = Router();
  router.mount(r'/api-v1/chats', service.chats.call);
  router.mount(r'/api-v1/messages', service.messages.call);
  return router;
}

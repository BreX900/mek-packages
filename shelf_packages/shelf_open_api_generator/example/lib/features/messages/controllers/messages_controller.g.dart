// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$MessagesControllerRouter(MessagesController service) {
  final router = Router();
  router.add('GET', r'/', service.fetchMessages);
  router.add('GET', r'/<messageId>', service.fetchMessage);
  return router;
}

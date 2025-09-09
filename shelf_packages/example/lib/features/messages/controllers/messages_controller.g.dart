// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_controller.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$MessagesControllerRouter(MessagesController service) => Router()
  ..add('GET', '/', (Request request) async {
    return await service.fetchMessages(request);
  })
  ..add('GET', '/<messageId>', (Request request, String $messageId) async {
    return await service.fetchMessage(request, int.parse($messageId));
  });

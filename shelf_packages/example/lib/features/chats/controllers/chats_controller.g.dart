// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_controller.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$ChatsControllerRouter(ChatsController service) => Router()
  ..add('POST', '/chats', (Request request) async {
    return await service.createChatForReport(request);
  })
  ..add('POST', '/chats', (Request request) async {
    return await service.createChatForReportV2(
      request,
      await $parseBodyAs(
        request,
        (data) => ChatCreateDto.fromJson(data! as Map<String, dynamic>),
      ),
    );
  });

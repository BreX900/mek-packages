// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_controller.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$ChatsControllerRouter(ChatsController service) => Router()
  ..add('POST', '/', (Request request) async {
    return await service.createChatForReport(request);
  })
  ..add('PUT', '/', (Request request) async {
    return await service.createChatForReportV2(
      request,
      await $readBodyAs(
        request,
        (data) => ChatCreateDto.fromJson(data! as Map<String, dynamic>),
      ),
    );
  })
  ..add('PUT', '/', (Request request) async {
    return await service.batchChats(
      request,
      await $readBodyAs(
        request,
        (data) => (data! as List<dynamic>).map((data) {
          return ChatCreateDto.fromJson(data! as Map<String, dynamic>);
        }).toList(),
      ),
    );
  });

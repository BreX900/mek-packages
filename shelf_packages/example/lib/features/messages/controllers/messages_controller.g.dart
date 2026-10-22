// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable

part of 'messages_controller.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$MessagesControllerRouter(MessagesController service) => Router()
  ..add('GET', '/', (Request request) async {
    return await service.fetchMessages(
      request,
      pageNumber: $parseQueryParameters(
        request,
        'pageNumber',
        (data) => int.parse(data.single),
        defaultValue: 1,
      ),
      pageSize: $parseQueryParameters(
        request,
        'pageSize',
        (data) => int.parse(data.single),
        defaultValue: 100,
      ),
      sortedBy: $parseQueryParameters(
        request,
        'sortedBy',
        (data) => data.isNotEmpty ? data.single : null,
      ),
      descending: $parseQueryParameters(
        request,
        'descending',
        (data) => bool.parse(data.single),
      ),
    );
  })
  ..add('GET', '/<messageId>', (Request request, String $messageId) async {
    return await service.fetchMessage(request, int.parse($messageId));
  });

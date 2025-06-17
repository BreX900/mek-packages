// ignore_for_file: always_use_package_imports
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api.g.dart';

class Api {
  Api({required this.client});

  final Dio client;

  /// fetchMessages
  Future<List<MessageDto>> fetchMessages({required String chatId}) async {
    final _queryParameters = <String, Object?>{
      'chatId': chatId,
    };
    final _response = await client.get('/v1/messages', queryParameters: _queryParameters);
    return switch (_response.statusCode) {
      200 => (_response.data as List<Object?>)
          .map((e) => MessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      _ => throw DioException.badResponse(
          statusCode: _response.statusCode!,
          requestOptions: _response.requestOptions,
          response: _response,
        ),
    };
  }

  /// createChatForReport
  Future<void> createChatForReport(ChatCreateDto _request) async {
    final _data = _request.toJson();
    final _response = await client.post('/v1/chats', data: _data);
    return switch (_response.statusCode) {
      200 => null,
      _ => throw DioException.badResponse(
          statusCode: _response.statusCode!,
          requestOptions: _response.requestOptions,
          response: _response,
        ),
    };
  }
}

@JsonSerializable()
class MessageDto {
  const MessageDto({
    required this.chatId,
    required this.content,
  });

  final String chatId;

  final String content;

  static MessageDto fromJson(Map<String, dynamic> map) => _$MessageDtoFromJson(map);
  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}

@JsonSerializable()
class ChatCreateDto {
  const ChatCreateDto({required this.title});

  final String title;

  static ChatCreateDto fromJson(Map<String, dynamic> map) => _$ChatCreateDtoFromJson(map);
  Map<String, dynamic> toJson() => _$ChatCreateDtoToJson(this);
}

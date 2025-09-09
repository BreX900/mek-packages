// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
      chatId: json['chatId'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) => <String, dynamic>{
      'chatId': instance.chatId,
      'content': instance.content,
    };

ChatCreateDto _$ChatCreateDtoFromJson(Map<String, dynamic> json) => ChatCreateDto(
      title: json['title'] as String,
    );

Map<String, dynamic> _$ChatCreateDtoToJson(ChatCreateDto instance) => <String, dynamic>{
      'title': instance.title,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_create_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCreateDto _$ChatCreateDtoFromJson(Map<String, dynamic> json) => ChatCreateDto(
  title: json['title'] as String,
  visibility: $enumDecode(_$ChatVisibilityEnumMap, json['visibility']),
);

const _$ChatVisibilityEnumMap = {ChatVisibility.private: 'private', ChatVisibility.public: 'open'};

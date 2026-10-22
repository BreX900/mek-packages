// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable

part of 'chat_create_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCreateDto _$ChatCreateDtoFromJson(Map<String, dynamic> json) =>
    ChatCreateDto(
      title: json['title'] as String,
      visibility: $enumDecode(_$ChatVisibilityEnumMap, json['visibility']),
      type: ChatType.fromJson(json['type'] as String),
    );

const _$ChatVisibilityEnumMap = {
  ChatVisibility.private: 'private',
  ChatVisibility.public: 'open',
};

const _$ChatTypeEnumMap = {
  ChatType.private: 'PV',
  ChatType.channel: 'CH',
  ChatType.group: 'GR',
};

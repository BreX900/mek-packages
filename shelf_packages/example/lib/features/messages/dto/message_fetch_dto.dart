import 'package:json_annotation/json_annotation.dart';

part 'message_fetch_dto.g.dart';

@JsonSerializable(createToJson: false)
class MessageFetchDto {
  final String chatId;

  const MessageFetchDto({
    required this.chatId,
  });

  factory MessageFetchDto.fromJson(Map<String, dynamic> map) => _$MessageFetchDtoFromJson(map);
}

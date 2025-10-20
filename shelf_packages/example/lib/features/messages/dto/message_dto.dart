import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable(createFactory: false)
class MessageDto {
  final String chatId;
  @JsonKey(name: 'description')
  final String content;
  final MessageDto? parent;

  const MessageDto({required this.chatId, required this.content, required this.parent});

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}

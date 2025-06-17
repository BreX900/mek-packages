import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable(createFactory: false)
class MessageDto {
  final String chatId;
  final String content;

  const MessageDto({
    required this.chatId,
    required this.content,
  });

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}

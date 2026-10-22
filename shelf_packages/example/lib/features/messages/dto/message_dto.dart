import 'package:example/shared/date.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable(createFactory: false)
class MessageDto {
  final String chatId;
  @JsonKey(name: 'description')
  final String content;
  final Date sentAt;
  final Date? receivedAt;
  final MessageDto? parent;

  const MessageDto({
    required this.chatId,
    required this.content,
    required this.sentAt,
    required this.receivedAt,
    required this.parent,
  });

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}

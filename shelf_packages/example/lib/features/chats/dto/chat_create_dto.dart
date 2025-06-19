import 'package:json_annotation/json_annotation.dart';

part 'chat_create_dto.g.dart';

enum ChatVisibility {
  private,
  @JsonValue('open')
  public,
}

@JsonSerializable(createToJson: false)
class ChatCreateDto {
  final String title;
  final ChatVisibility visibility;

  const ChatCreateDto({required this.title, required this.visibility});

  factory ChatCreateDto.fromJson(Map<String, dynamic> map) => _$ChatCreateDtoFromJson(map);
}

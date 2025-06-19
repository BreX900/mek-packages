import 'package:json_annotation/json_annotation.dart';

part 'chat_create_dto.g.dart';

@JsonSerializable(createToJson: false)
class ChatCreateDto {
  final String title;

  const ChatCreateDto({required this.title});

  factory ChatCreateDto.fromJson(Map<String, dynamic> map) => _$ChatCreateDtoFromJson(map);
}

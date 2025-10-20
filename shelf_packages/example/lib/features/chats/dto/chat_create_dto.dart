import 'package:json_annotation/json_annotation.dart';

part 'chat_create_dto.g.dart';

enum ChatVisibility {
  private,
  @JsonValue('open')
  public,
}

@JsonEnum(valueField: 'code')
enum ChatType {
  private('PV'),
  channel('CH'),
  group('GR');

  final String code;

  const ChatType(this.code);
}

@JsonSerializable(createToJson: false)
class ChatCreateDto {
  final String title;
  final ChatVisibility visibility;
  final ChatType type;

  const ChatCreateDto({required this.title, required this.visibility, required this.type});

  factory ChatCreateDto.fromJson(Map<String, dynamic> map) => _$ChatCreateDtoFromJson(map);
}

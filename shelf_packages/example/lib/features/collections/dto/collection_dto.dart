import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:json_annotation/json_annotation.dart';

part 'collection_dto.g.dart';

@JsonSerializable()
class CollectionDto {
  final String title;
  final IList<DocumentDto> documents;

  const CollectionDto({required this.title, required this.documents});

  factory CollectionDto.fromJson(Map<String, dynamic> map) => _$CollectionDtoFromJson(map);
  Map<String, dynamic> toJson() => _$CollectionDtoToJson(this);
}

@JsonSerializable()
class DocumentDto {
  final String id;

  const DocumentDto({required this.id});

  factory DocumentDto.fromJson(Map<String, dynamic> map) => _$DocumentDtoFromJson(map);
  Map<String, dynamic> toJson() => _$DocumentDtoToJson(this);
}

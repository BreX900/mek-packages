// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable

part of 'collection_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionDto _$CollectionDtoFromJson(Map<String, dynamic> json) =>
    CollectionDto(
      title: json['title'] as String,
      documents: IList<DocumentDto>.fromJson(
        json['documents'],
        (value) => DocumentDto.fromJson(value as Map<String, dynamic>),
      ),
    );

Map<String, dynamic> _$CollectionDtoToJson(CollectionDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'documents': instance.documents.toJson((value) => value),
    };

DocumentDto _$DocumentDtoFromJson(Map<String, dynamic> json) =>
    DocumentDto(id: json['id'] as String);

Map<String, dynamic> _$DocumentDtoToJson(DocumentDto instance) =>
    <String, dynamic>{'id': instance.id};

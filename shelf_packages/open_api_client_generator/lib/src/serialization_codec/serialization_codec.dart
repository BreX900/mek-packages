import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/api_specs.dart';
import 'package:open_api_client_generator/src/collection_codecs/collection_codec.dart';

abstract class SerializationCodec {
  final CollectionCodec collectionCodec;

  const SerializationCodec({required this.collectionCodec});

  String encodeDeserialization(Reference type, String varAccess);

  String encodeSerialization(Reference type, String varAccess);

  Class buildDataClass(ApiClass spec);

  Enum buildDataEnum(ApiEnum spec);
}

import 'package:code_builder/code_builder.dart';
import 'package:open_api_specification/open_api_spec.dart';

abstract class TypeCodec {
  const TypeCodec();

  Reference get reference;

  bool acceptSchema(SchemaOpenApi schema);

  bool acceptReference(Reference other) =>
      other.symbol == reference.symbol && other.url == reference.url;
}

abstract class JsonSerializableTypeCodec extends TypeCodec {
  const JsonSerializableTypeCodec();

  String encodeSerialization(String varAccess) => '$varAccess.toJson()';

  String encodeDeserialization(String varAccess) => '${reference.symbol}.fromJson($varAccess)';
}

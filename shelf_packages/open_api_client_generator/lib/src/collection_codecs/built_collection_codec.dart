import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/collection_codecs/collection_codec.dart';

class BuiltCollectionCodec extends CollectionCodecBase {
  const BuiltCollectionCodec();

  @override
  String get package => 'built_collection/built_collection.dart';

  @override
  String encodeToPackage(Reference type) {
    if (type.isList) return '.toBuiltList()';
    if (type.isMap) return '.toBuiltMap()';
    return '';
  }

  @override
  String encodeToCore(Reference type) {
    if (type.isList) return '.toList()';
    if (type.isMap) return '.asMap()';
    return '';
  }

  @override
  String onMapTypeSymbol(Reference reference) {
    if (reference.isList) return 'BuiltList';
    if (reference.isMap) return 'BuiltMap';
    return reference.symbol!;
  }
}

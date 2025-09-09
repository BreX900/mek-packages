import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/collection_codecs/collection_codec.dart';

class FastImmutableCollectionCodec extends CollectionCodecBase {
  const FastImmutableCollectionCodec();

  @override
  String get package => 'fast_immutable_collections/fast_immutable_collections.dart';

  @override
  String encodeToPackage(Reference type) {
    if (type.isList) return '.toIList()';
    if (type.isMap) return '.toIMap()';
    return '';
  }

  @override
  String encodeToCore(Reference type) {
    final questionOrEmpty = type.isNullable ? '?' : '';
    if (type.isList) return '$questionOrEmpty.toList()';
    if (type.isMap) return '$questionOrEmpty.unlockView';
    return '';
  }

  @override
  String onMapTypeSymbol(Reference reference) {
    if (reference.isList) return 'IList';
    if (reference.isMap) return 'IMap';
    return reference.symbol!;
  }
}

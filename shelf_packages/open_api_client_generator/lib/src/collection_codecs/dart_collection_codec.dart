import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/collection_codecs/collection_codec.dart';

class DartCollectionCodec extends CollectionCodec {
  const DartCollectionCodec();

  @override
  String encodeToPackage(Reference type) {
    if (type.isList) return '.toList()';
    return '';
  }

  @override
  String encodeToCore(Reference type) {
    // if (type.isList) return '.toList()';
    return '';
  }
}

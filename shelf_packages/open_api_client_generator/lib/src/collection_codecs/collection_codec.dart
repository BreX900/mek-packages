import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/plugins/plugin.dart';
import 'package:open_api_specification/open_api_spec.dart';

abstract class CollectionCodec {
  const CollectionCodec();

  String encodeToPackage(Reference type);

  String encodeToCore(Reference type);
}

abstract class CollectionCodecBase extends CollectionCodec with Plugin {
  const CollectionCodecBase();

  String get package;

  String onMapTypeSymbol(Reference reference);

  @override
  Class onDataClass(SchemaOpenApi schema, Class spec) {
    return spec.rebuild((b) => b..fields.map((e) => e.rebuild((b) => b..type = _mapType(b.type))));
  }

  @override
  Class onApiClass(OpenApi openApi, Class spec) {
    return spec.rebuild((b) => b
      ..methods.map((e) {
        return e.rebuild((b) => b
          ..returns = _mapType(b.returns)
          ..requiredParameters.map((e) {
            return e.rebuild((b) => b..type = _mapType(b.type));
          })
          ..optionalParameters.map((e) {
            return e.rebuild((b) => b..type = _mapType(b.type));
          }));
      }));
  }

  @override
  Library onLibrary(OpenApi openApi, Library spec) {
    return spec.rebuild((b) => b..directives.add(Directive.import('package:$package')));
  }

  Reference _mapType(Reference? reference) {
    reference!;
    final types = reference.types.map(_mapType);
    if (reference.isList) {
      return reference.rebuild((b) => b
        ..symbol = onMapTypeSymbol(reference)
        ..types.replace(types));
    }
    if (reference.isMap) {
      return reference.rebuild((b) => b
        ..symbol = onMapTypeSymbol(reference)
        ..types.replace(types));
    }
    if (reference.types.isNotEmpty) return reference.rebuild((b) => b..types.replace(types));
    return reference;
  }
}

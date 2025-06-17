import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/api_specs.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/collection_codecs/built_collection_codec.dart';
import 'package:open_api_client_generator/src/plugins/plugin.dart';
import 'package:open_api_client_generator/src/serialization_codec/serialization_codec.dart';
import 'package:open_api_specification/open_api_spec.dart';

class BuiltValueSerializationCodec extends SerializationCodec with Plugin {
  BuiltValueSerializationCodec({super.collectionCodec = const BuiltCollectionCodec()});

  var _factories = <Reference>[];

  @override
  String encodeDeserialization(Reference type, String varAccess) {
    if (!type.isJsonPrimitive) _factories.add(type);
    return '_serializers.deserialize($varAccess, ${type.symbol!})';
  }

  @override
  String encodeSerialization(Reference type, String varAccess) {
    if (!type.isJsonPrimitive) _factories.add(type);
    return '_serializers.deserialize($varAccess, ${type.symbol!})';
  }

  @override
  Class buildDataClass(ApiClass spec) {
    return spec.toSpec((b) => b
      ..extend = TypeReference((b) => b
        ..symbol = 'Built'
        ..types.add(Reference(spec.name))
        ..types.add(Reference('${spec.name}Builder')))
      ..methods.addAll(spec.fields.map((e) {
        final wireName = _resolveWireName(e.name, e.key);

        return Method((b) => b
          ..annotations.addAll([
            if (wireName != null) CodeExpression(Code("BuiltField(wireName: '${e.key}')")),
          ])
          ..returns = e.type
          ..type = MethodType.getter
          ..name = e.name);
      })));
  }

  @override
  Enum buildDataEnum(ApiEnum spec) {
    return spec.toSpec((b) => b
      ..values.addAll(spec.values.map((e) {
        final wireName = _resolveWireName(e.name, e.value);

        return e.toSpec((b) => b
          ..annotations.addAll([
            if (wireName != null) CodeExpression(Code("BuiltField(wireName: '$wireName')")),
          ]));
      })));
  }

  @override
  Library onLibrary(OpenApi openApi, Library spec) {
    return spec.rebuild((b) => b
      ..directives.add(Directive.import('package:json_annotation/json_annotation.dart'))
      ..body.add(Field((b) => b
        ..type = const Reference('Serializers')
        ..name = '_serializers'
        ..assignment = const Code(r'_$_serializers'))));
  }

  @override
  void onFinish() {
    _factories = [];
  }

  String? _resolveWireName(String original, String target) {
    return target == original ? null : target;
  }
}

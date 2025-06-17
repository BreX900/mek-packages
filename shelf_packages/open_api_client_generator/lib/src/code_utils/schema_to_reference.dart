import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/options/context.dart';
import 'package:open_api_specification/open_api_spec.dart';

extension SchemaToRef on ContextMixin {
  Reference ref(SchemaOpenApi schema) {
    if (schema.isEnum) return Reference(codecs.encodeType(schema.name!));

    switch (schema.format) {
      case FormatOpenApi.int32:
      case FormatOpenApi.int64:
        return References.int;
      case FormatOpenApi.float:
      case FormatOpenApi.double:
        return References.double;
      case FormatOpenApi.string:
        return References.string;
      case FormatOpenApi.date:
      case FormatOpenApi.dateTime:
        return References.dateTime;
      case FormatOpenApi.uuid:
      case FormatOpenApi.email:
        return References.string;

      case FormatOpenApi.url:
      case FormatOpenApi.uri:
        return References.uri;
      case FormatOpenApi.binary:
      case FormatOpenApi.base64:
        // TODO: Handle this case.
        break;
      case null:
        break;
    }

    switch (schema.type) {
      case TypeOpenApi.boolean:
        return References.bool;
      case TypeOpenApi.integer:
        return References.int;
      case TypeOpenApi.number:
        return References.num;
      case TypeOpenApi.string:
        return References.string;
      case TypeOpenApi.array:
        return References.list(ref(schema.items!));
      case TypeOpenApi.object:
        if (schema.name != null) return Reference(codecs.encodeType(schema.name!));

        return References.map(
          key: References.string,
          value: schema.additionalProperties != null ? ref(schema.additionalProperties!) : null,
        );
      case null:
        return References.jsonValue;
    }
  }
}

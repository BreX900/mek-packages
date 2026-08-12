import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/api_specs.dart';
import 'package:open_api_client_generator/src/code_utils/document.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/options/context.dart';
import 'package:open_api_specification/open_api_spec.dart';

class BuildSchemaClass with ContextMixin {
  @override
  final Context context;

  BuildSchemaClass({required this.context});

  final _cache = <String, _CacheEntry>{};

  Iterable<ApiSpec> get apiSpecs => _cache.values.map((e) => e.spec);

  Reference call(String name, SchemaOrRef schemaOrRef) {
    final schema = schemaOrRef.resolve(components);
    name = switch (schemaOrRef) {
      SchemaOpenApi() => schema.name ?? schema.title ?? name,
      SchemaRef() => schemaOrRef.ref.split('/').last,
    };

    final cacheEntry = _cache[name];
    if (cacheEntry != null) return cacheEntry.type;

    final builtSchema = _build(name, schema);

    final newCacheEntry = builtSchema.toCache();
    if (newCacheEntry != null) _cache[name] = newCacheEntry;

    return builtSchema.type;
  }

  _BuiltSchema _build(String name, SchemaOpenApi schema) {
    for (final codec in context.typeCodecs) {
      if (codec.acceptSchema(schema)) return _BuiltSchema(type: codec.reference);
    }

    final docs = Docs.format(
      Docs.documentClass(description: schema.description, example: schema.example),
    );

    if (schema.isEnum) {
      final values = schema.enum$!;
      final enumName = codecs.encodeType(name);

      return _BuiltSchema(
        type: Reference(enumName),
        spec: ApiEnum(
          schema: schema,
          docs: docs,
          name: enumName,
          values: values.map((value) {
            return ApiEnumValue(name: codecs.encodeEnumValue(value), value: '$value');
          }).toList(),
        ),
      );
    }

    switch (schema.format) {
      case FormatOpenApi.int32:
      case FormatOpenApi.int64:
        return const _BuiltSchema(type: References.int);
      case FormatOpenApi.float:
      case FormatOpenApi.double:
        return const _BuiltSchema(type: References.double);
      case FormatOpenApi.string:
        return const _BuiltSchema(type: References.string);
      case FormatOpenApi.date:
      case FormatOpenApi.dateTime:
        return const _BuiltSchema(type: References.dateTime);
      case FormatOpenApi.uuid:
      case FormatOpenApi.email:
      case FormatOpenApi.decimal:
        return const _BuiltSchema(type: References.string);

      case FormatOpenApi.url:
      case FormatOpenApi.uri:
        return const _BuiltSchema(type: References.uri);
      case FormatOpenApi.binary:
      case FormatOpenApi.base64:
        // TODO: Handle this case.
        break;
      case null:
        break;
    }

    switch (schema.type) {
      case TypeOpenApi.boolean:
        return const _BuiltSchema(type: References.boolean);
      case TypeOpenApi.integer:
        return const _BuiltSchema(type: References.int);
      case TypeOpenApi.number:
        return const _BuiltSchema(type: References.num);
      case TypeOpenApi.string:
        return const _BuiltSchema(type: References.string);
      case TypeOpenApi.array:
        final itemsReference = call(name, schema.items!);
        return _BuiltSchema(
          type: (schema.uniqueItems ?? false)
              ? References.set(itemsReference)
              : References.list(itemsReference),
        );
      case TypeOpenApi.object:
        if (schema.isClass) {
          final allOf = (schema.allOf ?? []).map((schema) => call('Unknown', schema));

          final className = codecs.encodeType(name);

          return _BuiltSchema(
            type: Reference(className).toNullable(schema.nullable),
            spec: ApiClass(
              schema: schema,
              docs: docs,
              name: className,
              implements: allOf.map((reference) => reference.symbol!).toList(),
              fields: (schema.properties ?? {}).entries.map((entry) {
                final MapEntry(key: name, value: propertySchema) = entry;
                final resolvedPropertySchema = propertySchema.resolve(components);

                return ApiField(
                  key: name,
                  docs: const [], // TODO:  prop.docs ??
                  isRequired: schema.isRequired(name),
                  type: call(
                    name,
                    propertySchema,
                  ).toNullable(schema.canNull(name, resolvedPropertySchema)),
                  name: codecs.encodeName(name),
                );
              }).toList(),
            ),
          );
        }

        return _BuiltSchema(
          type: References.map(
            key: References.string,
            value: schema.additionalProperties != null
                ? call(name, schema.additionalProperties!)
                : null,
          ),
        );
      case null:
        return _BuiltSchema(type: References.jsonValue);
    }
  }
}

class _CacheEntry {
  final Reference type;
  final ApiSpec spec;

  const _CacheEntry({required this.type, required this.spec});
}

class _BuiltSchema {
  final Reference type;
  final ApiSpec? spec;

  const _BuiltSchema({required this.type, this.spec});

  _CacheEntry? toCache() {
    final spec = this.spec;
    if (spec == null) return null;
    return _CacheEntry(type: type, spec: spec);
  }
}

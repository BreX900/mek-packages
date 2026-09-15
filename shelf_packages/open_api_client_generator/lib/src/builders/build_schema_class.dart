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

  final _cache = <String, ApiSpec?>{};

  Iterable<ApiSpec> get apiSpecs => _cache.values.nonNulls;

  Reference build(String name, SchemaOrRef schemaOrRef) {
    final schema = schemaOrRef.resolve(components);
    switch (schemaOrRef) {
      case SchemaOpenApi():
        name = codecs.encodeType(schema.name ?? schema.title ?? name);

        final builtSchema = _build(name, schema);
        if (builtSchema.spec case final spec?) _cache[name] = spec;

        return builtSchema.type;

      case SchemaRef():
        name = schemaOrRef.ref.split('/').last;

        if (!_cache.containsKey(name)) {
          _cache[name] = null;
          if (_build(name, schema).spec case final spec?) {
            _cache[name] = spec;
          } else {
            _cache.remove(name);
          }
        }

        return Reference(name);
    }
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

      return _BuiltSchema(
        type: Reference(name),
        spec: ApiEnum(
          schema: schema,
          docs: docs,
          name: name,
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
        final itemsReference = build(name, schema.items!);
        return _BuiltSchema(
          type: (schema.uniqueItems ?? false)
              ? References.set(itemsReference)
              : References.list(itemsReference),
        );
      case TypeOpenApi.object:
        if (schema.isClass) {
          final SchemaOpenApi(:discriminator) = schema;
          final allOf = (schema.allOf ?? []).map((schema) => build('Unknown', schema));

          List<ApiField> resolveField(SchemaOrRef schemaOrRef) {
            final schema = schemaOrRef.resolve(components);

            final properties = (schema.properties ?? {}).entries.map((__) {
              final MapEntry(key: name, value: propertySchemaOrRef) = __;
              final propertySchema = propertySchemaOrRef.resolve(components);

              return ApiField(
                key: name,
                docs: const [], // TODO:  prop.docs ??
                isRequired: schema.isRequired(name),
                type: build(
                  name,
                  propertySchemaOrRef,
                ).toNullable(schema.canNull(name, propertySchema)),
                name: codecs.encodeName(name),
              );
            });

            return [
              for (final schemaOrRef in schema.allOf ?? <SchemaOrRef>[])
                for (final field in resolveField(schemaOrRef.resolve(components)))
                  if (properties.every((e) => field.name != e.name)) field,
              ...properties,
            ];
          }

          ApiDiscriminator? apiDiscriminator;
          if (discriminator != null) {
            apiDiscriminator = ApiDiscriminator(
              name: discriminator.propertyName,
              mapping: discriminator.mapping,
            );
            for (final name in discriminator.mapping.values) {
              build(name, SchemaRef.from(name));
            }
          }

          return _BuiltSchema(
            type: Reference(name).toNullable(schema.nullable),
            spec: ApiClass(
              discriminator: apiDiscriminator,
              schema: schema,
              docs: docs,
              name: name,
              implements: allOf.map((reference) => reference.symbol!).toList(),
              fields: resolveField(schema),
            ),
          );
        }

        return _BuiltSchema(
          type: References.map(
            key: References.string,
            value: schema.additionalProperties != null
                ? build(name, schema.additionalProperties!)
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

  _CacheEntry({required this.type, required this.spec});
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

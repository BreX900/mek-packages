import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/api_specs.dart';
import 'package:open_api_client_generator/src/code_utils/document.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';
import 'package:open_api_client_generator/src/code_utils/schema_to_reference.dart';
import 'package:open_api_client_generator/src/options/context.dart';
import 'package:open_api_specification/open_api_spec.dart';

class BuildSchemaClass with ContextMixin {
  @override
  final Context context;

  BuildSchemaClass({
    required this.context,
  });

  final _cache = <String, _CacheEntry>{};

  Iterable<ApiSpec> get apiSpecs => _cache.values.map((e) => e.spec);

  Reference call(String name, SchemaOpenApi schema) {
    // ignore: parameter_assignments
    name = schema.name ?? name;

    final cacheEntry = _cache[name];
    if (cacheEntry != null) return cacheEntry.type;

    final builtSchema = _build(name, schema);

    final newCacheEntry = builtSchema.toCache();
    if (newCacheEntry != null) _cache[name] = newCacheEntry;

    builtSchema.children.forEach(call);

    return builtSchema.type;
  }

  _BuiltSchema _build(String name, SchemaOpenApi schema) {
    final docs = Docs.format(Docs.documentClass(
      description: schema.description,
      example: schema.example,
    ));

    final items = schema.items;
    if (items != null) {
      return _BuiltSchema(
        // docs: docs.followedBy(built.docs ?? const []),
        type: ref(schema),
        children: {name: items},
      );
    }

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
            return ApiEnumValue(
              name: codecs.encodeEnumValue(value),
              value: '$value',
            );
          }).toList(),
        ),
      );
    }

    if (schema.isClass) {
      final properties = schema.allProperties;
      final allOf = schema.allOf ?? const [];
      final implements = allOf.where((e) => e.name != null).toList();
      final implementsNames = implements.map((e) => codecs.encodeType(e.name!)).toList();

      final className = codecs.encodeType(name);

      return _BuiltSchema(
        type: Reference(className).toNullable(schema.nullable),
        spec: ApiClass(
          schema: schema,
          docs: docs,
          name: className,
          implements: implementsNames,
          fields: properties.entries.map((entry) {
            final MapEntry(key: name, value: prop) = entry;

            return ApiField(
              key: name,
              docs: const [], // TODO:  prop.docs ??
              isRequired: schema.isRequired(name),
              type: ref(prop).toNullable(schema.canNull(name, properties[name]!)),
              name: codecs.encodeName(name),
            );
          }).toList(),
        ),
        children: {...Map.fromEntries(implements.map((e) => MapEntry(e.name!, e))), ...properties},
      );
    }
    final reference = ref(schema);
    if (!reference.isDartCore) {
      // ignore: avoid_print
      print('$name $schema');
    }

    return _BuiltSchema(
      // docs: docs,
      type: reference,
    );
  }
}

class _CacheEntry {
  final Reference type;
  final ApiSpec spec;

  const _CacheEntry({
    required this.type,
    required this.spec,
  });
}

class _BuiltSchema {
  final Reference type;
  final ApiSpec? spec;
  final Map<String, SchemaOpenApi> children;

  const _BuiltSchema({
    required this.type,
    this.spec,
    this.children = const {},
  });

  _CacheEntry? toCache() {
    final spec = this.spec;
    if (spec == null) return null;
    return _CacheEntry(type: type, spec: spec);
  }
}

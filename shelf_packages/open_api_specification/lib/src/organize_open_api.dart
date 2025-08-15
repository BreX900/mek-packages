Map<String, dynamic> organizeOpenApi(Map<String, dynamic> document) {
  final schemas = <String, dynamic>{};

  Map<String, dynamic> resolveSchema(Map<String, dynamic> schema) {
    final properties = schema['properties'] as Map<String, dynamic>? ?? const {};
    final items = schema['items'] as Map<String, dynamic>?;
    schema = {
      ...schema,
      if (properties.isNotEmpty)
        'properties': properties.map((key, value) {
          return MapEntry(key, resolveSchema(value as Map<String, dynamic>));
        }),
      if (items != null) 'items': resolveSchema(items),
    };

    final title = schema['title'] as String?;
    if (title != null) {
      schemas[title] = schema;
      return {r'$ref': '#/components/schemas/$title'};
    }
    return schema;
  }

  Map<String, dynamic> resolveMedia(Map<String, dynamic> data) {
    return data.map((key, content) {
      if (key == 'content') {
        content as Map<String, dynamic>?;
        return MapEntry(
          key,
          content?.map((type, media) {
            media as Map<String, dynamic>?;
            return MapEntry(
              type,
              media?.map((key, value) {
                if (key == 'schema')
                  return MapEntry(key, resolveSchema(value as Map<String, dynamic>));
                return MapEntry(key, value);
              }),
            );
          }),
        );
      }
      return MapEntry(key, content);
    });
  }

  return {
    ...document,
    'paths': (document['paths'] as Map<String, dynamic>).map((path, endPoint) {
      final newEndpoint = (endPoint as Map<String, dynamic>).map((operationId, operation) {
        operation as Map<String, dynamic>;
        final requestBody = operation['requestBody'] as Map<String, dynamic>?;
        final responses = operation['responses'] as Map<String, dynamic>?;

        return MapEntry(operationId, {
          ...operation,
          if (requestBody != null) 'requestBody': resolveMedia(requestBody),
          if (responses != null)
            'responses': responses.map((code, media) {
              return MapEntry(code, resolveMedia(media));
            }),
        });
      });
      return MapEntry(path, newEndpoint);
    }),
    if (schemas.isNotEmpty) 'components': {'schemas': schemas},
  };
}

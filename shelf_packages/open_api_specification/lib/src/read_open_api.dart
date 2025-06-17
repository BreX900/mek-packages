import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart' as path_;
import 'package:yaml/yaml.dart';

path_.Context get _uri => path_.url;

Future<Map<dynamic, dynamic>> readOpenApi(Uri uri) async {
  if (uri.isScheme('HTTP') || uri.isScheme('HTTPS')) {
    final response = await get(uri);
    final content = response.body;
    return _parseContent(uri.path, content);
  } else {
    final path = _uri.fromUri(uri);
    final content = File(path).readAsStringSync();
    return _parseContent(path, content);
  }
}

const _sentinelCache = <String, Map<dynamic, dynamic>>{};

Future<Map<dynamic, dynamic>> readOpenApiWithRefs(
  Uri input, {
  Map<String, Map<dynamic, dynamic>>? cache = _sentinelCache,
}) async {
  cache = cache == _sentinelCache ? <String, Map<dynamic, dynamic>>{} : cache;

  final data = await readOpenApi(input);

  final document = await _resolveDocumentRefs(input, data, data, cache: cache);
  return {...document! as Map<dynamic, dynamic>}..remove('parameters');
}

Future<Object?> _resolveDocumentRefs(
  Uri input,
  Map<dynamic, dynamic> document,
  Object? data, {
  required Map<String, Map<dynamic, dynamic>>? cache,
}) async {
  if (data is List<dynamic>) {
    return await Future.wait<dynamic>(data.map((element) async {
      return await _resolveDocumentRefs(input, document, element, cache: cache);
    }));
  } else if (data is Map<dynamic, dynamic>) {
    final ref = data[r'$ref'] as String?;
    if (ref != null) return await readRef(input, document, ref, cache: cache);

    return Map<dynamic, dynamic>.fromEntries(await Future.wait(data.entries.map((e) async {
      final MapEntry(:key, :value) = e;
      return MapEntry(key, await _resolveDocumentRefs(input, document, value, cache: cache));
    })));
  } else {
    return data;
  }
}

Future<Map<dynamic, dynamic>> readRef(
  Uri uri,
  Map<dynamic, dynamic> document,
  String ref, {
  Map<String, Map<dynamic, dynamic>>? cache,
}) async {
  Map<dynamic, dynamic>? pendingData;
  if (cache != null) {
    pendingData = cache[ref];
    if (pendingData != null) return pendingData;
    cache[ref] = pendingData = {};
  }

  final index = ref.indexOf('#');
  final documentRef = index != -1 ? ref.substring(index + 2) : null;
  final fileRef = index != 0 ? ref.substring(0, index == -1 ? null : index) : null;

  if (fileRef != null) {
    final parent = _uri.dirname(uri.path);
    uri = uri.replace(path: _uri.normalize(_uri.join(parent, fileRef)));
    document = await readOpenApiWithRefs(uri);
  }

  var data = document;
  if (documentRef != null) {
    final segments = documentRef.split('/');
    for (final segment in segments) {
      data = data[segment] as Map<dynamic, dynamic>;
    }
    if (!data.containsKey('name')) data = {'name': segments.last, ...data};
  }

  final resolvedData = await _resolveDocumentRefs(uri, document, data, cache: cache);

  if (pendingData != null) {
    pendingData.addAll(resolvedData! as Map<dynamic, dynamic>);
    return pendingData;
  } else {
    return resolvedData! as Map<dynamic, dynamic>;
  }
}

Map<dynamic, dynamic> _parseContent(String path, String content) {
  final extension = _uri.extension(path);
  if (const {'.yaml', '.yml'}.contains(extension)) {
    return loadYaml(content);
  } else if (extension == '.json') {
    return jsonDecode(content);
  } else {
    throw StateError('Not support file $extension');
  }
}

abstract final class FilesContents {
  static const String webApiClient = r'''
// ignore_for_file: always_use_package_imports

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'api_client.dart';
import 'dart_api_client.dart';

DartApiClient createDartApiClient() => WebApiClient();

class WebApiClient extends ApiClient implements DartApiClient {
  WebApiClient();

  @override
  Future<ApiClientResponse> onSend(ApiClientRequest request) async {
    final platformRequest = HttpRequest()
      ..open(request.method, '${request.uri}')
      ..responseType = 'arraybuffer';

    request.headers.forEach((key, value) => platformRequest.setRequestHeader(key, value.join(',')));

    final completer = Completer<ApiClientResponse>();

    unawaited(platformRequest.onLoad.first.then((_) {
      final body = (platformRequest.response as ByteBuffer).asUint8List();
      completer.complete(ApiClientResponse(
        request: request,
        statusCode: platformRequest.status!,
        headers:
            platformRequest.responseHeaders.map((key, value) => MapEntry(key, value.split(','))),
        data: jsonDecode(utf8.decode(body)),
      ));
    }));

    unawaited(platformRequest.onError.first.then((_) {
      // Unfortunately, the underlying XMLHttpRequest API doesn't expose any
      // specific information about the error itself.
      completer.completeError('XMLHttpRequest error.', StackTrace.current);
    }));

    platformRequest.send(utf8.encode(jsonEncode(request.data)));

    return await completer.future;
  }
}

''';
  static const String ioApiClient = '''
// ignore_for_file: always_use_package_imports

import 'dart:convert';
import 'dart:io';

import 'api_client.dart';
import 'dart_api_client.dart';

DartApiClient createDartApiClient() => IoApiClient();

class IoApiClient extends ApiClient implements DartApiClient {
  final HttpClient httpClient;

  IoApiClient([HttpClient? httpClient]) : httpClient = httpClient ?? HttpClient();

  @override
  Future<ApiClientResponse> onSend(ApiClientRequest request) async {
    final platformRequest = await httpClient.openUrl(request.method, request.uri);

    request.headers.forEach((key, value) {
      platformRequest.headers.set(key, value);
    });
    platformRequest.add(utf8.encode(jsonEncode(request.data)));

    final response = await platformRequest.close();
    final responseHeaders = <String, List<String>>{};
    response.headers.forEach((name, values) => responseHeaders[name] = values);

    return ApiClientResponse(
      request: request,
      statusCode: response.statusCode,
      headers: responseHeaders,
      data: jsonDecode(await utf8.decodeStream(response)),
    );
  }
}

''';
  static const String httpApiClient = '''
// ignore_for_file: always_use_package_imports

import 'dart:convert';

import 'package:http/http.dart';

import 'api_client.dart';

class HttpApiClient extends ApiClient {
  final Client httpClient;

  HttpApiClient([Client? httpClient]) : httpClient = httpClient ?? Client();

  @override
  Future<ApiClientResponse> onSend(ApiClientRequest request) async {
    final response = await httpClient
        .send(Request(request.method, request.uri)..body = jsonEncode(request.data));

    return ApiClientResponse(
      request: request,
      statusCode: response.statusCode,
      headers: response.headers.map((key, value) => MapEntry(key, value.split(','))),
      data: jsonDecode(await response.stream.bytesToString()),
    );
  }
}

''';
  static const String apiClient = '''
import 'dart:async';

abstract class ApiClient {
  final interceptors = <ApiClientInterceptor>[];

  Future<ApiClientResponse> send(
    String method,
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) async {
    var request = ApiClientRequest(
      method: method,
      path: path,
      headers: const {},
      queryParameters: queryParameters ?? const {},
      data: data ?? const {},
    );
    for (final interceptor in interceptors) {
      request = await interceptor.onRequest(request);
    }
    var response = await onSend(request);
    for (final interceptor in interceptors) {
      response = await interceptor.onResponse(response);
    }
    return response;
  }

  Future<ApiClientResponse> onSend(ApiClientRequest request);
}

class ApiClientInterceptor {
  FutureOr<ApiClientRequest> onRequest(ApiClientRequest request) => request;
  FutureOr<ApiClientResponse> onResponse(ApiClientResponse response) => response;
}

class ApiClientRequest {
  final String method;
  final String path;
  final Map<String, List<String>> headers;
  final Map<String, dynamic> queryParameters;
  final Object? data;

  Uri get uri => Uri.parse(path).replace(queryParameters: queryParameters);

  const ApiClientRequest({
    required this.method,
    required this.path,
    required this.headers,
    required this.queryParameters,
    required this.data,
  });
}

class ApiClientResponse {
  final ApiClientRequest request;
  final int statusCode;
  final Map<String, List<String>> headers;
  final Object? data;

  const ApiClientResponse({
    required this.request,
    required this.statusCode,
    required this.headers,
    required this.data,
  });
}

class ApiClientException implements Exception {
  final ApiClientResponse response;

  const ApiClientException({
    required this.response,
  });

  factory ApiClientException.of(ApiClientResponse response) =>
      ApiClientException(response: response);
}

''';
  static const String dartApiClient = '''
// ignore_for_file: always_use_package_imports

import 'api_client.dart';
import 'io_api_client.dart' if (dart.html) 'web_api_client.dart';

abstract interface class DartApiClient implements ApiClient {
  factory DartApiClient() => createDartApiClient();
}

''';
}

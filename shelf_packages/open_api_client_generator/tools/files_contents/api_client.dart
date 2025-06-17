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

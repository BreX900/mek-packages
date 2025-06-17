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

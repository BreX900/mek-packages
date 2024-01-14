// ignore_for_file: comment_references

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

/// The json response returned by a [Handler].
class JsonResponse<T> extends Response {
  /// Constructs an HTTP response with the given [statusCode].
  ///
  /// [statusCode] must be greater than or equal to 100.
  JsonResponse(
    super.statusCode, {
    Object? body,
    Map<String, /* String | List<String> */ Object>? headers,
    super.context,
  }) : super(body: _bindBody(body), headers: _bindHeaders(headers));

  /// Constructs a 200 OK response.
  ///
  /// This indicates that the request has succeeded.
  JsonResponse.ok(
    T? body, {
    Map<String, /* String | List<String> */ Object>? headers,
    super.context,
  }) : super.ok(_bindBody(body), headers: _bindHeaders(headers));

  /// Constructs a 301 Moved Permanently response.
  ///
  /// This indicates that the requested resource has moved permanently to a new
  /// URI. [location] is that URI; it can be either a [String] or a [Uri]. It's
  /// automatically set as the Location header in [headers].
  JsonResponse.movedPermanently(
    super.location, {
    Object? body,
    Map<String, /* String | List<String> */ Object>? headers,
    super.context,
  }) : super.movedPermanently(body: _bindBody(body), headers: _bindHeaders(headers));

  /// Constructs a 302 Found response.
  ///
  /// This indicates that the requested resource has moved temporarily to a new
  /// URI. [location] is that URI; it can be either a [String] or a [Uri]. It's
  /// automatically set as the Location header in [headers].
  JsonResponse.found(
    super.location, {
    Object? body,
    Map<String, /* String | List<String> */ Object>? headers,
    super.context,
  }) : super.found(body: _bindBody(body), headers: _bindHeaders(headers));

  /// Constructs a 304 Not Modified response.
  ///
  /// This is used to respond to a conditional GET request that provided
  /// information used to determine whether the requested resource has changed
  /// since the last request. It indicates that the resource has not changed and
  /// the old value should be used.
  ///
  /// [headers] must contain values that are either `String` or `List<String>`.
  /// An empty list will cause the header to be omitted.
  ///
  /// If [headers] contains a value for `content-length` it will be removed.
  JsonResponse.notModified({super.headers, super.context}) : super.notModified();

  /// Constructs a 400 Bad Request response.
  ///
  /// This indicates that the server has received a malformed request.
  JsonResponse.badRequest({
    Object? body,
    Map<String, /* String | List<String> */ Object>? headers,
    super.context,
  }) : super.badRequest(body: _bindBody(body ?? 'Bad Request'), headers: _bindHeaders(headers));

  /// Constructs a 401 Unauthorized response.
  ///
  /// This indicates indicates that the client request has not been completed
  /// because it lacks valid authentication credentials.
  JsonResponse.unauthorized(
    Object? body, {
    Map<String, /* String | List<String> */ Object>? headers,
    super.context,
  }) : super.unauthorized(_bindBody(body ?? 'Unauthorized'), headers: _bindHeaders(headers));

  /// Constructs a 403 Forbidden response.
  ///
  /// This indicates that the server is refusing to fulfill the request.
  JsonResponse.forbidden(
    Object? body, {
    Map<String, /* String | List<String> */ Object>? headers,
    super.context,
  }) : super.forbidden(_bindBody(body ?? 'Forbidden'), headers: _bindHeaders(headers));

  /// Constructs a 404 Not Found response.
  ///
  /// This indicates that the server didn't find any resource matching the
  /// requested URI.
  JsonResponse.notFound(
    Object? body, {
    Map<String, /* String | List<String> */ Object>? headers,
    super.context,
  }) : super.notFound(_bindBody(body ?? 'Not Found'), headers: _bindHeaders(headers));

  /// Constructs a 500 Internal Server Error response.
  ///
  /// This indicates that the server had an internal error that prevented it
  /// from fulfilling the request.
  JsonResponse.internalServerError({
    Object? body,
    Map<String, /* String | List<String> */ Object>? headers,
    super.context,
  }) : super.internalServerError(
            body: _bindBody(body ?? 'Internal Server Error'), headers: _bindHeaders(headers));
}

final _encoder = JsonUtf8Encoder();

Object? _bindBody(Object? body) => _encoder.bind(Stream.value(body));

Map<String, /* String | List<String> */ Object> _bindHeaders(
  Map<String, /* String | List<String> */ Object>? headers,
) {
  return {...?headers, HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'};
}

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Request createRequest({
  required Object controller,
  required Route route,
  Map<String, dynamic>? queryParameters,
}) {
  T getter<T extends Object>(Request request) => controller as T;

  return Request(
    route.verb,
    Uri.https('example.com', route.route, queryParameters),
    context: {'_getter': getter},
  );
}

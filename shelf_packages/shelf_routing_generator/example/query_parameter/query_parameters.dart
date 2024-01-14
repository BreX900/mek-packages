import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

part 'query_parameters.g.dart';

class QueryParametersController {
  static Router get router => _$queryParametersControllerRouter;

  const QueryParametersController();

  @Route.get('/single')
  Response single(
    Request request, {
    required int integer,
    double? double,
    required String string,
    String? stringOrNull,
    DateTime? customParser,
  }) {
    // ...
    return Response.ok(null);
  }

  @Route.get('/list')
  Response list(
    Request request, {
    required List<String> stringList,
    required List<int> integerList,
    required List<DateTime> customParserList,
  }) {
    // ...
    return Response.ok(null);
  }
}

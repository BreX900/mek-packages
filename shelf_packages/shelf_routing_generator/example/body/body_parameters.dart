import 'package:decimal/decimal.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

part 'body_parameters.g.dart';

class PathParametersController {
  static Router get router => _$pathParametersControllerRouter;

  const PathParametersController();

  @Route.post('/integer')
  Response integer(Request request, int integer) {
    // ...
    return Response.ok(null);
  }

  @Route.post('/fromJson')
  Response fromJson(Request request, Decimal decimal) {
    // ...
    return Response.ok(null);
  }

  @Route.post('/listDouble')
  Response listDouble(Request request, List<double> values) {
    // ...
    return Response.ok(null);
  }

  @Route.post('/listFromJson')
  Response listFromJson(Request request, List<Decimal> decimal) {
    // ...
    return Response.ok(null);
  }

  @Route.post('/mapNum')
  Response mapNum(Request request, Map<String, num> values) {
    // ...
    return Response.ok(null);
  }

  @Route.post('/mapFromJson')
  Response mapFromJson(Request request, Map<String, Decimal> decimal) {
    // ...
    return Response.ok(null);
  }
}

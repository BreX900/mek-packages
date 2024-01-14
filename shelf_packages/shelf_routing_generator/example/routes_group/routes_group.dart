import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

import 'route_group.dart';

part 'routes_group.g.dart';

class RoutesGroupController {
  static Router get router => _$routesGroupControllerRouter;

  const RoutesGroupController();

  @Route.get('/')
  Response sync(Request request) {
    // ...
    return Response.ok(null);
  }
}

@RoutableV1(prefix: '/example')
class RoutesGroupWithPrefixController {
  static Router get router => _$routesGroupWithPrefixControllerRouter;

  const RoutesGroupWithPrefixController();

  @Route.get('/')
  Response sync(Request request) {
    // ...
    return Response.ok(null);
  }
}

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

part 'routes_group.g.dart';

class RoutesGroupController implements RouterMixin {
  @override
  Router get router => _$RoutesGroupControllerRouter(this);

  const RoutesGroupController();

  @Route.get('/')
  Response sync(Request request) {
    // ...
    return Response.ok(null);
  }
}

class RoutesGroupWithPrefixController implements RouterMixin {
  @override
  Router get router => _$RoutesGroupWithPrefixControllerRouter(this);

  const RoutesGroupWithPrefixController();

  @Route.get('/')
  Response sync(Request request) {
    // ...
    return Response.ok(null);
  }
}

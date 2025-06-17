import 'package:shelf_router/shelf_router.dart';

import 'routes_group.dart';

part 'route_group.g.dart';

class ApiController {
  Router get router => _$ApiControllerRouter(this);

  @Route.mount('/')
  RoutesGroupController get route => const RoutesGroupController();

  @Route.mount('/example')
  RoutesGroupWithPrefixController get example => const RoutesGroupWithPrefixController();
}

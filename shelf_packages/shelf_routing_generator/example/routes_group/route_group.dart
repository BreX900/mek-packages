import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

import 'routes_group.dart';

part 'route_group.g.dart';

class RoutableV1 extends Routable {
  const RoutableV1({String? prefix}) : super(prefix: '/v1${prefix ?? ''}');
}

@GenerateRouterFor([RoutesGroupController, RoutesGroupWithPrefixController])
Router get v1Router => _$v1Router;

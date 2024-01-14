# Shelf Routing
Shelf makes it easy to build web applications in Dart by composing request handlers. The shelf_routing package offers a request router for Shelf. this package enables generating a shelf_router.Router from annotations in code.

This package should be a development dependency along with package build_runner, and used with package shelf and package shelf_routing as dependencies.

```yaml
dependencies:
  shelf: ^0.7.5
  shelf_router: ^0.7.0+1
dev_dependencies:
  shelf_router_generator: ^0.7.0+1
  build_runner: ^1.3.1
```
Once your code have been annotated as illustrated in the example below the generated part can be created with pub run build_runner build.

Example
```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

// generated with 'pub run build_runner build'
import 'example.routers.dart';


// generated with 'pub run build_runner build'
part 'example.g.dart';

class User {
  final int id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> map) => User(id: map['id'], name: map['name']);
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

@Routable(prefix: '/users')
class UserController {
  // Create router using the generate function defined in 'example.g.dart'.
  static Router get router => _$userControllerRouter;

  final DatabaseConnection connection;

  UserController(this.connection);

  @Route.get('/')
  Future<List<dynamic>> listUsers(Request request, {String? query}) async {
    return ['user1'];
  }

  @Route.get('/<userId>')
  Future<Response> fetchUser(Request request, int userId) async {
    if (userId == 1) {
      return Response.ok('user1');
    }
    return Response.notFound('no such user');
  }

  @Route.post('/')
  Future<JsonResponse<User>> createUser(Request request, User user) async {
    if (user.name.isEmpty) {
      return JsonResponse.badRequest(body: 'Missing name field');
    }
    return JsonResponse.ok(user);
  }
}

// Create router using the generate function defined in 'example.g.dart'.
@GenerateRouterFor([UserController])
Router get apiRouter => _$apiRouter;

void main() async {
  // You can setup context, database connections, cache connections, email
  // services, before you create an instance of your service.
  final connection = await DatabaseConnection.connect('localhost:1234');

  // Define a function to inject your controllers.
  // You can use the get_it package.
  T get<T extends Object>(Request request) {
    return UserController(connection) as T;
  }

  // Service request using the router, note the router can also be mounted.
  final handler = const Pipeline().addMiddleware(getterMiddleware(get)).addHandler(apiRouter);
  await serve(handler, 'localhost', 8080);
}
```

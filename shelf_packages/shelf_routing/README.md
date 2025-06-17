# Shelf Routing
Shelf makes it easy to build web applications in Dart by composing request handlers.
The shelf_routing package offers a request router for Shelf.
This package enables generating a shelf_router.Router from annotations in code.

This package should be a development dependency along with package build_runner,
and used with package shelf and package shelf_routing as dependencies.

```yaml
dependencies:
  shelf:
  shelf_router:
  shelf_routing: 
dev_dependencies:
  build_runner:
  shelf_routing_generator: 
```
Once your code have been annotated as illustrated in the example below the generated part can be created with pub run build_runner build.

Example
```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

// generated with 'dart run build_runner build'
part 'example.g.dart';

class User {
  final int id;
  final String name;

  const User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> map) => User(id: map['id'], name: map['name']);
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class UserController implements RouterMixin {
  // Create router using the generate function defined in 'example.g.dart'.
  @override
  Router get router => _$UserControllerRouter(this);

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

class ApiRouter {
  static const _prefix = '/api';

  final DatabaseConnection connection;

  ApiRouter(this.connection);

  Router get router => _$ApiRouterRouter(this);

  @Route.mount('$_prefix/users')
  UserController get users => UserController(connection);
}

class DatabaseConnection {
  static Future<DatabaseConnection> connect(String _) => throw UnimplementedError();
}

void main() async {
  // You can setup context, database connections, cache connections, email
  // services, before you create an instance of your service.
  final connection = await DatabaseConnection.connect('localhost:1234');

  // Service request using the router, note the router can also be mounted.
  final handler = const Pipeline().addHandler(ApiRouter(connection).router);
  await serve(handler, 'localhost', 8080);
}
```

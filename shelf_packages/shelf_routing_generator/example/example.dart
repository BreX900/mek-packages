// ignore_for_file: unreachable_from_main

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

// generated with 'pub run build_runner build'
part 'example.g.dart';

class User {
  final int id;
  final String name;

  const User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> map) => User(id: map['id'], name: map['name']);
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class UserController implements RouterMixin {
  // // Create router using the generate function defined in 'example.g.dart'.
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

// Create router using the generate function defined in 'example.g.dart'.
// @GenerateRouterFor([UserController])
// Router get apiRouter => _$apiRouter;

const _prefix = '/api';

class ApiRouter {
  final DatabaseConnection connection;

  ApiRouter(this.connection);

  Router get router => _$ApiRouterRouter(this);

  @Route.mount('$_prefix/users')
  UserController get users => UserController(connection);
}

class DatabaseConnection {
  static Future<DatabaseConnection> connect(String _) => throw UnimplementedError();
}

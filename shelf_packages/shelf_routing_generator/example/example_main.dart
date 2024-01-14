import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_routing/shelf_routing.dart';

import 'example.dart';

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
  final handler = const Pipeline().addMiddleware(GetterMiddleware(get)).addHandler(apiRouter);
  await serve(handler, 'localhost', 8080);
}

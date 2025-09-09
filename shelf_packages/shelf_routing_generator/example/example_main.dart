import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'example.dart';

void main() async {
  // You can setup context, database connections, cache connections, email
  // services, before you create an instance of your service.
  final connection = await DatabaseConnection.connect('localhost:1234');

  // Service request using the router, note the router can also be mounted.
  final handler = const Pipeline().addHandler(ApiRouter(connection).router);
  await serve(handler, 'localhost', 8080);
}

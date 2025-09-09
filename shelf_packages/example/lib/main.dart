import 'dart:convert';
import 'dart:io';

import 'package:example/features/chats/controllers/chats_controller.dart';
import 'package:example/features/messages/controllers/messages_controller.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

part 'main.g.dart';

void main() async {
  final data = File('public/main.json').readAsStringSync();

  OpenApi.fromJson(jsonDecode(data));

  final rootRouter = Router()
    ..mount('/', const ApiController().call)
    ..mount('/swagger', SwaggerUI(data, title: 'Swagger Example Api v2'))
    ..mount('/', createStaticHandler('public'));

  // Configure a pipeline.
  final handler = const Pipeline().addHandler(rootRouter);

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;
  // For running in containers, we respect the PORT environment variable.
  final server = await serve(handler, ip, 8080);

  final url = 'http://${server.address.address}:${server.port}';
  // ignore: avoid_print
  print('Server listening on $url -> Swagger: $url/swagger');
}

@OpenApiFile()
class ApiController {
  static const _version = '/api-v1';

  const ApiController();

  Router get router => _$ApiControllerRouter(this);

  @Route.mount('$_version/chats')
  ChatsController get chats => const ChatsController();
  @Route.mount('$_version/messages')
  MessagesController get messages => const MessagesController();

  Future<Response> call(Request request) => router.call(request);
}

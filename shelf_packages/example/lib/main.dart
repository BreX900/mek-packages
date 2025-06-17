import 'dart:convert';
import 'dart:io';

import 'package:example/features/chats/controllers/chats_controller.dart';
import 'package:example/features/messages/controllers/messages_controller.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';
import 'package:yaml/yaml.dart';

part 'main.g.dart';

void main() async {
  final data = loadYaml(File('public/open_api.yaml').readAsStringSync());

  final rootRouter = Router()
    ..mount('/', const ApiController().call)
    ..mount('/swagger', SwaggerUI(_yamlToJson(data), title: 'Swagger Example Api'))
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

String _yamlToJson(Object? data) {
  return jsonEncode(
    data,
    toEncodable: (data) {
      if (data is Map<dynamic, dynamic>) return data.map((k, v) => MapEntry('$k', v));
      return data;
    },
  );
}

@OpenApi()
class ApiController {
  const ApiController();

  Router get router => _$ApiControllerRouter(this);

  @Route.mount('/v1')
  ChatsController get chats => const ChatsController();
  @Route.mount('/v1')
  MessagesController get messages => const MessagesController();

  Future<Response> call(Request request) => router.call(request);
}

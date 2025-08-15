import 'package:example/features/chats/dto/chat_create_dto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'chats_controller.g.dart';

class ChatsController {
  const ChatsController();

  Router get router => _$ChatsControllerRouter(this);

  @Route.post('/')
  @OpenApiRouteHttp(requestBody: ChatCreateDto)
  Future<Response> createChatForReport(Request request) async {
    // ...

    return Response.ok(null);
  }

  @Route.put('/')
  Future<Response> createChatForReportV2(Request request) async {
    // ...

    return Response.ok(null);
  }
}

import 'package:example/features/messages/dto/message_dto.dart';
import 'package:example/features/messages/dto/message_fetch_dto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'messages_controller.g.dart';

class MessagesController {
  const MessagesController();

  Router get router => _$MessagesControllerRouter(this);

  @Route.get('/')
  @OpenApiRouteHttp(requestQuery: MessageFetchDto, responseBody: List<MessageDto>)
  Future<Response> fetchMessages(Request request) async {
    // ...

    return Response.ok(null);
  }

  @Route.get('/<messageId>')
  @OpenApiRouteHttp(responseBody: List<MessageDto>)
  Future<Response> fetchMessage(Request request, String messageId) async {
    // ...

    return Response.ok(null);
  }
}

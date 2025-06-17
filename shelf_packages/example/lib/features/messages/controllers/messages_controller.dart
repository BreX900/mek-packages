import 'package:example/features/messages/dto/message_dto.dart';
import 'package:example/features/messages/dto/message_fetch_dto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

part 'messages_controller.g.dart';

class MessagesController with RouterMixin {
  const MessagesController();

  @override
  Router get router => _$MessagesControllerRouter(this);

  @Route.get('/')
  @OpenApiRoute(requestQuery: MessageFetchDto)
  Future<JsonResponse<List<MessageDto>>> fetchMessages(Request request) async {
    // ...

    return JsonResponse.ok(null);
  }

  @Route.get('/<messageId>')
  Future<JsonResponse<List<MessageDto>>> fetchMessage(Request request, int messageId) async {
    // ...

    return JsonResponse.ok(null);
  }

  Future<Response> call(Request request) => router.call(request);
}

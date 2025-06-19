import 'package:example/features/chats/dto/chat_create_dto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

part 'chats_controller.g.dart';

class ChatsController with RouterMixin {
  const ChatsController();

  @override
  Router get router => _$ChatsControllerRouter(this);

  @Route.post('/')
  @OpenApiRouteHttp(requestBody: ChatCreateDto)
  Future<JsonResponse<void>> createChatForReport(Request request) async {
    // ...

    return JsonResponse.ok(null);
  }

  @Route.put('/')
  Future<JsonResponse<void>> createChatForReportV2(Request request, ChatCreateDto data) async {
    // ...

    return JsonResponse.ok(null);
  }

  @Route.put('/')
  Future<JsonResponse<void>> batchChats(Request request, List<ChatCreateDto> data) async {
    // ...

    return JsonResponse.ok(null);
  }

  Future<Response> call(Request request) => router.call(request);
}

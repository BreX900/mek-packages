import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

part 'responses.g.dart';

class ResponsesController {
  static Router get router => _$responsesControllerRouter;

  const ResponsesController();

  @Route.get('/sync')
  Response sync(Request request) {
    // ...
    return Response.ok(null);
  }

  @Route.post('/async')
  Future<Response> async(Request request) async {
    // ...
    return Response.ok(null);
  }

  @Route.put('/json')
  Future<List<dynamic>> json(Request request) async {
    // ...
    return [1, 2, 3, 4];
  }

  @Route.head('/json-dto')
  Future<Dto> jsonClass(Request request) async {
    // ...
    return const Dto(value: 'value');
  }

  @Route.delete('/json-response')
  Future<JsonResponse<String>> jsonResponse(Request request) async {
    // ...
    return JsonResponse.ok('value');
  }
}

class Dto {
  final String value;

  const Dto({
    required this.value,
  });

  Map<String, dynamic> toJson() => {'value': value};
}

import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

part 'files_controller.g.dart';

class FilesController with RouterMixin {
  const FilesController();

  @override
  Router get router => _$FilesControllerRouter(this);

  @Route.get('/')
  Future<Stream<Uint8List>> download(Request request) async {
    return const Stream.empty();
  }

  @Route.get('/via-response')
  Future<Response> downloadViaResponse(Request request) async {
    // ...

    return Response.ok(null);
  }

  @Route.post('/')
  Future<void> upload(Request request, Stream<List<int>> bytesStream) async {
    // ...
  }
}

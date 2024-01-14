import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '_utils.dart';

void main() {
  test('parsing headers', () async {
    const source = r'''
  import 'package:shelf/shelf.dart';
  import 'package:shelf_router/shelf_router.dart';
  import 'package:shelf_routing/shelf_routing.dart';
  
  part 'example.g.dart';
  
  class Controller {
    static Router get router => _$ControllerRouter;
  
    @RouteHeader(name: 'authorization')
    @Route.get('/get')
    Response get(Request request) => throw UnimplementedError();
  }''';

    final code = await testRouterBuilder(source: source);

    expect(code, r'''
Router get _$controllerRouter => Router()
  ..add('GET', r'/get', (Request request) async {
    $ensureHasHeader(request, 'authorization');
    final $ = request.get<Controller>();
    return $.get(
      request,
    );
  });''');
  });
}

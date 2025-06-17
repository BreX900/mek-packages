import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../../example/responses/responses.dart';
import '../_utils.dart';

class _MockResponsesController extends Mock implements ResponsesController {}

class _FakeRequest extends Fake implements Request {}

void main() {
  late _MockResponsesController controller;

  setUp(() {
    controller = _MockResponsesController();

    registerFallbackValue(_FakeRequest());
  });

  tearDown(resetMocktailState);

  group('responses tests', () {
    test('sync handler', () async {
      when(() => controller.sync(any())).thenReturn(Response.ok(null));

      final request = createRequest(controller: controller, route: const Route.get('/'));
      final response = await const ResponsesController().router.call(request);

      expect(response.statusCode, 200);

      verify(() => controller.sync(any()));
    });

    test('async handler', () async {
      when(() => controller.async(any())).thenAnswer((_) async => Response.ok(null));

      final request = createRequest(controller: controller, route: const Route.post('/'));
      final response = await const ResponsesController().router.call(request);

      expect(response.statusCode, 200);

      verify(() => controller.async(any()));
    });
  });
}

import 'package:decimal/decimal.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../../example/path_parameter/path_parameters.dart';
import '../_utils.dart';

class _MockPathParametersController extends Mock implements PathParametersController {}

class _FakeRequest extends Fake implements Request {}

void main() {
  late _MockPathParametersController controller;

  setUp(() {
    controller = _MockPathParametersController();

    registerFallbackValue(_FakeRequest());

    throwOnMissingStub(controller, exceptionBuilder: (_) => Response.ok(null));
  });

  tearDown(resetMocktailState);

  group('path parameters tests', () {
    test('integer path parameter', () async {
      final request = createRequest(controller: controller, route: const Route.get('/1'));
      final response = await PathParametersController.router.call(request);

      expect(response.statusCode, 200);

      verify(() => controller.fetchMessages(any(), 1));
    });

    test('string path parameter', () async {
      final request = createRequest(controller: controller, route: const Route.post('/text'));
      final response = await PathParametersController.router.call(request);

      expect(response.statusCode, 200);

      verify(() => controller.createMessage(any(), 'text'));
    });

    test('decimal path parameter', () async {
      final request = createRequest(controller: controller, route: Route.put('/${Decimal.one}'));
      final response = await PathParametersController.router.call(request);

      expect(response.statusCode, 200);

      verify(() => controller.updateMessage(any(), Decimal.one));
    });
  });
}

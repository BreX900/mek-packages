// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unnecessary_raw_strings

part of 'example.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$UserControllerRouter(UserController service) => Router()
  ..add('GET', '/', (Request request) async {
    final body = await service.listUsers(
      request,
      query: $parseQueryParameters(
        request,
        'query',
        (vls) => vls.isNotEmpty ? vls.single : null,
      ),
    );
    return JsonResponse.ok(body);
  })
  ..add('GET', '/<userId>', (Request request, String $userId) async {
    return await service.fetchUser(request, int.parse($userId));
  })
  ..add('POST', '/', (Request request) async {
    return await service.createUser(
      request,
      await $parseBodyAs(
        request,
        (data) => User.fromJson(data! as Map<String, dynamic>),
      ),
    );
  });

Router _$ApiRouterRouter(ApiRouter service) =>
    Router()..mount('/api/users', service.users.router.call);

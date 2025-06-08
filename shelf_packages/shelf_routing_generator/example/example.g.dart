// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unnecessary_raw_strings

part of 'example.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

Router get _$userControllerRouter => Router()
  ..add('GET', r'/', (Request request) async {
    final $ = request.get<UserController>();
    final $data = await $.listUsers(
      request,
      query: $parseQueryParameters(request, 'query', (vls) => vls.isNotEmpty ? vls.single : null),
    );
    return JsonResponse.ok($data);
  })
  ..add('GET', r'/<userId>', (Request request, String userId) async {
    final $ = request.get<UserController>();
    return await $.fetchUser(request, int.parse(userId));
  })
  ..add('POST', r'/', (Request request) async {
    final $ = request.get<UserController>();
    return await $.createUser(request, await $readBodyAs(request, User.fromJson));
  });

// **************************************************************************
// GroupsRouterGenerator
// **************************************************************************

Router get _$apiRouter => Router()..mount('/users', UserController.router);

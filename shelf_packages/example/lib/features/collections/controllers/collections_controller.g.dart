// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable

part of 'collections_controller.dart';

// **************************************************************************
// RoutingGenerator
// **************************************************************************

Router _$CollectionsControllerRouter(CollectionsController service) => Router()
  ..add('GET', '/', (Request request) async {
    final data = await service.fetchCollections(
      request,
      languages: $parseQueryParameters(
        request,
        'languages',
        (data) => ISet.fromJson(data, (data) => data as String),
        defaultValue: const ISet.empty(),
      ),
      conditions: $parseQueryParameters(
        request,
        'conditions',
        (data) =>
            ISet.fromJson(data, (data) => ChatType.fromJson(data as String)),
        defaultValue: const ISet.empty(),
      ),
      languagesNullable: $parseQueryParameters(
        request,
        'languagesNullable',
        (data) => ISet.fromJson(data, (data) => data as String),
      ),
      conditionsNullable: $parseQueryParameters(
        request,
        'conditionsNullable',
        (data) =>
            ISet.fromJson(data, (data) => ChatType.fromJson(data as String)),
      ),
    );
    return JsonResponse.ok(data.toJson((data) => data.toJson()));
  })
  ..add('PUT', '/', (Request request) async {
    await service.createCollections(
      request,
      await $readBodyAs(
        request,
        (data) => IList<CollectionDto>.fromJson(
          data! as dynamic,
          (data) => CollectionDto.fromJson(data! as Map<String, dynamic>),
        ),
      ),
    );
    return Response.ok(null);
  });

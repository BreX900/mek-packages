import 'package:example/features/chats/dto/chat_create_dto.dart';
import 'package:example/features/collections/dto/collection_dto.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';

part 'collections_controller.g.dart';

class CollectionsController with RouterMixin {
  const CollectionsController();

  @override
  Router get router => _$CollectionsControllerRouter(this);

  @Route.get('/')
  Future<IList<CollectionDto>> fetchCollections(
    Request request, {
    ISet<String> languages = const ISet.empty(),
    ISet<ChatType> conditions = const ISet.empty(),
    required ISet<String> languagesNullable,
    required ISet<ChatType> conditionsNullable,
  }) async {
    // ...

    return const IList.empty();
  }

  @Route.put('/')
  Future<void> createCollections(Request request, IList<CollectionDto> data) async {
    // ...
  }
}

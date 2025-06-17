import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:shelf_open_api_generator/src/config.dart';
import 'package:shelf_open_api_generator/src/handlers/route_handler.dart';
import 'package:shelf_open_api_generator/src/schemas_registry.dart';
import 'package:shelf_open_api_generator/src/utils/doc.dart';
import 'package:shelf_open_api_generator/src/utils/utils.dart';

class RoutesHandler {
  final Config config;
  final SchemasRegistry schemasRegistry;
  final List<RouteHandler> routes;

  RoutesHandler({required this.config, required this.schemasRegistry, required this.routes});

  OpenApi buildOpenApi() {
    final routesInPaths = routes.groupListsBy((e) => e.path);

    return OpenApi(
      openapi: '3.0.0',
      info: _buildInfoSpecs(),
      servers: [_buildServerSpecs()],
      paths: routesInPaths.map((path, routes) {
        final item = ItemPathOpenApi.from(
          operations: routes.toMap((route) {
            final operation = route.buildOperation();
            return MapEntry(route.method, operation);
          }),
        );
        return MapEntry(path, item);
      }),
      components: ComponentsOpenApi(securitySchemes: config.securitySchemes),
      tags: _buildTags(),
    );
  }

  InfoOpenApi _buildInfoSpecs() {
    return InfoOpenApi(
      title: config.infoTitle,
      description: config.infoDescription,
      termsOfService: config.infoTermsOfService,
      version: config.infoVersion,
    );
  }

  ServerOpenApi _buildServerSpecs() {
    return ServerOpenApi(description: config.serverDescription, url: config.serverUrl);
  }

  List<TagOpenApi> _buildTags() {
    return routes.map((e) => e.element.enclosingElement3 as ClassElement).toSet().map((e) {
      return TagOpenApi(name: e.displayName, description: Doc.clean(e.documentationComment));
    }).toList();
  }
}

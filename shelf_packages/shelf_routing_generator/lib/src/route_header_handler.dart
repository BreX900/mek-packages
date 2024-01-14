import 'package:analyzer/dart/element/element.dart';
import 'package:shelf_routing/shelf_routing.dart';
import 'package:source_gen/source_gen.dart';

class RouteHeaderHandler {
  static const TypeChecker _checker = TypeChecker.fromRuntime(RouteHeader);

  final String name;

  const RouteHeaderHandler._({
    required this.name,
  });

  static List<RouteHeaderHandler> from(MethodElement element) {
    return _checker.annotationsOf(element).map(ConstantReader.new).map((e) {
      return RouteHeaderHandler._(
        name: e.read('name').stringValue,
      );
    }).toList();
  }
}

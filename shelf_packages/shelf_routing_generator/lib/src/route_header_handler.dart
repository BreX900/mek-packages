import 'package:analyzer/dart/element/element2.dart';
import 'package:shelf_routing/shelf_routing.dart';
import 'package:source_gen/source_gen.dart';

class RouteHeaderHandler {
  static const _checker = TypeChecker.typeNamed(RouteHeader, inPackage: 'shelf_routing');

  final String name;

  const RouteHeaderHandler._({required this.name});

  static List<RouteHeaderHandler> from(MethodElement2 element) {
    return _checker.annotationsOf(element).map(ConstantReader.new).map((e) {
      return RouteHeaderHandler._(name: e.read('name').stringValue);
    }).toList();
  }
}

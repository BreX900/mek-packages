// import 'dart:async';
//
// import 'package:analyzer/dart/element/element.dart';
// import 'package:build/build.dart';
// import 'package:glob/glob.dart';
// import 'package:shelf_open_api/shelf_routing.dart';
// import 'package:shelf_router/shelf_router.dart';
// import 'package:source_gen/source_gen.dart';
// import 'package:stream_transform/stream_transform.dart';
//
// Builder buildRouting(BuilderOptions options) {
//   return LibraryBuilder(const RoutingGenerator(), generatedExtension: '.routing.dart');
// }
//
// class _RouterAnnotated {
//   final Routes annotation;
//   final ClassElement element;
//
//   const _RouterAnnotated({required this.annotation, required this.element});
// }
//
// class RoutingGenerator extends GeneratorForAnnotation<Routing> {
//   static final _routesType = TypeChecker.fromRuntime(Routes);
//   static final _routeType = TypeChecker.fromRuntime(Route);
//
//   const RoutingGenerator();
//
//   @override
//   Future<void> generateForAnnotatedElement(
//     Element element,
//     ConstantReader annotation,
//     BuildStep buildStep,
//   ) async {
//     final routing = Routing(
//       varName: annotation.read('varName').stringValue,
//       generateFor: annotation.read('generateFor').listValue.map((e) {
//         return e.toStringValue()!;
//       }).toList(),
//     );
//     final routers = await _findRouters(buildStep, routing.generateFor.map(Glob.new)).toList();
//
//     final varName = '\$${routing.varName}';
//     final mountedRouters = routers.map((e) {
//       return "..mount('${e.annotation.prefix}', ${e.element.name}().router)";
//     });
//     final importRouters = routers.map((e) => "import '${e.element.library.identifier}';");
//     final result =
//         "import 'package:shelf_router/shelf_router.dart';\n"
//         '${importRouters.map((e) => '$e\n').join()}'
//         '\n'
//         'Router get $varName => Router()${mountedRouters.map((e) => '\n  $e').join('')};';
//
//     await buildStep.writeAsString(buildStep.allowedOutputs.single, result);
//   }
//
//   Stream<_RouterAnnotated> _findRouters(BuildStep buildStep, Iterable<Glob> generateFor) {
//     return Stream<AssetId>.empty()
//         .mergeAll(generateFor.map(buildStep.findAssets))
//         .concurrentAsyncMap((asset) async {
//           final library = await buildStep.resolver.libraryFor(asset);
//
//           return _readRouters(LibraryReader(library));
//         })
//         .expand((list) => list);
//   }
//
//   Iterable<_RouterAnnotated> _readRouters(LibraryReader library) sync* {
//     final elements = library.classes.where((e) {
//       return e.methods.any(_routeType.hasAnnotationOf) ||
//           e.accessors.any(_routeType.hasAnnotationOf);
//     });
//
//     for (final element in elements) {
//       final annotation = ConstantReader(_routesType.firstAnnotationOf(element));
//
//       yield _RouterAnnotated(
//         annotation: const Routes().copyWith(prefix: annotation.peek('prefix')?.stringValue),
//         element: element,
//       );
//     }
//   }
// }

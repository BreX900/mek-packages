// /// Annotations for the shelf_routing_generator library.
// library shelf_routing;
//
// import 'package:meta/meta_meta.dart';
//
// class Routing {
//   final String varName;
//   final List<String> generateFor;
//
//   const Routing({
//     required this.varName,
//     this.generateFor = const ['**.dart'],
//   });
// }
//
// @TargetKind.classType
// class Routes {
//   final String prefix;
//
//   const Routes({
//     this.prefix = '/',
//   });
//
//   Routes copyWith({String? prefix}) {
//     return Routes(
//       prefix: prefix ?? this.prefix,
//     );
//   }
// }

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';
import 'package:source_gen/source_gen.dart';

const TypeChecker routeChecker = TypeChecker.fromRuntime(Route);
const TypeChecker requestChecker = TypeChecker.fromRuntime(Request);
const TypeChecker responseChecker = TypeChecker.fromRuntime(Response);

const TypeChecker routerChecker = TypeChecker.fromRuntime(Router);
const TypeChecker routerMixinChecker = TypeChecker.fromRuntime(RouterMixin);

bool isHandlerFunctionAssignableFromType(DartType type) {
  if (type is! FunctionType) return false;

  var returnType = type.returnType;
  returnType = returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr
      ? (returnType as InterfaceType).typeArguments.single
      : returnType;
  if (!responseChecker.isAssignableFromType(returnType)) return false;

  final parameter = type.parameters.singleOrNull;
  if (parameter == null || !requestChecker.isAssignableFromType(parameter.type)) return false;

  return true;
}

void ensureIsValidRoute(String? route, {required String name, Element? element}) {
  if (route == null || RegExp(r'^\/.+[^/]$').hasMatch(route)) return;
  throw InvalidGenerationSourceError(
    '"$name" field must begin and not end with "/". ',
    element: element,
  );
}

extension JsonType on DartType {
  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;

  bool get isPrimitive =>
      isDartCoreBool || isDartCoreInt || isDartCoreDouble || isDartCoreNum || isDartCoreString;

  bool get isJsonPrimitive => isDartCoreNull || isPrimitive;
  bool get isJson => isJsonPrimitive || isDartCoreList || isDartCoreMap;

  InterfaceType? get asDartCoreList => this is InterfaceType ? this as InterfaceType : null;
}

extension InterfaceTypeExtensions on InterfaceType {
  DartType get typeArgument => typeArguments.single;
}

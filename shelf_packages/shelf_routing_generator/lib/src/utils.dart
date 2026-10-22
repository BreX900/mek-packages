import 'dart:typed_data';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_routing/shelf_routing.dart';
import 'package:source_gen/source_gen.dart';

const routeChecker = TypeChecker.typeNamed(Route, inPackage: 'shelf_router');
const requestChecker = TypeChecker.typeNamed(Request, inPackage: 'shelf');
const responseChecker = TypeChecker.typeNamed(Response, inPackage: 'shelf');
const jsonResponseChecker = TypeChecker.typeNamed(JsonResponse, inPackage: 'shelf_routing');

const routerChecker = TypeChecker.typeNamed(Router, inPackage: 'shelf_router');
const routerMixinChecker = TypeChecker.typeNamed(RouterMixin, inPackage: 'shelf_routing');

const bytesChecker = TypeChecker.typeNamed(Uint8List, inSdk: true);
const byteStreamChecker = TypeChecker.typeNamed(Stream<List<int>>, inSdk: true);

abstract final class TypeCheckers {
  static const _ficPackage = 'fast_immutable_collections';
  static const _builtPackage = 'built_collection';

  static const iterable = TypeChecker.typeNamed(Iterable, inSdk: true);

  static const list = TypeChecker.any([
    TypeChecker.typeNamed(List, inSdk: true),
    TypeChecker.typeNamedLiterally('IList', inPackage: _ficPackage),
    TypeChecker.typeNamedLiterally('BuiltList', inPackage: _builtPackage),
  ]);
  static const set = TypeChecker.any([
    TypeChecker.typeNamed(Set, inSdk: true),
    TypeChecker.typeNamedLiterally('ISet', inPackage: _ficPackage),
    TypeChecker.typeNamedLiterally('BuiltSet', inPackage: _builtPackage),
  ]);
  static const listOrSet = TypeChecker.any([list, set]);
  static const map = TypeChecker.any([
    TypeChecker.typeNamed(Map, inSdk: true),
    TypeChecker.typeNamedLiterally('IMap', inPackage: _ficPackage),
    TypeChecker.typeNamedLiterally('BuiltMap', inPackage: _builtPackage),
  ]);
}

bool isHandlerFunctionAssignableFromType(DartType type) {
  if (type is! FunctionType) return false;

  var returnType = type.returnType;
  returnType = returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr
      ? (returnType as InterfaceType).typeArguments.single
      : returnType;
  if (!responseChecker.isAssignableFromType(returnType)) return false;

  final parameter = type.formalParameters.singleOrNull;
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
  bool get isPrimitive =>
      isDartCoreBool || isDartCoreInt || isDartCoreDouble || isDartCoreNum || isDartCoreString;

  bool get isJsonPrimitive => isDartCoreNull || isPrimitive;
  bool get isJson => isJsonPrimitive || isDartCoreList || isDartCoreMap;

  bool get isJsonSuperset =>
      isJson ||
      TypeCheckers.list.isAssignableFromType(this) ||
      TypeCheckers.map.isAssignableFromType(this);

  InterfaceType? get asDartCoreList => this is InterfaceType ? this as InterfaceType : null;
}

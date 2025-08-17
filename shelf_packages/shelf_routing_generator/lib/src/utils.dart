import 'dart:typed_data';

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
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

void ensureIsValidRoute(String? route, {required String name, Element2? element}) {
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

extension RequireNameElementExtension on Element2 {
  String get requireName {
    if (name3 case final name?) return name;
    throw InvalidGenerationSourceError('The parameter name is required!', element: this);
  }
}

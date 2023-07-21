import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all_generator/src/handlers.dart';
import 'package:one_for_all_generator/src/options.dart';

/// https://docs.flutter.dev/platform-integration/platform-channels
abstract class ApiBuilder {
  final OneForAllOptions pluginOptions;

  String get outputFile;

  const ApiBuilder(this.pluginOptions);

  void writeHostApiClass(HostApiHandler handler);

  void writeFlutterApiClass(FlutterApiHandler handler);

  void writeException(EnumElement element);

  void writeSerializableClass(SerializableClassHandler handler);

  void writeSerializableEnum(SerializableEnumHandler handler);

  String build();
}

extension TypeArgsDartType on DartType {
  DartType get singleTypeArg {
    final element = this as ParameterizedType;
    return element.typeArguments.single;
  }

  (DartType, DartType) get doubleTypeArgs {
    final element = this as ParameterizedType;
    return (element.typeArguments[0], element.typeArguments[1]);
  }
}

extension SupportedDartType on DartType {
  bool get isPrimitive =>
      this is DynamicType ||
      isDartCoreNull ||
      isDartCoreObject ||
      isDartCoreBool ||
      isDartCoreInt ||
      isDartCoreDouble ||
      isDartCoreString;

  bool get isSupported => isPrimitive || isDartCoreList || isDartCoreMap;
}

extension SupportedMethodElement on MethodElement {
  bool get isHostApiMethod => isAbstract && returnType.isDartAsyncFuture;
  bool get isHostApiEvent => isAbstract && returnType.isDartAsyncStream;
  bool get isFlutterApiMethod => name.startsWith('on') || name.startsWith('_on');
  bool get isSupported => isHostApiMethod || isHostApiEvent || isFlutterApiMethod;

  String get flutterApiName => name.replaceFirst('_on', '').replaceFirst('on', '');
}

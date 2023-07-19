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

  void writeSerializable(SerializableHandler<ClassElement> handler);

  void writeEnum(SerializableHandler<EnumElement> handler);

  String build();
}

extension CleanNameInterface on InterfaceOrAugmentationElement {
  String get cleanName => name.replaceFirst('_', '');
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
  bool get isHostMethod => isAbstract && returnType.isDartAsyncFuture;
  bool get isFlutterMethod => name.startsWith('on') || name.startsWith('_on');
}

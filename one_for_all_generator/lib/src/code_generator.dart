import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all_generator/src/handlers/api_class_handler.dart';
import 'package:one_for_all_generator/src/options.dart';

/// https://docs.flutter.dev/platform-integration/platform-channels
abstract class CodeGenerator {
  final OneForAllOptions pluginOptions;

  const CodeGenerator(this.pluginOptions);

  void writeHostApiClass(ApiClassHandler handler);

  void writeFlutterApiClass(ClassElement element);

  void writeException(EnumElement element);

  void writeDataClass(ClassElement element);

  void writeEnum(EnumElement element);

  void writeToFile();
}

mixin WriteToOutputFile {
  String get outputFile;

  Future<void> writeToFile() async {
    await File(outputFile).writeAsString(toString());
  }
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

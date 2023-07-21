import 'package:analyzer/dart/element/element.dart';
import 'package:equatable/equatable.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/one_for_all_generator.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

const _methodApiChecker = TypeChecker.fromRuntime(MethodApi);

class MethodHandler {
  final MethodElement element;
  final SwiftMethodType swiftMethodType;

  const MethodHandler({
    required this.element,
    required this.swiftMethodType,
  });
}

class HostApiHandler {
  final OneForAllOptions options;
  final ClassElement element;
  final Revivable? hostExceptionHandler;
  final SwiftMethodType swiftMethodType;

  HostApiHandler({
    required this.options,
    required this.element,
    required this.hostExceptionHandler,
    required this.swiftMethodType,
  });

  factory HostApiHandler.of(OneForAllOptions options, AnnotatedElement _) {
    final AnnotatedElement(:element, :annotation) = _;

    return HostApiHandler(
      options: options,
      element: element as ClassElement,
      hostExceptionHandler: annotation.peek('hostExceptionHandler')?.revive(),
      swiftMethodType: annotation.read('swiftMethodType').reviveEnum(SwiftMethodType.values),
    );
  }

  late final List<MethodHandler> methods = element.methods.where((e) => e.isHostApiMethod).map((e) {
    final annotation = ConstantReader(_methodApiChecker.firstAnnotationOf(e));

    return MethodHandler(
      element: e,
      swiftMethodType:
          annotation.peek('swiftMethodType')?.reviveEnum(SwiftMethodType.values) ?? swiftMethodType,
    );
  }).toList();

  String channelName([MethodElement? e]) => e?.name ?? element.name;
  @Deprecated('In favour of ApiBuilder.encodeName')
  String get className => '${element.name.pascalCase}${options.hostClassSuffix}';

  @Deprecated('In favour of ApiBuilder.encodeName')
  String controllerName(MethodElement e) =>
      '${e.name.pascalCase}Controller${options.hostClassSuffix}';
  String controllerChannelName(MethodElement? e) =>
      '${element.name}${e != null ? '#${e.name}' : ''}';
}

class FlutterApiHandler {
  final OneForAllOptions options;
  final ClassElement element;

  FlutterApiHandler({
    required this.options,
    required this.element,
  });

  factory FlutterApiHandler.of(OneForAllOptions options, AnnotatedElement _) {
    final AnnotatedElement(:element) = _;

    return FlutterApiHandler(
      options: options,
      element: element as ClassElement,
    );
  }

  String channelName([MethodElement? e]) => e?.name ?? element.name;
  @Deprecated('In favour of ApiBuilder.encodeName')
  String name(String name) => '${element.name.pascalCase}${options.hostClassSuffix}';
  @Deprecated('In favour of ApiBuilder.encodeName')
  String get className => '${element.name.pascalCase}${options.hostClassSuffix}';
}

class SerializableClassHandler extends Equatable {
  static const _annotationChecker = TypeChecker.fromRuntime(SerializableClass);

  final ClassElement element;
  final bool kotlinGeneration;
  final bool swiftGeneration;
  final bool flutterToHost;
  final bool hostToFlutter;

  const SerializableClassHandler({
    required this.element,
    required this.kotlinGeneration,
    required this.swiftGeneration,
    required this.flutterToHost,
    required this.hostToFlutter,
  });

  factory SerializableClassHandler.from(ClassElement element) {
    final annotation = ConstantReader(_annotationChecker.firstAnnotationOf(element));

    return SerializableClassHandler(
      element: element,
      kotlinGeneration: annotation.peek('kotlinGeneration')?.boolValue ?? true,
      swiftGeneration: annotation.peek('swiftGeneration')?.boolValue ?? true,
      flutterToHost: false,
      hostToFlutter: false,
    );
  }

  SerializableClassHandler apply({
    bool flutterToHost = false,
    bool hostToFlutter = false,
  }) {
    return SerializableClassHandler(
      element: element,
      kotlinGeneration: kotlinGeneration,
      swiftGeneration: swiftGeneration,
      flutterToHost: this.flutterToHost || flutterToHost,
      hostToFlutter: this.hostToFlutter || hostToFlutter,
    );
  }

  @override
  List<Object?> get props =>
      [element, kotlinGeneration, swiftGeneration, flutterToHost, hostToFlutter];
}

class SerializableEnumHandler extends Equatable {
  static const _annotationChecker = TypeChecker.fromRuntime(SerializableEnum);

  final EnumElement element;
  final SerializableEnumType type;
  final bool kotlinGeneration;
  final bool swiftGeneration;
  final bool flutterToHost;
  final bool hostToFlutter;

  const SerializableEnumHandler({
    required this.element,
    required this.type,
    required this.kotlinGeneration,
    required this.swiftGeneration,
    required this.flutterToHost,
    required this.hostToFlutter,
  });

  factory SerializableEnumHandler.from(EnumElement element) {
    final annotation = ConstantReader(_annotationChecker.firstAnnotationOf(element));

    return SerializableEnumHandler(
      element: element,
      type: annotation.peek('type')?.reviveEnum(SerializableEnumType.values) ??
          SerializableEnumType.int,
      kotlinGeneration: annotation.peek('kotlinGeneration')?.boolValue ?? true,
      swiftGeneration: annotation.peek('swiftGeneration')?.boolValue ?? true,
      flutterToHost: false,
      hostToFlutter: false,
    );
  }

  SerializableEnumHandler apply({
    bool flutterToHost = false,
    bool hostToFlutter = false,
  }) {
    return SerializableEnumHandler(
      element: element,
      type: type,
      kotlinGeneration: kotlinGeneration,
      swiftGeneration: swiftGeneration,
      flutterToHost: this.flutterToHost || flutterToHost,
      hostToFlutter: this.hostToFlutter || hostToFlutter,
    );
  }

  @override
  List<Object?> get props =>
      [element, type, kotlinGeneration, swiftGeneration, flutterToHost, hostToFlutter];
}

extension NoUndescoreString on String {
  String get no_ => replaceFirst('_', '');
}

extension on ConstantReader {
  T reviveEnum<T extends Enum>(List<T> values) {
    final revivable = revive();
    final name = revivable.accessor.split('.')[1];
    return values.firstWhere((e) => e.name == name);
  }
}

class AnnotatedWithElement<T extends Element> {
  final ConstantReader annotation;
  final T element;

  AnnotatedWithElement(this.annotation, this.element);
}

import 'package:analyzer/dart/element/element.dart';
import 'package:equatable/equatable.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/one_for_all_generator.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:source_gen/source_gen.dart';

class MethodHandler {
  static const _checker = TypeChecker.fromRuntime(MethodApi);

  final MethodElement element;
  final MethodApiType swift;
  final MethodApiType kotlin;

  const MethodHandler({required this.element, required this.swift, required this.kotlin});

  factory MethodHandler.from(MethodElement element, MethodApiType defaultMethod) {
    final annotation = ConstantReader(_checker.firstAnnotationOf(element));

    return MethodHandler(
      element: element,
      kotlin: annotation.peek('kotlin')?.reviveEnum(MethodApiType.values) ?? defaultMethod,
      swift: annotation.peek('swift')?.reviveEnum(MethodApiType.values) ?? defaultMethod,
    );
  }
}

class HostApiHandler {
  final OneForAllOptions options;
  final ClassElement element;
  final Revivable? hostExceptionHandler;
  final MethodApiType kotlinMethod;
  final MethodApiType swiftMethod;

  HostApiHandler({
    required this.options,
    required this.element,
    required this.hostExceptionHandler,
    required this.kotlinMethod,
    required this.swiftMethod,
  });

  factory HostApiHandler.of(OneForAllOptions options, AnnotatedElement _) {
    final AnnotatedElement(:element, :annotation) = _;

    return HostApiHandler(
      options: options,
      element: element as ClassElement,
      hostExceptionHandler: annotation.peek('hostExceptionHandler')?.revive(),
      kotlinMethod: annotation.read('kotlinMethod').reviveEnum(MethodApiType.values),
      swiftMethod: annotation.read('swiftMethod').reviveEnum(MethodApiType.values),
    );
  }

  late final List<MethodHandler> kotlinMethods = element.methods
      .where((e) => e.isHostApiMethod)
      .map((e) => MethodHandler.from(e, kotlinMethod))
      .toList();
  late final List<MethodHandler> swiftMethods = element.methods
      .where((e) => e.isHostApiMethod)
      .map((e) => MethodHandler.from(e, swiftMethod))
      .toList();

  String channelName([MethodElement? e]) => e?.name ?? element.name;
  String controllerChannelName(MethodElement? e) =>
      '${element.name}${e != null ? '#${e.name}' : ''}';
}

class FlutterApiHandler {
  final OneForAllOptions options;
  final ClassElement element;
  final MethodApiType kotlinMethod;
  final MethodApiType swiftMethod;

  FlutterApiHandler({
    required this.options,
    required this.element,
    required this.kotlinMethod,
    required this.swiftMethod,
  });

  factory FlutterApiHandler.of(OneForAllOptions options, AnnotatedElement _) {
    final AnnotatedElement(:element, :annotation) = _;

    return FlutterApiHandler(
      options: options,
      element: element as ClassElement,
      kotlinMethod: annotation.read('kotlinMethod').reviveEnum(MethodApiType.values),
      swiftMethod: annotation.read('swiftMethod').reviveEnum(MethodApiType.values),
    );
  }

  late final List<MethodHandler> kotlinMethods = element.methods
      .where((e) => e.isFlutterApiMethod)
      .map((e) => MethodHandler.from(e, kotlinMethod))
      .toList();
  late final List<MethodHandler> swiftMethods = element.methods
      .where((e) => e.isFlutterApiMethod)
      .map((e) => MethodHandler.from(e, swiftMethod))
      .toList();

  String channelName([MethodElement? e]) => e?.name ?? element.name;
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

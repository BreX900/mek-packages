import 'package:analyzer/dart/element/element.dart';
import 'package:one_for_all_generator/one_for_all_generator.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

class HostApiHandler {
  final OneForAllOptions options;
  final ClassElement element;
  final Revivable? hostExceptionHandler;

  const HostApiHandler({
    required this.options,
    required this.element,
    required this.hostExceptionHandler,
  });

  factory HostApiHandler.from(OneForAllOptions options, AnnotatedElement _) {
    final AnnotatedElement(:element, :annotation) = _;

    return HostApiHandler(
      options: options,
      element: element as ClassElement,
      hostExceptionHandler: annotation.peek('hostExceptionHandler')?.revive(),
    );
  }

  String channelName([MethodElement? e]) => e?.name ?? element.name;
  String get className => '${element.name.pascalCase}${options.hostClassSuffix}';

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

  factory FlutterApiHandler.from(OneForAllOptions options, AnnotatedElement _) {
    final AnnotatedElement(:element) = _;

    return FlutterApiHandler(
      options: options,
      element: element as ClassElement,
    );
  }

  String channelName([MethodElement? e]) => e?.name ?? element.name;
  String get className => '${element.name.pascalCase}${options.hostClassSuffix}';
}

class SerializableHandler<TElement extends InterfaceElement> {
  final TElement element;
  final bool flutterToHost;
  final bool hostToFlutter;

  const SerializableHandler({
    required this.element,
    required this.flutterToHost,
    required this.hostToFlutter,
  });

  const SerializableHandler.of(this.element)
      : flutterToHost = false,
        hostToFlutter = false;

  SerializableHandler<TElement> apply({
    bool flutterToHost = false,
    bool hostToFlutter = false,
  }) {
    return SerializableHandler(
      element: element,
      flutterToHost: this.flutterToHost || flutterToHost,
      hostToFlutter: this.hostToFlutter || hostToFlutter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SerializableHandler &&
          runtimeType == other.runtimeType &&
          element == other.element &&
          flutterToHost == other.flutterToHost &&
          hostToFlutter == other.hostToFlutter;

  @override
  int get hashCode => element.hashCode ^ flutterToHost.hashCode ^ hostToFlutter.hashCode;
}

extension NoUndescoreString on String {
  String get no_ => replaceFirst('_', '');
}

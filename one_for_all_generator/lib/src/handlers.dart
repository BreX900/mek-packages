import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class HostApiHandler {
  final ClassElement element;
  final Revivable? hostExceptionHandler;

  const HostApiHandler({
    required this.element,
    required this.hostExceptionHandler,
  });

  factory HostApiHandler.from(AnnotatedElement _) {
    final AnnotatedElement(:element, :annotation) = _;

    return HostApiHandler(
      element: element as ClassElement,
      hostExceptionHandler: annotation.peek('hostExceptionHandler')?.revive(),
    );
  }
}

class FlutterApiHandler {
  final ClassElement element;

  FlutterApiHandler({required this.element});

  factory FlutterApiHandler.from(AnnotatedElement _) {
    final AnnotatedElement(:element) = _;

    return FlutterApiHandler(
      element: element as ClassElement,
    );
  }
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

  @override
  String toString() {
    return 'SerializableHandler<$TElement>{element: $element, flutterToHost: $flutterToHost, hostToFlutter: $hostToFlutter}';
  }

// factory SerializableHandler.from(AnnotatedElement _) {
  //   final AnnotatedElement(:element) = _;
  //
  //   return SerializableHandler(
  //     element: element as InterfaceElement,
  //     shouldGenerateSerializer: true,
  //     shouldGenerateDeserializer: true,
  //   );
  // }
}

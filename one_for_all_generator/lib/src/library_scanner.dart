import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:one_for_all/one_for_all.dart';
import 'package:one_for_all_generator/src/api_builder.dart';
import 'package:one_for_all_generator/src/handlers.dart';
import 'package:one_for_all_generator/src/options.dart';
import 'package:source_gen/source_gen.dart';

class LibraryScanned {
  final List<HostApiHandler> hostApiHandles;
  final List<FlutterApiHandler> flutterApiHandlers;
  final List<SerializableHandler> serializableHandlers;

  const LibraryScanned({
    required this.hostApiHandles,
    required this.flutterApiHandlers,
    required this.serializableHandlers,
  });
}

class LibraryScanner {
  static const hostApiChecker = TypeChecker.typeNamed(HostApi, inPackage: 'one_for_all');
  static const flutterApiChecker = TypeChecker.typeNamed(FlutterApi, inPackage: 'one_for_all');
  static const serializableClassChecker = TypeChecker.typeNamed(
    SerializableClass,
    inPackage: 'one_for_all',
  );
  static const serializableEnumChecker = TypeChecker.typeNamed(
    SerializableEnum,
    inPackage: 'one_for_all',
  );

  final OneForAllOptions options;

  final _hostApiHandles = <HostApiHandler>{};
  final _flutterApiHandlers = <FlutterApiHandler>{};
  final _serializableHandlers = <InterfaceElement, SerializableHandler>{};

  LibraryScanner({required this.options});

  void scan(LibraryElement library) {
    final libraryReader = LibraryReader(library);

    final serializableClassElements = libraryReader.classes.whereHasAnnotation(
      serializableClassChecker.firstAnnotationOf,
    );
    for (final AnnotatedWithElement(:element) in serializableClassElements) {
      scanSerializable(element.thisType);
    }
    final serializableEnumElements = libraryReader.enums.whereHasAnnotation(
      serializableEnumChecker.firstAnnotationOf,
    );
    for (final AnnotatedWithElement(:element) in serializableEnumElements) {
      scanSerializable(element.thisType);
    }

    _hostApiHandles.addAll(
      libraryReader.annotatedWith(hostApiChecker).map((e) => HostApiHandler.of(options, e)),
    );

    _flutterApiHandlers.addAll(
      libraryReader.annotatedWith(flutterApiChecker).map((e) => FlutterApiHandler.of(options, e)),
    );
  }

  LibraryScanned get result {
    for (final HostApiHandler(:element) in _hostApiHandles) {
      scanApi(element, flutterToHost: true);
    }
    for (final FlutterApiHandler(:element) in _flutterApiHandlers) {
      scanApi(element, hostToFlutter: true);
    }
    return LibraryScanned(
      hostApiHandles: _hostApiHandles.sortedBy((e) => e.element.displayName),
      flutterApiHandlers: _flutterApiHandlers.sortedBy((e) => e.element.displayName),
      serializableHandlers: _serializableHandlers.values.sortedBy((e) => e.element.displayName),
    );
  }

  late final codecs = options.codecs.map((e) => (TypeChecker.typeNamed(e.type), e)).toList();
  bool hasCodec(DartType type) => codecs.any((e) => e.$1.isExactlyType(type));

  void scanSerializable(DartType type, {bool flutterToHost = false, bool hostToFlutter = false}) {
    if (hasCodec(type)) return;
    if (type.isDartCoreList || type.isDartCoreMap) {
      for (final typeArg in (type as ParameterizedType).typeArguments) {
        scanSerializable(typeArg, hostToFlutter: hostToFlutter, flutterToHost: flutterToHost);
      }
      return;
    }
    if (type.isSupported) return;

    final element = type.element;

    final handler = switch (element) {
      EnumElement() => _serializableHandlers.putIfAbsent(element, () {
        return SerializableEnumHandler.from(element);
      }),
      ClassElement() => _serializableHandlers.putIfAbsent(element, () {
        return SerializableClassHandler.from(element);
      }),
      _ => null,
    };
    if (handler == null) return;

    final updatedHandler = handler.apply(
      flutterToHost: flutterToHost,
      hostToFlutter: hostToFlutter,
    );
    if (handler == updatedHandler) return;

    _serializableHandlers[handler.element] = updatedHandler;

    switch (element) {
      case EnumElement():
        break;
      case ClassElement():
        for (final field in element.fields) {
          scanSerializable(field.type, hostToFlutter: hostToFlutter, flutterToHost: flutterToHost);
        }
    }
  }

  void scanApi(InterfaceElement element, {bool flutterToHost = false, bool hostToFlutter = false}) {
    for (final method in element.methods) {
      if (!method.isSupported) continue;

      for (final parameter in method.formalParameters) {
        scanSerializable(
          parameter.type,
          flutterToHost: flutterToHost,
          hostToFlutter: hostToFlutter,
        );
      }

      scanSerializable(
        method.returnType.thisOrSingleTypeArg,
        flutterToHost: hostToFlutter,
        hostToFlutter: flutterToHost,
      );
    }
  }
}

extension<T extends Element> on Iterable<T> {
  Iterable<AnnotatedWithElement<T>> whereHasAnnotation(DartObject? Function(Element) finder) sync* {
    for (final element in this) {
      final annotation = finder(element);
      if (annotation == null) continue;
      yield AnnotatedWithElement(ConstantReader(annotation), element);
    }
  }
}

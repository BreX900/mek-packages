import 'package:meta/meta_meta.dart';

// TODO: Rename to LanguageApi
enum PlatformApi { dart, kotlin, swift }

enum SwiftMethodType { result, async }

class MethodApi {
  final SwiftMethodType? swiftMethodType;

  const MethodApi({
    this.swiftMethodType,
  });
}

@Target({TargetKind.classType})
class HostApi {
  final Set<Type> extraInterfaces;
  final Function? hostExceptionHandler;
  final SwiftMethodType swiftMethodType;

  const HostApi({
    this.extraInterfaces = const {},
    this.hostExceptionHandler,
    this.swiftMethodType = SwiftMethodType.result,
  });
}

@Target({TargetKind.classType})
class FlutterApi {
  final Set<Type> extraInterfaces;

  const FlutterApi({
    this.extraInterfaces = const {},
  });
}

@Target({TargetKind.classType})
class SerializableClass {
  final Set<PlatformApi> languages;
  final bool? flutterToHost;
  final bool? hostToFlutter;

  const SerializableClass({
    this.languages = const {PlatformApi.dart, PlatformApi.kotlin, PlatformApi.swift},
    this.flutterToHost,
    this.hostToFlutter,
  });
}

enum SerializableEnumType { int, string }

@Target({TargetKind.enumType})
class SerializableEnum {
  final SerializableEnumType type;
  final Set<PlatformApi> languages;
  final bool? flutterToHost;
  final bool? hostToFlutter;

  const SerializableEnum({
    this.type = SerializableEnumType.int,
    this.languages = const {PlatformApi.dart, PlatformApi.kotlin, PlatformApi.swift},
    this.flutterToHost,
    this.hostToFlutter,
  });
}

// class HostExceptionCodeApi {
//   final bool swiftGeneration;
//   final bool kotlinGeneration;
//
//   const HostExceptionCodeApi({
//     this.swiftGeneration = false,
//     this.kotlinGeneration = false,
//   });
// }
//
// class FlutterExceptionCodeApi {
//   final bool swiftGeneration;
//   final bool kotlinGeneration;
//
//   const FlutterExceptionCodeApi({
//     this.swiftGeneration = false,
//     this.kotlinGeneration = false,
//   });
// }

library;

import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

enum LanguageApi { dart, kotlin, swift }

enum MethodApiType { sync, callbacks, async }

class MethodApi {
  @experimental
  final MethodApiType? kotlin;
  final MethodApiType? swift;

  const MethodApi({
    this.kotlin,
    this.swift,
  });
}

@Target({TargetKind.classType})
class HostApi {
  final Function? hostExceptionHandler;
  @experimental
  final MethodApiType kotlinMethod;
  final MethodApiType swiftMethod;

  const HostApi({
    this.hostExceptionHandler,
    this.kotlinMethod = MethodApiType.sync,
    this.swiftMethod = MethodApiType.sync,
  });
}

@Target({TargetKind.classType})
class FlutterApi {
  @experimental
  final MethodApiType kotlinMethod;
  final MethodApiType swiftMethod;

  const FlutterApi({
    this.kotlinMethod = MethodApiType.sync,
    this.swiftMethod = MethodApiType.sync,
  });
}

@Target({TargetKind.classType})
class SerializableClass {
  final Set<LanguageApi> languages;
  final bool? flutterToHost;
  final bool? hostToFlutter;

  const SerializableClass({
    this.languages = const {LanguageApi.dart, LanguageApi.kotlin, LanguageApi.swift},
    this.flutterToHost,
    this.hostToFlutter,
  });
}

@Target({TargetKind.field, TargetKind.parameter, TargetKind.optionalParameter})
class SerializableParam {
  final bool isIgnored;

  const SerializableParam.ignore() : isIgnored = true;
}

enum SerializableEnumType { int, string }

@Target({TargetKind.enumType})
class SerializableEnum {
  final SerializableEnumType type;
  final Set<LanguageApi> languages;
  final bool? flutterToHost;
  final bool? hostToFlutter;

  const SerializableEnum({
    this.type = SerializableEnumType.int,
    this.languages = const {LanguageApi.dart, LanguageApi.kotlin, LanguageApi.swift},
    this.flutterToHost,
    this.hostToFlutter,
  });
}

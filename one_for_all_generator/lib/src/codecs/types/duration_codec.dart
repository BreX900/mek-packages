import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';

class DurationDartApiCodec extends ApiCodec<Duration> {
  const DurationDartApiCodec();

  @override
  String encodeType(ApiCodecs codecs, DartType type) => 'Duration${type.isNullable ? '?' : ''}';

  @override
  String encodeDeserialization(ApiCodecs codecs, DartType type, String varAccess) =>
      'Duration(microseconds: $varAccess as int)';

  @override
  bool get hasNullSafeSerialization => true;
  @override
  String encodeSerialization(ApiCodecs codecs, DartType type, String varAccess) =>
      '$varAccess${type.isNullable ? '?' : ''}.inMicroseconds';
}

class DurationKotlinApiCodec extends ApiCodec<Duration> {
  const DurationKotlinApiCodec();

  @override
  String encodeType(ApiCodecs codecs, DartType type) => 'Long${type.isNullable ? '?' : ''}';

  @override
  bool get hasNullSafeDeserialization => true;
  @override
  String encodeDeserialization(ApiCodecs codecs, DartType type, String varAccess) =>
      '$varAccess as Long${type.isNullable ? '?' : ''}';

  @override
  bool get hasNullSafeSerialization => true;
  @override
  String encodeSerialization(ApiCodecs codecs, DartType type, String varAccess) => varAccess;
}

class DurationSwiftApiCodec extends ApiCodec<Duration> {
  const DurationSwiftApiCodec();

  @override
  String encodeType(ApiCodecs codecs, DartType type) => 'Int${type.isNullable ? '?' : ''}';

  @override
  bool get hasNullSafeDeserialization => true;
  @override
  String encodeDeserialization(ApiCodecs codecs, DartType type, String varAccess) =>
      '$varAccess as${type.isNullable ? '?' : '!'} Int';

  @override
  bool get hasNullSafeSerialization => true;
  @override
  String encodeSerialization(ApiCodecs codecs, DartType type, String varAccess) => varAccess;
}

import 'package:analyzer/dart/element/type.dart';
import 'package:one_for_all_generator/src/codecs/codecs.dart';

class DateTimeDartApiCodec extends ApiCodec<DateTime> {
  const DateTimeDartApiCodec();

  @override
  String encodeType(ApiCodecs codecs, DartType type) => 'DateTime${type.isNullable ? '?' : ''}';

  @override
  String encodeDeserialization(ApiCodecs codecs, DartType type, String varAccess) =>
      'DateTime.fromMillisecondsSinceEpoch($varAccess as int)';

  @override
  bool get hasNullSafeSerialization => true;

  @override
  String encodeSerialization(ApiCodecs codecs, DartType type, String varAccess) =>
      '$varAccess${type.isNullable ? '?' : ''}.millisecondsSinceEpoch';
}

class DateTimeKotlinApiCodec extends ApiCodec<DateTime> {
  const DateTimeKotlinApiCodec();

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

class DateTimeSwiftApiCodec extends ApiCodec<DateTime> {
  const DateTimeSwiftApiCodec();

  @override
  String encodeType(ApiCodecs codecs, DartType type) => 'Date${type.isNullable ? '?' : ''}';

  @override
  String encodeDeserialization(ApiCodecs codecs, DartType type, String varAccess) =>
      'Date(timeIntervalSince1970: (($varAccess as Int) / 1000).toInt())';

  @override
  String encodeSerialization(ApiCodecs codecs, DartType type, String varAccess) =>
      '$varAccess.timeIntervalSince1970 * 1000';
}

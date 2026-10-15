class Date implements Comparable<Date> {
  final DateTime _value;

  Date(int year, [int month = 1, int day = 1]) : _value = DateTime.utc(year, month, day);

  Date.today() : this.fromDateTime(DateTime.now());

  Date.fromDateTime(DateTime value) : this(value.year, value.month, value.day);

  factory Date.fromJson(String source) => parse(source);

  static Date parse(String source) => Date.fromDateTime(DateTime.parse(source));

  int get year => _value.year;

  int get month => _value.month;

  int get day => _value.day;

  int get millisecondsSinceEpoch => _value.millisecondsSinceEpoch;

  int get microsecondsSinceEpoch => _value.microsecondsSinceEpoch;

  @override
  int compareTo(Date other) => _value.compareTo(other._value);

  bool isAfter(Date other) => _value.isAfter(other._value);

  Date subtract({int days = 0}) => Date.fromDateTime(_value.subtract(Duration(days: days)));

  Date copyWith({int? year, int? month, int? day}) =>
      Date.fromDateTime(_value.copyWith(year: year, month: month, day: day));

  DateTime asDateTime() => _value;

  DateTime toDateTime() => _value.toLocal();

  String toJson() => _value.toIso8601String();

  @override
  String toString() => '${_value.year}-${_value.month}-${_value.day}';

  @override
  bool operator ==(Object other) => other is Date && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}

extension ToDateDateTimeExtension on DateTime {
  Date toDate() => Date.fromDateTime(this);
}

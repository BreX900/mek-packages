import 'dart:convert';

const encoder = JsonEncoder.withIndent('  ');

mixin PrettyJsonToString {
  Map<dynamic, dynamic> toJson();

  @override
  String toString() => encoder.convert(toJson());
}

import 'dart:convert';

const encoder = JsonEncoder.withIndent('  ');

mixin PrettyJsonToString {
  Map<String, dynamic> toJson();

  @override
  String toString() => encoder.convert(toJson());
}

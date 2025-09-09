import 'package:json_annotation/json_annotation.dart';

export 'package:json_annotation/json_annotation.dart' show $checkedCreate;

class YamlSerializable extends JsonSerializable {
  const YamlSerializable({super.createFactory})
    : super(fieldRename: FieldRename.snake, anyMap: true);
}

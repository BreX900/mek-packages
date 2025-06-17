import 'dart:io';

import 'package:path/path.dart';
import 'package:recase/recase.dart';

void main() {
  final root = Directory('./tools/files_contents');

  final variables = root.listSync().map((file) {
    final content = File(file.path).readAsStringSync();
    final rawStringChar = content.contains(r'$') ? 'r' : '';
    return "  static const String ${basenameWithoutExtension(file.path).camelCase} = $rawStringChar'''\n"
        '$content'
        "\n''';";
  });

  File('./lib/src/utils/files_contents.dart')
      .writeAsStringSync('abstract final class FilesContents {\n'
          '${variables.join('\n')}'
          '\n}\n');
}

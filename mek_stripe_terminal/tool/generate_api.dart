import 'dart:io';

import 'package:pigeon/pigeon.dart';

void main() async {
  const options = PigeonOptions(
    dartPackageName: 'mek_stripe_terminal',
    input: 'tool/api_schema.g.dart',
    dartOut: 'lib/src/terminal_api.g.dart',
    kotlinOut: 'android/src/main/kotlin/mek/stripeterminal/api/TerminalApi.g.kt',
    swiftOut: 'ios/mek_stripe_terminal/Sources/mek_stripe_terminal/Api/TerminalApi.g.swift',
  );

  final entities = Directory('tool/schemas').listSync(recursive: true);
  final contents = await Future.wait(
    entities.whereType<File>().where((e) => !e.path.endsWith('/.DS_Store')).map((file) async {
      final content = await file.readAsString();
      return content.split('\n').where((line) => !line.startsWith('import ')).join('\n');
    }),
  );
  final input = File(options.input!);
  input.writeAsStringSync(
    "import 'package:pigeon/pigeon.dart';\n"
    '${contents.join('\n')}',
  );

  await Pigeon.runWithOptions(options);

  input.deleteSync();
}

import 'dart:io';

import 'package:pigeon/pigeon.dart';

void main() async {
  await Future.wait([_generateTerminalApi(), _generateProximityReaderApi()]);
}

Future<void> _generateTerminalApi() async {
  const options = PigeonOptions(
    dartPackageName: 'mek_stripe_terminal',
    input: 'tool/schemas/api_schema.g.dart',
    dartOut: 'lib/src/api/terminal_api.g.dart',
    kotlinOut: 'android/src/main/kotlin/mek/stripeterminal/api/TerminalApi.g.kt',
    swiftOut: 'ios/mek_stripe_terminal/Sources/mek_stripe_terminal/Api/TerminalApi.g.swift',
  );

  final entities = Directory('tool/schemas/terminal').listSync(recursive: true);
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

  final result = Process.runSync('dart', ['format', options.dartOut!]);
  if (result.exitCode >= 0) return;

  throw StateError('${result.stderr}\n${result.stdout}');
}

Future<void> _generateProximityReaderApi() async {
  const options = PigeonOptions(
    dartPackageName: 'mek_stripe_terminal',
    input: 'tool/schemas/proximity_reader_schema.dart',
    dartOut: 'lib/src/api/proximity_reader_api.g.dart',
    swiftOut: 'ios/mek_stripe_terminal/Sources/mek_stripe_terminal/Api/ProximityReaderApi.g.swift',
    swiftOptions: SwiftOptions(includeErrorClass: false),
  );

  await Pigeon.runWithOptions(options);
}

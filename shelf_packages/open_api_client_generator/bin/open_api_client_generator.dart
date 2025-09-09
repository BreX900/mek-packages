import 'package:args/args.dart';
import 'package:open_api_client_generator/open_api_client_generator.dart';

void main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('input',
        mandatory: true,
        help:
            'Path to the file or link to the OpenApi specification file in json, yaml or yml format.')
    ..addOption('api-class-name', defaultsTo: 'Api')
    ..addOption('data-classes-postfix')
    ..addOption('output-folder', mandatory: true)
    ..addOption('client', allowed: ['abstract', 'dart', 'http', 'dio'], defaultsTo: 'dart')
    ..addOption('collection',
        allowed: ['dart', 'fast_immutable_collection', 'built_collection'], defaultsTo: 'dart')
    ..addOption('serialization', mandatory: true, allowed: ['json_serializable', 'built_value'])
    ..addMultiOption('plugins', allowed: ['mek_data_class'])
    ..addSeparator('Data Codec: json_serializable')
    ..addFlag('d-js-implicit-create', defaultsTo: true)
    ..addOption('d-js-class-field-rename')
    ..addOption('d-js-enum-field-rename');

  final args = argParser.parse(arguments);

  if (args['help']) {
    // ignore: avoid_print
    print(argParser.usage);
    return;
  }

  final input = args['input'] as String;

  final options = Options(
    input: input.contains('://') ? Uri.parse(input) : Uri.file(input),
    apiClassName: args['api-class-name'],
    dataClassesPostfix: args['data-classes-postfix'],
    outputFolder: args['output-folder'],
  );

  final client = switch (args['client']) {
    'abstract' => AbstractClientCodec(options: options),
    'dart' => DartClientCodec(options: options),
    'http' => HttpClientCodec(options: options),
    'dio' => const DioClientCodec(),
    _ => throw StateError('Unsupported "client" option ${args['client']}'),
  };

  final data = _resolveDataCodec(args);

  final plugins = (args['plugins'] as List<String>).map((plugin) {
    return switch (plugin) {
      'mek_data_class' => const MekDataClassPlugin(),
      _ => throw StateError('Unsupported "plugins" option $plugin'),
    };
  }).toList();

  await generateApi(
    options: options,
    clientCodec: client,
    serializationCodec: data,
    plugins: plugins,
  );
}

SerializationCodec _resolveDataCodec(ArgResults args) {
  final collection = switch (args['collection']) {
    'dart' => const DartCollectionCodec(),
    'fast_immutable_collection' => const FastImmutableCollectionCodec(),
    'built_collection' => const BuiltCollectionCodec(),
    _ => throw StateError('Unsupported "collection" option ${args['collection']}'),
  };

  switch (args['serialization']) {
    case 'json_serializable':
      return JsonSerializableSerializationCodec(
        collectionCodec: collection,
        implicitCreate: args['d-js-implicit-create'],
        classFieldRename: FieldRename.fromName(args['d-js-class-field-rename']),
        enumFieldRename: FieldRename.fromName(args['d-js-enum-field-rename']),
      );
    case 'built_value':
      return BuiltValueSerializationCodec(
        collectionCodec: collection,
      );
    default:
      throw StateError('Unsupported "serialization" option ${args['serialization']}');
  }
}

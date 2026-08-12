import 'package:args/args.dart';
import 'package:open_api_client_generator/open_api_client_generator.dart';

void main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print this usage information.')
    ..addOption(
      'input',
      mandatory: true,
      help:
          'Path to the file or link to the OpenApi specification file in json, yaml or yml format.',
    )
    ..addOption('api-class-name', defaultsTo: 'Api', help: 'The name of the generated API class.')
    ..addOption('data-classes-postfix', help: 'A postfix to add to all generated data classes.')
    ..addOption(
      'output-folder',
      mandatory: true,
      help: 'The output folder where the generated files will be saved.',
    )
    ..addOption('part-folder', help: 'The folder where part files will be generated.')
    ..addOption(
      'client',
      allowed: ['abstract', 'http', 'dio'],
      defaultsTo: 'dart',
      help: 'The type of client to generate.',
    )
    ..addOption(
      'collection',
      allowed: ['dart', 'fast_immutable_collection', 'built_collection'],
      defaultsTo: 'dart',
      help: 'The collection library to use for generated lists and maps.',
    )
    ..addOption(
      'serialization',
      mandatory: true,
      allowed: ['json_serializable', 'built_value'],
      help: 'The serialization library to use.',
    )
    ..addMultiOption(
      'plugins',
      allowed: ['mek_data_class'],
      help: 'A list of plugins to apply during code generation.',
    )
    ..addSeparator('Data Codec: json_serializable')
    ..addFlag(
      'd-js-implicit-create',
      defaultsTo: true,
      help: 'Whether to implicitly create instances for json_serializable.',
    )
    ..addOption(
      'd-js-class-field-rename',
      help: 'The field rename strategy for classes using json_serializable.',
    )
    ..addOption(
      'd-js-enum-field-rename',
      help: 'The field rename strategy for enums using json_serializable.',
    );

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
    partFolder: args['part-folder'] as String?,
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
      return BuiltValueSerializationCodec(collectionCodec: collection);
    default:
      throw StateError('Unsupported "serialization" option ${args['serialization']}');
  }
}

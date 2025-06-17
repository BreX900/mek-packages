
# OpenApi Client Generator

OpenApi Client Generator allows generation of API client libraries (SDK generation), server stubs, documentation and configuration automatically given an OpenAPI Spec.

This library is under development, any help is welcome

The package is written only in dart, other dependencies will not be needed

You can use this package from the command line or by writing a script in dart

## Command Line

You can run the generator with the command below

```shell
dart run open_api_client_generator \
  --input=http://0.0.0.0:8080/api/v1/swagger/open_api.yaml \
  --output-folder=lib/api \
  --client=dio \
  --data=json_serializable
```

For all usable parameters use the `--help` flag

## Script

You can also use this package by creating a dart script, here is an example:

```dart
import 'package:open_api_client_generator/open_api_client_generator.dart';

void main() async {
  await generateApi(
    options: Options(
      input: Uri.parse('http://0.0.0.0:8080/api/v1/swagger/open_api.yaml'),
      outputFolder: 'lib/api',
    ),
    clientCodec: const DioClientCodec(),
    serializationCodec: const JsonSerializableSerializationCodec(),
  );
}
```

## Arguments

Several http clients, serializers and more are supported.

### Client

| CommandLine       | Dart Class          | package | Description                                            |
|-------------------|---------------------|---------|--------------------------------------------------------|
| --client=abstract | AbstractClientCodec |         | Generate an abstract client                            |
| --client=dart     | DartClientCodec     |         | Generate a client that does not use external libraries |
| --client=http     | HttpClientCodec     | [http]  | Generate a client that uses the http library           |
| --client=dio      | DioClientCodec      | [dio]   | Generate a client that uses the dio library            |


### Serialization

| CommandLine                       | Dart Class                         | package             | Description                                              |
|-----------------------------------|------------------------------------|---------------------|----------------------------------------------------------|
| --serialization=json_serializable | JsonSerializableSerializationCodec | [json_serializable] | Generate serialization use the json_serializable package |
| --serialization=built_value       | BuiltValueSerializationCodec       | [built_value]       | Generate serialization use the built_value package       |

### Collection

| CommandLine                            | Dart Class                   | package                     | Description                                        |
|----------------------------------------|------------------------------|-----------------------------|----------------------------------------------------|
| --collection=dart                      | DartCollectionCodec          |                             | Use List an Map from dart core                     |
| --collection=fast_immutable_collection | FastImmutableCollectionCodec | [fast_immutable_collection] | Instead of List and Map use IList and IMap         |
| --collection=built_collection          | BuiltCollectionCodec         | [built_collection]          | Instead of List and Map use BuiltList and BuiltMap |

### Plugins

| CommandLine              | Dart Class         | package          | Description                                                                       |
|--------------------------|--------------------|------------------|-----------------------------------------------------------------------------------|
| --plugins=mek_data_class | MekDataClassPlugin | [mek_data_class] | Generates data classes with Data Class annotation, implements toString and equals |

## More

[shelf_open_api] The purpose of this library is to expose the generation of file with open api specifications from your shelf controllers

[http]: https://pub.dev/packages/http
[dio]: https://pub.dev/packages/dio
[json_serializable]: https://pub.dev/packages/json_serializable
[built_value]: https://pub.dev/packages/built_value
[fast_immutable_collection]: https://pub.dev/packages/fast_immutable_collection
[built_collection]: https://pub.dev/packages/built_collection
[mek_data_class]: https://pub.dev/packages/mek_data_class
[shelf_open_api]: https://pub.dev/packages/shelf_open_api

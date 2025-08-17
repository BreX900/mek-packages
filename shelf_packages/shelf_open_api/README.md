

# Shelf Open Api

The purpose of this library is to expose the generation of file with open api specifications from your shelf controllers
[OpenApi Specification]

This library is under development, any help is welcome

## Features

- [x] Info (Versioning, EndPoint and more api info)
- [x] Params (Supported only string type params)
- [x] Requests
- [x] Responses
- [ ] Bad Responses
- [x] Reused schemas by `$ref`
- [ ] Inheritance and Polymorphism by `allOf`, `oneOf`, `anyOf`, `discriminator`
- [-] Security (Partial implemented)
- [x] Docs (`summary`, `description`, `example`)
- [x] Tags/Groups
- [x] json_serializable
- [ ] Deprecated operations by `@Deprecated()` meta annotation
- [ ] Default values `default`

## Install package

To use [shelf_open_api], you will need your typical [build_runner]/code-generator setup.
First, install [build_runner], [shelf_open_api], [shelf_open_api_generator] by adding them to your pubspec.yaml file:

```yaml
# pubspec.yaml
dependencies:
  shelf_open_api:

dev_dependencies:
  build_runner:
  shelf_open_api_generator:
```

> It is recommended to use with the [shelf_routing] and [shelf_routing_generator] packages

## Usage

> You can see some examples in [example] folder.

Annotate your routes class with `OpenApi` annotation
```dart
@OpenApiFile()
class MessagesController {
  @Route.get('/messages')
  Future<Response> fetch(Request request) async {
    // Code...
  }
}
```

Run the code generator, you can use:
- `dart run build_runner build`

You can see the generated result in the `public` folder!

Done! See options for more info/configurations.


## But now let's type the routes!

### Typing with: Shelf routing

Hey you could use the [shelf_routing] and [shelf_routing_generator] packages to type your routes
without having to write open api annotations!

```dart
class MessagesController with RouterMixin {
  Router get router => _$MessagesController(this);

  @Route.post('/<messageId>')
  Future<JsonResponse<MessageDto>> get(Request request, int messageId) async {
    // Code...
    return JsonResponse.ok(MessageDto(messageId: messageId));
  }
  
  @Route.post('/')
  Future<JsonResponse<MessageDto>> post(Request request, MessageCreateDto data) async {
    // Code...
    return JsonResponse.ok(MessageDto(messageId: data.messageId));
  }
}

@OpenApi()
class ApiController {
  static const _prefix = '/api-v1';
  
  Router get router => _$ApiController(this);

  @Route.mount('$_prefix/messages')
  MessagesController get messages => MessagesController();
}
```

### Typing with: Open Api Annotations

Use `OpenApiRoute` on routes where the query type or body type needs to be defined.
Remember that you can define the summary and description for each route.
The summary is the first line of each method and must only be in one line otherwise it will be a description of your route.
The [JsonResponse] class can be found in the example. Should I add it to [shelf_open_api] package?

```dart
@OpenApi()
class MessagesController {
  @Route.get('/messages')
  @OpenApiRoute(requestQuery: MessageFetchDto)
  Future<JsonResponse<void>> fetch(Request request) async {
    // Code...
  }
  
  /// This is a summary
  /// 
  /// This is a
  /// long description
  @Route.post('/messages')
  @OpenApiRoute(requestBody: MessageCreateDto)
  Future<JsonResponse<void>> create(Request request) async {
    // Code...
  }
}
```

## More from Open Api Annotations


You can define summaries, descriptions and examples for your queries or requests as well

```dart
class MessageCreateDto {
  /// The id of the chat where the message will be sent
  final String chatId;
  /// The content of the message.
  /// 
  /// You can enter texts and emojis. Images are not supported.
  /// 
  /// `Hi, Luigi!`
  final String content;

  const MessageCreateDto({
    required this.chatId,
    required this.content,
  });
}
```

## Options

You can find many other configuration parameters by looking at the [config](shelf_open_api_generator/lib/src/config.dart) file.

```yaml
targets:
  $default:
    builders:
      shelf_open_api_generator:
        options:
          info: # See more info on open_api_specification.InfoOpenApi class
            title: 'Api'
            description: 'Shelf open api example'
          servers: # See more info on open_api_specification.ServerOpenApi class
            url: 'http://localhost:8080'
          security_schemes: # See more info on open_api_specification.SecuritySchemeOpenApi class
             appwriteJwt:
               type: http
               scheme: Bearer
               bearerFormat: JWT
```

## More

[open_api_client_generator] The purpose of this library is to expose the generation of file with open api specifications from your shelf controllers

[JsonResponse]: example/lib/shared/json_response.dart
[example]: example
[build_runner]: https://pub.dev/packages/build_runner
[shelf_open_api]: https://pub.dev/packages/shelf_open_api
[shelf_open_api_generator]: https://pub.dev/packages/shelf_open_api_generator
[shelf_routing]: https://pub.dev/packages/shelf_routing
[shelf_routing_generator]: https://pub.dev/packages/shelf_routing_generator
[OpenApi Specification]: https://swagger.io/specification/v3/
[open_api_client_generator]: https://pub.dev/packages/open_api_client_generator
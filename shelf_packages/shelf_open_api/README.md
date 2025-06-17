

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
- [ ] `json_serializable` annotations
- [-] Security (Partial implemented)
- [x] Docs (`summary`, `description`, `example`)
- [x] Tags/Groups
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

## Usage

> You can see some examples in [example] folder.

Run the code generator, you can use:
- `<dart|flutter> pub run build_runner build`

You can see the generated result in the `public` folder!

Done! See options for more info/configurations.
But now let's type the routes!

Use `OpenApiRoute` on routes where the query type or body type needs to be defined.
Remember that you can define the summary and description for each route.
The summary is the first line of each method and must only be in one line otherwise it will be a description of your route.
The [JsonResponse] class can be found in the example. Should I add it to [shelf_open_api] package?

```dart
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
          include_routes_in: 'lib/**_controller.dart'
          info_title: 'Api'
          security_schemes:
             appwriteJwt:
               type: http
               scheme: Bearer
               bearerFormat: JWT
```

# Shelf Routing

Have too many controllers in your app? This could save you!

Write something down with `Routing` and a file with all the controllers in your app will be generated!

```dart
@Routing(
  varName: 'controllersRouter',
  generateFor: ['**/*_controller.dart'],
)
void main() {
  // ...
}

// *.g.dart

import 'package:shelf_router/shelf_router.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/messages/controllers/messages_controller.dart';
import 'package:app/features/users/controllers/users_controller.dart';

final $controllersRouter = Router()
  ..mount('/v1', UsersController().router)
  ..mount('/v1', MessagessController().router)
  ..mount('/v1', ChatsController().router);
```

This allows you to annotate your controllers with `@Routes(prefix: '/v1')` to prefix all controller routes.
This annotation is not mandatory!

```dart
@Routes(prefix: '/v1')
class MessagesController {
  // ...
}
```

## Options

```yaml
targets:
  $default:
    builders:
      shelf_open_api_generator:shelf_routing:
        generate_for:
          - '**/*_api.dart'
```

## More

[open_api_client_generator] The purpose of this library is to expose the generation of file with open api specifications from your shelf controllers

[JsonResponse]: example/lib/shared/json_response.dart
[example]: example
[build_runner]: https://pub.dev/packages/build_runner
[shelf_open_api]: https://pub.dev/packages/shelf_open_api
[shelf_open_api_generator]: https://pub.dev/packages/shelf_open_api_generator
[OpenApi Specification]: https://swagger.io/specification/v3/
[open_api_client_generator]: https://pub.dev/packages/open_api_client_generator
import 'package:open_api_client_generator/src/code_utils/codecs.dart';
import 'package:open_api_client_generator/src/options/options.dart';
import 'package:open_api_specification/open_api_spec.dart';

class Context {
  final Options options;
  final ApiCodecs codecs;
  final ComponentsOpenApi components;

  const Context({required this.options, required this.codecs, required this.components});
}

mixin ContextMixin {
  Context get context;

  Options get options => context.options;
  ApiCodecs get codecs => context.codecs;
  ComponentsOpenApi get components => context.components;
}

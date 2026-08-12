import 'package:open_api_client_generator/src/code_utils/codecs.dart';
import 'package:open_api_client_generator/src/options/options.dart';
import 'package:open_api_client_generator/src/type_codec.dart';
import 'package:open_api_specification/open_api_spec.dart';

class Context {
  final Options options;
  final ApiCodecs codecs;
  final ComponentsOpenApi components;
  final List<TypeCodec> typeCodecs;

  const Context({
    required this.options,
    required this.codecs,
    required this.components,
    required this.typeCodecs,
  });
}

mixin ContextMixin {
  Context get context;

  Options get options => context.options;
  ApiCodecs get codecs => context.codecs;
  ComponentsOpenApi get components => context.components;
}

import 'package:open_api_client_generator/src/code_utils/codecs.dart';
import 'package:open_api_client_generator/src/options/options.dart';

class Context {
  final Options options;
  final ApiCodecs codecs;

  Context({
    required this.options,
    required this.codecs,
  });
}

mixin ContextMixin {
  Context get context;

  Options get options => context.options;
  ApiCodecs get codecs => context.codecs;
}

import 'package:shelf/shelf.dart';

/// Getter definition for dependency injection.
typedef RequestGetter = T Function<T extends Object>(Request request);

/// Dependency injection extensions.
extension GetterRequestExtensions on Request {
  static const String _key = '_getter';

  /// Retrieve data using the getter injected into the request via the [GetterMiddleware] middleware.
  T get<T extends Object>() {
    final getter = context[_key] as RequestGetter?;

    assert(
      getter != null,
      'Missing getter scope in request context.\nUse getterScope method to provider it.',
    );

    return getter!<T>(this);
  }

  /// Change the dependency injection [getter].
  Request changeGetter(RequestGetter getter) => change(context: {_key: getter});
}

/// [Middleware] to inject [_getter] to retrieve data by dependency injection.
class GetterMiddleware {
  final RequestGetter _getter;

  /// See class documentation
  const GetterMiddleware(this._getter);

  /// [Middleware] method
  Handler call(Handler innerHandler) {
    return (request) {
      // ignore: discarded_futures
      return innerHandler(request.changeGetter(_getter));
    };
  }
}

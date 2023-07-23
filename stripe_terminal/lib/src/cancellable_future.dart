import 'dart:async';

class CancelableFuture<T> implements Future<T> {
  final Future<T> Function(int id) _onStart;
  final Future<void> Function(int id) _onStop;

  CancelableFuture(this._onStop, this._onStart);

  late final Future<T> result = _onStart(hashCode);

  Future<void> cancel() => _onStop(hashCode);

  @override
  Stream<T> asStream() => result.asStream();

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      result.catchError(onError, test: test);

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue, {Function? onError}) =>
      result.then(onValue, onError: onError);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      result.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) => result.whenComplete(action);
}

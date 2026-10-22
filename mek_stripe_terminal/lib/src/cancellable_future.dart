import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class CancelableFuture<T> implements Future<T> {
  late final Future<T> result = onStart(hashCode);

  Future<void> cancel() => onStop(hashCode);

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

  @protected
  Future<T> onStart(int id);

  @protected
  Future<void> onStop(int id);
}

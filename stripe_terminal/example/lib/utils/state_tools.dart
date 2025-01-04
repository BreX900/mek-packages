import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: avoid_print
void report(String message) => print(message);

mixin StateTools<T extends StatefulWidget> on State<T> {
  var _isMutating = false;
  bool get isMutating => _isMutating;

  var _listeners = <ValueListenable>{};

  @override
  void dispose() {
    for (final listenable in _listeners) {
      listenable.removeListener(_onListenableChange);
    }
    _listeners = const {};
    super.dispose();
  }

  // ignore: avoid_void_async
  void mutate(Future<void> Function() body) async {
    if (isMutating) return;
    setState(() => _isMutating = true);
    try {
      await body();
    } catch (error) {
      showSnackBar('$error');
      rethrow;
    } finally {
      setState(() => _isMutating = false);
    }
  }

  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
  }

  R watch<R>(ValueListenable<R> listenable) {
    if (!_listeners.contains(listenable)) listenable.addListener(_onListenableChange);
    return listenable.value;
  }

  void _onListenableChange() => setState(_noop);

  static void _noop() {}
}

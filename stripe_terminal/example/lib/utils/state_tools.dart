import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: avoid_print
void report(String message) => print(message);

abstract class ConsumerRef {
  R watch<R>(ValueListenable<R> listenable);
}

abstract class ConsumerStatefulWidget extends StatefulWidget {
  const ConsumerStatefulWidget({super.key});

  @override
  StatefulElement createElement() => _ConsumerStatefulElement(this);
}

abstract class ConsumerState<T extends ConsumerStatefulWidget> extends State<T> {
  ConsumerRef get ref => context as ConsumerRef;
}

class _ConsumerStatefulElement extends StatefulElement implements ConsumerRef {
  var _dependencies = <ValueListenable>[];
  var _oldDependencies = const <ValueListenable>[];

  _ConsumerStatefulElement(super.widget);

  @override
  void unmount() {
    for (final listenable in _dependencies) {
      listenable.removeListener(markNeedsBuild);
    }
    _dependencies = const [];
    super.unmount();
  }

  @override
  R watch<R>(ValueListenable<R> listenable) {
    if (!_dependencies.contains(listenable)) {
      if (!_oldDependencies.contains(listenable)) listenable.addListener(markNeedsBuild);
      _dependencies.add(listenable);
    }
    return listenable.value;
  }

  @override
  Widget build() {
    _oldDependencies = _dependencies;
    _dependencies = [];
    try {
      return super.build();
    } finally {
      for (final oldListenable in _oldDependencies) {
        if (_dependencies.contains(oldListenable)) continue;
        oldListenable.removeListener(markNeedsBuild);
      }
      _oldDependencies = const [];
    }
  }
}

mixin StateTools<T extends StatefulWidget> on State<T> {
  var _isMutating = false;
  bool get isMutating => _isMutating;

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
}

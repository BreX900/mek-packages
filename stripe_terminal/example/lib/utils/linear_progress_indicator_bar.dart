import 'package:flutter/material.dart';

class LinearProgressIndicatorBar extends StatelessWidget implements PreferredSizeWidget {
  const LinearProgressIndicatorBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(0.0);

  @override
  Widget build(BuildContext context) {
    return const SizedOverflowBox(
      alignment: Alignment.bottomCenter,
      size: Size.fromHeight(0.0),
      child: LinearProgressIndicator(),
    );
  }
}

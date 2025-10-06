import 'package:devtools_plus/core/widgets/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcuts extends StatelessWidget {
  final Widget child;

  const KeyboardShortcuts({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          showCommandPalette(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          showCommandPalette(context);
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}

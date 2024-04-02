import 'package:flutter/material.dart';

import 'util/rounded_edge_clipper.dart';

class MyDialog extends StatelessWidget {
  const MyDialog({
    super.key,
    required this.title,
    this.titleStyle,
    this.subtitle,
    required this.child,
  });

  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final titleStyle = this.titleStyle ?? Theme.of(context).textTheme.titleMedium;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipPath(
        clipper: RoundedEdgeClipper(edgeCutDepth: 30),
        child: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: titleStyle,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
                SizedBox(height: 32),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> animateDialog<T extends Object?>({
  required BuildContext context,
  bool barrierDismissible = true,
  bool canPop = true,
  required Widget dialog,
}) {
  return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: PopScope(
                canPop: canPop,
                child: dialog
            )
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 180),
      barrierDismissible: barrierDismissible,
      barrierLabel: "",
      context: context,
      pageBuilder: (context, animation1, animation2) { return Container(); }
  );
}
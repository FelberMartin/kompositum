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
                  style: titleStyle == null
                      ? Theme.of(context).textTheme.titleSmall
                      : titleStyle,
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

void animateDialog({
  required BuildContext context,
  bool barrierDismissible = true,
  required Widget dialog,
}) {
  showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: dialog,
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
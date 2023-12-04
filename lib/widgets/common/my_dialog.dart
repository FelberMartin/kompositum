import 'package:flutter/material.dart';

import 'util/rounded_edge_clipper.dart';

class MyDialog extends StatelessWidget {
  const MyDialog({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
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
                  style: Theme.of(context).textTheme.titleSmall,
                ),
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
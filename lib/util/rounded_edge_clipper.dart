import 'package:flutter/material.dart';

class RoundedEdgeClipper extends CustomClipper<Path> {

  final double edgeCutDepth;
  final bool onTop;
  final bool onBottom;

  RoundedEdgeClipper({
    this.edgeCutDepth = 20,
    this.onTop = true,
    this.onBottom = true,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();

    if (onTop) {
      path.moveTo(0, edgeCutDepth);
      path.addArc(
        Rect.fromCenter(
          center: Offset(size.width / 2, edgeCutDepth),
          height: edgeCutDepth * 2,
          width: size.width,
        ),
        3.14,
        3.14,
      );
      path.lineTo(size.width, size.height);
    } else {
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    }

    if (onBottom) {
      path.lineTo(size.width, size.height - edgeCutDepth);
      path.addArc(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height - edgeCutDepth),
          height: edgeCutDepth * 2,
          width: size.width,
        ),
        0,
        3.14,
      );
    } else {
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    path.lineTo(0, onTop ? edgeCutDepth : 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
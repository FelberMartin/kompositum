import 'package:flutter/material.dart';

class IconStyledText extends StatelessWidget {
  const IconStyledText({
    super.key,
    required this.text,
    this.strokeWidth = 3.0,
    this.style = const TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.normal,
    )
  });

  final String text;
  final double strokeWidth;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeJoin = StrokeJoin.round
          ..color = Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
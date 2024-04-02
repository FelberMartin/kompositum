import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Shake Widget')),
      body: Center(
        child: ShakeWidget(
          key: _shakeKey,
          duration: Duration(milliseconds: 300),
          deltaX: 40,
          curve: Curves.bounceOut,
          child: ElevatedButton(
            onPressed: () {
              _shakeKey.currentState?.shake();
            },
            child: Text('Shake Me'),
          ),
        ),
      ),
    ),
  ));
}

class ShakeWidget extends StatefulWidget {
  ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
    this.shakeCount = 5,
    this.deltaX = 10,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final int shakeCount;
  final double deltaX;


  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>   with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() => setState(() {}));

    animation = Tween<double>(
      begin: 00.0,
      end: 120.0,
    ).animate(animationController);

    animationController.forward(from:0);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  double _shake() {
    double progress = widget.curve.transform(animationController.value);
    return sin(progress * pi * widget.shakeCount);  // change 10 to make it vibrate faster
  }

  shake() {
    animationController.forward(from:0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(widget.deltaX * _shake(), 0.0),
      child: widget.child,
    );
  }
}

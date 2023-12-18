import 'package:flutter/material.dart';

class My3dContainer extends StatefulWidget {

  const My3dContainer({
    required this.child,
    required this.topColor,
    required this.sideColor,
    this.clickable = false,
    this.onPressed,
    super.key,
  });

  final Widget child;
  final Color topColor;
  final Color sideColor;
  final bool clickable;
  final Function? onPressed;

  static const topInset = 4.0;
  static const leftInset = 1.0;

  @override
  State<My3dContainer> createState() => _My3dContainerState();
}

class _My3dContainerState extends State<My3dContainer> {

  bool _isPressedDown = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          child: _EmbedChild(
            backgroundColor: widget.sideColor,
            borderColor: widget.sideColor,
            elevation: 0,
            clickable: false,
            child: widget.child,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          top: _isPressedDown ? 0 : -My3dContainer.topInset,
          left: _isPressedDown ? 0 : -My3dContainer.leftInset,
          bottom: _isPressedDown ? 0 : My3dContainer.topInset,
          right: _isPressedDown ? 0 : My3dContainer.leftInset,

          child: _EmbedChild(
            backgroundColor: widget.topColor,
            borderColor: widget.sideColor,
            elevation: 4,
            clickable: widget.clickable,
            onTapDown: () {
              setState(() {
                _isPressedDown = true;
              });
            },
            onTapUp: () {
              setState(() {
                _isPressedDown = false;
              });
              if (widget.onPressed != null) widget.onPressed!();
            },
            child: widget.child,
          ),
        )
      ],
    );
  }
}

class _EmbedChild extends StatelessWidget {
  const _EmbedChild({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.elevation,
    required this.clickable,
    this.onTapDown,
    this.onTapUp,
    required this.child,
  });

  final Color backgroundColor;
  final Color borderColor;
  final double elevation;
  final bool clickable;
  final Function? onTapDown;
  final Function? onTapUp;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (clickable) assert(onTapDown != null && onTapUp != null);
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: 1.0,   // Hairline border
        ),
      ),
      elevation: elevation,
      child: GestureDetector(
        onTapDown: clickable ? (details) => onTapDown!() : null,
        onTapUp: clickable ? (details) => onTapUp!() : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: child,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class My3dContainer extends StatefulWidget {

  const My3dContainer({
    super.key,
    required this.child,
    required this.topColor,
    required this.sideColor,
    this.clickable = false,
    this.onPressed,
    this.animationDuration = const Duration(milliseconds: 100),
    this.cornerRadius = 10,
  });

  final Widget child;
  final Color topColor;
  final Color sideColor;
  final bool clickable;
  final Function? onPressed;
  final Duration animationDuration;
  final double cornerRadius;

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
          // Background
          _EmbedChild(
            backgroundColor: widget.sideColor,
            borderColor: widget.sideColor,
            elevation: 0,
            clickable: false,
            animationDuration: widget.animationDuration,
            cornerRadius: widget.cornerRadius,
            child: widget.child,
          ),
          // Foreground
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            top: _isPressedDown ? 0 : -My3dContainer.topInset,
            left: _isPressedDown ? 0 : -My3dContainer.leftInset,
            bottom: _isPressedDown ? 0 : My3dContainer.topInset,
            right: _isPressedDown ? 0 : My3dContainer.leftInset,
            curve: Curves.ease,
            child: _EmbedChild(
              backgroundColor: widget.topColor,
              borderColor: widget.sideColor,
              elevation: 0,
              animationDuration: widget.animationDuration,
              cornerRadius: widget.cornerRadius,
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
              onTapCancel: () {
                setState(() {
                  _isPressedDown = false;
                });
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
    this.onTapCancel,
    required this.animationDuration,
    required this.child,
    required this.cornerRadius,
  });

  final Color backgroundColor;
  final Color borderColor;
  final double elevation;
  final bool clickable;
  final Function? onTapDown;
  final Function? onTapUp;
  final Function? onTapCancel;
  final Widget child;
  final Duration animationDuration;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    if (clickable) assert(onTapDown != null && onTapUp != null);
    return Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        elevation: elevation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cornerRadius),
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: clickable ? (details) => onTapDown!() : null,
            onPointerUp: clickable ? (details) => onTapUp!() : null,
            onPointerCancel: clickable ? (x) => onTapCancel!() : null,
            child: AnimatedSize(
              curve: Curves.ease,
              duration: animationDuration,
              child: child,
            ),
          ),
        ),
    );
  }
}
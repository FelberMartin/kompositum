import 'package:flutter/material.dart';

import '../../util/color_util.dart';



class My3dContainer extends StatelessWidget {

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
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          top: topInset,
          left: leftInset,
          bottom: -topInset,
          right: -leftInset,
          child: _embedChild(
            backgroundColor: sideColor,
            elevation: 0,
            clickable: false,
            child: child,
          ),
        ),
        Positioned(
          child: _embedChild(
            backgroundColor: topColor,
            elevation: 4,
            clickable: clickable,
            child: child,
          ),
        )
      ],
    );
  }

  Widget _embedChild({
    required Color backgroundColor,
    required double elevation,
    required bool clickable,
    required Widget child,
  }) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: elevation,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: clickable ? () => onPressed!() : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: child,
        ),
      ),
    );
  }
}

class MyPrimaryButton extends StatelessWidget {

  const MyPrimaryButton({
    this.enabled = true,
    required this.onPressed,
    required this.child,
    super.key,
  });

  final bool enabled;
  final Function onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return My3dContainer(
      topColor: Theme.of(context).colorScheme.primary,
      sideColor: darken(Theme.of(context).colorScheme.primary, 10),
      clickable: enabled,
      onPressed: onPressed,
      child: child,
    );
  }
}


class MyPrimaryTextButton extends StatelessWidget {

  const MyPrimaryTextButton({
    required this.onPressed,
    required this.text,
    this.enabled = true,
    super.key,
  });

  final Function onPressed;
  final String text;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium!;
    return MyPrimaryButton(
      enabled: enabled,
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}

class MyPrimaryTextButtonLarge extends StatelessWidget {

  const MyPrimaryTextButtonLarge({
    required this.onPressed,
    required this.text,
    super.key,
  });

  final Function onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge!;
    return My3dContainer(
      topColor: Theme.of(context).colorScheme.primary,
      sideColor: darken(Theme.of(context).colorScheme.primary, 10),
      clickable: true,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: textStyle.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class MySecondaryTextButton extends StatelessWidget {

  const MySecondaryTextButton({
    required this.onPressed,
    required this.text,
    super.key,
  });

  final Function onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium!;
    return My3dContainer(
      topColor: Theme.of(context).colorScheme.secondary,
      sideColor: Theme.of(context).colorScheme.primary,
      clickable: true,
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle.copyWith(color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../config/my_theme.dart';
import '../../util/color_util.dart';
import 'my_3d_container.dart';


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
      sideColor: MyColorPalette.of(context).primaryShade,
      clickable: enabled,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
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
        style: textStyle.copyWith(
            color: enabled
                ? Theme.of(context).colorScheme.onPrimary
                : MyColorPalette.of(context).textSecondary
        ),
      ),
    );
  }
}

class MyPrimaryTextButtonLarge extends StatelessWidget {

  const MyPrimaryTextButtonLarge({
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
    final textStyle = Theme.of(context).textTheme.labelLarge!;
    return My3dContainer(
      topColor: Theme.of(context).colorScheme.primary,
      sideColor: MyColorPalette.of(context).primaryShade,
      clickable: enabled,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: textStyle.height,
          child: FittedBox(
            child: Text(
              text,
              style: textStyle.copyWith(color: enabled
                  ? Theme.of(context).colorScheme.onPrimary
                    : MyColorPalette.of(context).textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class MySecondaryButton extends StatelessWidget {

  const MySecondaryButton({
    required this.onPressed,
    this.enabled = true,
    required this.child,
    super.key,
  });

  final bool enabled;
  final Function onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return My3dContainer(
      topColor: Theme.of(context).colorScheme.secondary,
      sideColor: MyColorPalette.of(context).secondaryShade,
      clickable: enabled,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}

class MySecondaryTextButton extends StatelessWidget {

  const MySecondaryTextButton({
    required this.onPressed,
    required this.text,
    this.enabled = true,
    this.trailingIcon,
    super.key,
  });

  final Function onPressed;
  final String text;
  final bool enabled;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium!;
    return MySecondaryButton(
      onPressed: onPressed,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: textStyle.copyWith(
                  color: enabled
                      ? Theme.of(context).colorScheme.onSecondary
                      : MyColorPalette.of(context).textSecondary
              ),
            ),
            if (trailingIcon != null) trailingIcon!,
          ],
        ),
      )
    );
  }
}
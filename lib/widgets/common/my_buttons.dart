import 'package:flutter/material.dart';

import '../../config/theme.dart';
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
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return MyPrimaryButton(
      enabled: enabled,
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle.copyWith(
            color: enabled
                ? Theme.of(context).colorScheme.onPrimary
                : customColors.textSecondary
        ),
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
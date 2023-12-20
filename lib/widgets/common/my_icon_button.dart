import 'package:flutter/material.dart';
import 'package:kompositum/config/theme.dart';

import 'my_3d_container.dart';


class MyIconButtonInfo {
  const MyIconButtonInfo({
    required this.icon,
    required this.onPressed,
    required this.enabled,
  });

  final IconData icon;
  final Function onPressed;
  final bool enabled;

}

class MyIconButton extends StatelessWidget {
  const MyIconButton({
    required this.icon,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  MyIconButton.fromInfo({
    required info,
    super.key,
  }) : icon = info.icon,
       onPressed = info.onPressed,
       enabled = info.enabled;

  final IconData icon;
  final Function onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final iconColor = enabled ? Theme.of(context).colorScheme.onSecondary : customColors.textSecondary;
    const size = 48.0;
    return My3dContainer(
      topColor: Theme.of(context).colorScheme.secondary,
      sideColor: Theme.of(context).colorScheme.primary,
      clickable: enabled,
      onPressed: onPressed,
      cornerRadius: size / 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:kompositum/config/my_theme.dart';

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

  static Widget centered({
    required IconData icon,
    required Function onPressed,
    bool enabled = true,
  }) => Padding(
    padding: const EdgeInsets.only(top: My3dContainer.topInset),
    child: MyIconButton(
      icon: icon,
      onPressed: onPressed,
      enabled: enabled,
    ),
  );

  final IconData icon;
  final Function onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final iconColor = enabled
        ? Theme.of(context).colorScheme.onSecondary
        : MyColorPalette.of(context).textSecondary;
    const size = 40.0;
    const padding = 8.0;
    return My3dContainer(
      topColor: Theme.of(context).colorScheme.secondary,
      sideColor: MyColorPalette.of(context).secondaryShade,
      clickable: enabled,
      onPressed: onPressed,
      cornerRadius: size,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Icon(
          icon,
          color: iconColor,
          size: size - 2 * padding,
        ),
      ),
    );
  }
}
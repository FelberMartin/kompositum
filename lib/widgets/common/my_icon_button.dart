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

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 4,
          left: 1,
          child: SizedBox(
            width: size,
            height: size,
            child: Card(
              color: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 0,
              ),
            ),
        ),
          SizedBox(
            width: size,
            height: size,
            child: Card(
              color: Theme.of(context).colorScheme.secondary,
              shape: CircleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 0,
                ),
              ),
              elevation: 4,
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                onTap: enabled ? () => onPressed() : null,
                child: Icon(
                  icon,
                  color: iconColor,
                ),
                ),
              ),
            ),
      ],
    );
  }
}
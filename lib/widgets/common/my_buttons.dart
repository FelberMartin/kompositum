import 'package:flutter/material.dart';

import '../../util/color_util.dart';

class MyPrimaryButton extends StatelessWidget {

  const MyPrimaryButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final Function onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: -5,
            right: -1.5,
            child: _embedChild(
              backgroundColor: darken(Theme.of(context).colorScheme.primary),
              elevation: 0,
              clickable: false,
              child: child,
            ),
          ),
          _embedChild(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 4,
            clickable: true,
            child: child,
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
        onTap: clickable ? () => onPressed() : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: child,
        ),
      ),
    );
  }
}


class MySecondaryButton extends StatelessWidget {

  const MySecondaryButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final Function onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: -5,
          right: -1.5,
          child: _embedChild(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            clickable: false,
            child: child,
          ),
        ),
        _embedChild(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          elevation: 4,
          clickable: true,
          child: child,
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
        onTap: clickable ? () => onPressed() : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: child,
        ),
      ),
    );
  }
}


class MyPrimaryTextButton extends StatelessWidget {

  const MyPrimaryTextButton({
    required this.onPressed,
    required this.text,
    super.key,
  });

  final Function onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium!;
    return MyPrimaryButton(
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
    return MyPrimaryButton(
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
    return MySecondaryButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle.copyWith(color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }
}
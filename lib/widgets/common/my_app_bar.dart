import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:kompositum/main.dart';
import 'package:kompositum/widgets/common/util/clip_shadow_path.dart';
import 'package:kompositum/widgets/common/util/rounded_edge_clipper.dart';

import '../../config/theme.dart';
import 'my_icon_button.dart';


const AppBarHeight = 80.0;

class MyDefaultAppBar extends StatelessWidget implements PreferredSizeWidget {

  const MyDefaultAppBar({
    super.key,
    required this.navigationIcon,
    required this.onNavigationPressed,
    this.middleContent,
    required this.starCount,
    this.animateStarCount = false,
  });

  final IconData navigationIcon;
  final Function onNavigationPressed;
  final Widget? middleContent;
  final int starCount;
  final bool animateStarCount;

  @override
  Size get preferredSize => const Size.fromHeight(AppBarHeight);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return MyAppBar(
      leftContent: Center(
        child: MyIconButton.centered(
          icon: navigationIcon,
          onPressed: onNavigationPressed,
        ),
      ),
      middleContent: middleContent ?? Container(),
      rightContent: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedFlipCounter(
            duration: Duration(milliseconds: animateStarCount ? 300 : 0),
            value: starCount,
            thousandSeparator: ".",
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          Icon(
            Icons.star_rounded,
            color: customColors.star,
          ),
          SizedBox(width: 16.0),
        ],
      ),
    );
  }
}


class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    required this.leftContent,
    required this.middleContent,
    required this.rightContent,
    super.key,
  });

  final Widget leftContent;
  final Widget middleContent;
  final Widget rightContent;

  @override
  Size get preferredSize => const Size.fromHeight(AppBarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipShadowPath(
      clipper: RoundedEdgeClipper(onTop: false),
      shadow: Shadow(
        color: Theme.of(context).colorScheme.shadow,
        blurRadius: 2,
      ),
      child: Container(
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          clipBehavior: Clip.none,
          leading: leftContent,
          title: middleContent,
          centerTitle: true,
          actions: [rightContent],
        ),
      ),
    );
  }
}

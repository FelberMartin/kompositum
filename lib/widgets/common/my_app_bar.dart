import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:kompositum/widgets/common/util/clip_shadow_path.dart';
import 'package:kompositum/widgets/common/util/corner_radius.dart';
import 'package:kompositum/widgets/common/util/rounded_edge_clipper.dart';

import '../../config/my_icons.dart';
import '../../config/my_theme.dart';
import 'my_icon_button.dart';


const AppBarHeight = 66.0;

class MyDefaultAppBar extends StatelessWidget implements PreferredSizeWidget {

  const MyDefaultAppBar({
    super.key,
    this.navigationIcon = MyIcons.navigateBack,
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
          SizedBox(width: 4.0),
          Icon(
            MyIcons.star,
            color: MyColorPalette.of(context).star,
            size: 18,
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
    return AppBar(
      shadowColor: Theme.of(context).colorScheme.shadow,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(CornerRadius.large),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      leading: leftContent,
      title: middleContent,
      centerTitle: true,
      actions: [rightContent],
    );
  }
}

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:kompositum/config/flavors/flavor.dart';
import 'package:kompositum/game/difficulty.dart';

import '../../config/my_theme.dart';
import '../common/my_app_bar.dart';

class TopRow extends StatelessWidget implements PreferredSizeWidget {
  const TopRow({
    super.key,
    required this.onBackPressed,
    required this.title,
    required this.subtitle,
    required this.starCount,
  });

  final VoidCallback onBackPressed;
  final String title;
  final Widget subtitle;
  final int starCount;

  @override
  Size get preferredSize => const Size.fromHeight(AppBarHeight);

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );

    // If the title is a level count, display it as an animated flip counter
    final levelCountPrefix = Flavor.instance.uiString.lblLevelIndicator + " ";
    if (title.startsWith(levelCountPrefix)) {
      final prefix = levelCountPrefix;
      final value = int.parse(title.split(" ")[1]);
      titleWidget = AnimatedFlipCounter(
        duration: const Duration(milliseconds: 600),
        value: value,
        prefix: prefix,
        textStyle: Theme.of(context).textTheme.titleMedium,
      );
    }

    return MyDefaultAppBar(
      onNavigationPressed: onBackPressed,
      middleContent: Column(
        children: [
          SizedBox(height: 4.0),
          titleWidget,
          SizedBox(height: 4.0),
          subtitle,
        ],
      ),
      starCount: starCount,
      animateStarCount: true,
    );
  }
}
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:kompositum/game/difficulty.dart';

import '../../config/my_theme.dart';
import '../common/my_app_bar.dart';

class TopRow extends StatelessWidget implements PreferredSizeWidget {
  const TopRow({
    super.key,
    required this.onBackPressed,
    required this.difficulty,
    required this.title,
    required this.starCount,
  });

  final VoidCallback onBackPressed;
  final Difficulty difficulty;
  final String title;
  final int starCount;

  @override
  Size get preferredSize => const Size.fromHeight(AppBarHeight);

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
    if (title.startsWith("Level ")) {
      final prefix = "Level ";
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
          Text(
            difficulty.uiText.toLowerCase(),
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: MyColorPalette.of(context).textSecondary,
            ),
          ),
        ],
      ),
      starCount: starCount,
      animateStarCount: true,
    );
  }
}
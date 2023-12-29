import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:format/format.dart';

import '../../config/theme.dart';
import '../../game/level_provider.dart';
import '../common/my_app_bar.dart';
import '../common/my_icon_button.dart';

class TopRow extends StatelessWidget implements PreferredSizeWidget {
  const TopRow({
    super.key,
    required this.onBackPressed,
    required this.displayedDifficulty,
    required this.title,
    required this.levelProgress,
    required this.starCount,
  });

  final VoidCallback onBackPressed;
  final Difficulty displayedDifficulty;
  final String title;
  final double levelProgress;
  final int starCount;

  @override
  Size get preferredSize => const Size.fromHeight(AppBarHeight);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return MyDefaultAppBar(
      navigationIcon: FontAwesomeIcons.chevronLeft,
      onNavigationPressed: onBackPressed,
      middleContent: Column(
        children: [
          SizedBox(height: 16.0),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 4.0),
          Text(
            displayedDifficulty.toUiString().toLowerCase(),
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: customColors.textSecondary,
            ),
          ),
        ],
      ),
      starCount: starCount,
    );
  }
}
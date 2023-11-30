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
    required this.levelNumber,
    required this.levelProgress,
    required this.starCount,
  });

  final VoidCallback onBackPressed;
  final Difficulty displayedDifficulty;
  final int levelNumber;
  final double levelProgress;
  final int starCount;

  @override
  Size get preferredSize => Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return MyAppBar(
      leftContent: Center(
        child: MyIconButton(
          icon: FontAwesomeIcons.chevronLeft,
          onPressed: onBackPressed,
        ),
      ),
      middleContent: Column(
        children: [
          SizedBox(height: 16.0),
          Text(
            "Level $levelNumber",
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
      rightContent: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            // Format the starcount with a separator for thousands
            "{:,d}".format([starCount]),
            style: Theme.of(context).textTheme.labelLarge,
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
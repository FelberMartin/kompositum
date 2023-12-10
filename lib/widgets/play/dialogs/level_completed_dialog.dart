
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';

import '../../../config/star_costs_rewards.dart';
import '../../../config/theme.dart';
import '../../common/my_dialog.dart';

void main() => runApp(MaterialApp(
    theme: myTheme,
    home: LevelCompletedDialog(onContinuePressed: () {}, difficulty: Difficulty.easy,))
);

class LevelCompletedDialog extends StatelessWidget {

  const LevelCompletedDialog({
    super.key,
    required this.onContinuePressed,
    required this.difficulty,
  });

  final Function onContinuePressed;
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: "Glückwunsch!",
      titleStyle: Theme.of(context).textTheme.titleMedium,
      subtitle: "Level geschaft!",
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Center(
              child: StarBonusInfo(difficulty: difficulty)
            )
          ),
          MyPrimaryTextButtonLarge(onPressed: onContinuePressed, text: "Weiter")
        ],
      ),
    );
  }

}

class StarBonusInfo extends StatelessWidget {
  const StarBonusInfo({
    super.key,
    required this.difficulty,
  });

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "+ ${Rewards.byDifficulty(difficulty)}",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              FontAwesomeIcons.solidStar,
              color: customColors.star,
              size: 32,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "(${difficulty.toUiString().toLowerCase()})",
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: customColors.textSecondary,
          ),
        )
      ],
    );
  }
}
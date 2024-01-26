import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';

import '../../../config/my_icons.dart';
import '../../../config/star_costs_rewards.dart';
import '../../../config/my_theme.dart';
import '../../common/my_dialog.dart';

void main() => runApp(MaterialApp(
    theme: myTheme,
    home: LevelCompletedDialog(
      type: LevelCompletedDialogType.classic,
      failedAttempts: 0,
      difficulty: Difficulty.easy,
      nextLevelNumber: 2,
      onContinue: (result) {},
    )));


enum LevelCompletedDialogType {
  classic,
  daily,
}

enum LevelCompletedDialogResultType {
  classic_continue,
  daily_continueWithClassic,
  daily_backToOverview,
}

class LevelCompletedDialogResult {
  final LevelCompletedDialogResultType type;
  final int starCountIncrease;

  LevelCompletedDialogResult({
    required this.type,
    required this.starCountIncrease,
  });
}

class LevelCompletedDialog extends StatelessWidget {

  static const List<String> titles = [
    "Glückwunsch!",
    "Super!",
    "Fantastisch!",
    "Perfekt!",
    "Gut gemacht!",
    "Bravo!",
    "Genial!",
    "Sensationell!",
    "Klasse!",
    "Wow!",
    "Ausgezeichnet!",
    "Großartig!",
    "Einfach stark!"
  ];

  LevelCompletedDialog({
    super.key,
    required this.type,
    required this.failedAttempts,
    required this.difficulty,
    required this.nextLevelNumber,
    required this.onContinue,
  }) {
    title = titles[Random().nextInt(titles.length)];
  }

  final LevelCompletedDialogType type;
  final int failedAttempts;
  final Difficulty difficulty;
  final int nextLevelNumber;
  final Function(LevelCompletedDialogResult) onContinue;

  late final String title;


  @override
  Widget build(BuildContext context) {
    final starsForFailedAttempts = Rewards.getStarCountForFailedAttempts(
      failedAttempts,
    );
    final starsForDifficulty = Rewards.byDifficulty(
      difficulty,
    );
    final totalStars = starsForFailedAttempts + starsForDifficulty;

    var bottomContent;
    if (type == LevelCompletedDialogType.classic) {
      bottomContent = MyPrimaryTextButtonLarge(
        text: "Weiter",
        onPressed: () {
          onContinue(LevelCompletedDialogResult(
            type: LevelCompletedDialogResultType.classic_continue,
            starCountIncrease: totalStars,
          ));
        },
      );
    } else if (type == LevelCompletedDialogType.daily) {
      bottomContent = Column(
        children: [
          MySecondaryTextButton(
            text: "Zurück zur Übersicht",
            onPressed: () {
              onContinue(LevelCompletedDialogResult(
                type: LevelCompletedDialogResultType.daily_backToOverview,
                starCountIncrease: totalStars,
              ));
            },
          ),
          SizedBox(height: 8),
          MyPrimaryTextButton(
            text: "Level $nextLevelNumber",
            onPressed: () {
              onContinue(LevelCompletedDialogResult(
                type: LevelCompletedDialogResultType.daily_continueWithClassic,
                starCountIncrease: totalStars,
              ));
            },
          ),
        ],
      );
    }

    return MyDialog(
      title: title,
      titleStyle: Theme.of(context).textTheme.titleMedium,
      subtitle: "Level geschaft!",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        StarItem(
                          title: "Fehlversuche",
                          value: failedAttempts.toString(),
                          starCount: starsForFailedAttempts,
                        ),
                        SizedBox(height: 16),
                        StarItem(
                          title: "Schwierigkeit",
                          value: difficulty.toUiString().toLowerCase(),
                          starCount: starsForDifficulty,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: MyColorPalette.of(context).textSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TotalRow(totalStars: totalStars),
                  )
                ],
              ),
            ),
            SizedBox(height: 16),
            bottomContent,
          ],
        ),
      ),
    );
  }
}

class TotalRow extends StatefulWidget {
  const TotalRow({
    super.key,
    required this.totalStars,
  });

  final int totalStars;

  @override
  State<TotalRow> createState() => _TotalRowState();
}

class _TotalRowState extends State<TotalRow> {
  int _totalStars = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        _totalStars = widget.totalStars;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "TOTAL",
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: MyColorPalette.of(context).textSecondary,
              ),
        ),
        Expanded(child: Container()),
        AnimatedFlipCounter(
          value: _totalStars,
          prefix: "+",
          textStyle: Theme.of(context).textTheme.titleMedium,
          duration: Duration(milliseconds: _totalStars * 60),
        ),
        SizedBox(width: 5.0),
        Icon(
          MyIcons.star,
          size: 24,
          color: MyColorPalette.of(context).star,
        ),
      ],
    );
  }
}

class StarItem extends StatelessWidget {
  const StarItem({
    super.key,
    required this.title,
    required this.value,
    required this.starCount,
  });

  final String title;
  final String value;
  final int starCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: MyColorPalette.of(context).textSecondary,
                )),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Expanded(child: Container()),
            Text(
              "+$starCount",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            SizedBox(width: 3.0),
            Icon(
              MyIcons.star,
              color: MyColorPalette.of(context).star,
              size: 16,
            )
          ],
        ),
      ],
    );
  }
}

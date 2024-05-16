import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:kompositum/config/locator.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/home/daily_goals_container.dart';

import '../../../config/my_icons.dart';
import '../../../config/my_theme.dart';
import '../../../config/star_costs_rewards.dart';
import '../../../data/models/daily_goal_set.dart';
import '../../../game/goals/daily_goal_set_manager.dart';
import '../../common/my_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(MaterialApp(
      theme: myTheme,
      home: LevelCompletedDialog(
        type: LevelCompletedDialogType.classic,
        failedAttempts: 0,
        difficulty: Difficulty.easy,
        nextLevelNumber: 2,
        onContinue: (result) {},
      )));
}


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

class LevelCompletedDialog extends StatefulWidget {

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

  DailyGoalSet? dailyGoalSet;

  @override
  State<LevelCompletedDialog> createState() => _LevelCompletedDialogState();
}

class _LevelCompletedDialogState extends State<LevelCompletedDialog> {
  final DailyGoalSetManager dailyGoalSetManager = locator<DailyGoalSetManager>();

  @override
  void initState() {
    super.initState();
    dailyGoalSetManager.getDailyGoalSet().then((value) {
      setState(() {
        widget.dailyGoalSet = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final starsForFailedAttempts = Rewards.getStarCountForFailedAttempts(
      widget.failedAttempts,
    );
    final starsForDifficulty = Rewards.byDifficulty(
      widget.difficulty,
    );
    final totalStars = starsForFailedAttempts + starsForDifficulty;

    return Scaffold(
      backgroundColor: MyColorPalette.of(context).secondary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            children: [
              Expanded(child: Container()),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12),
              Text(
                "Level geschaft!",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Expanded(child: Container()),
              LevelRewardCalculation(
                failedAttempts: widget.failedAttempts,
                starsForFailedAttempts: starsForFailedAttempts,
                difficulty: widget.difficulty,
                starsForDifficulty: starsForDifficulty,
                totalStars: totalStars,
              ),
              Expanded(child: Container()),
              widget.dailyGoalSet != null ? DailyGoalsContainer(dailyGoalSet: widget.dailyGoalSet!) : Container(),
              Expanded(child: Container()),
              _BottomContent(
                onContinue: widget.onContinue,
                type: widget.type,
                nextLevelNumber: widget.nextLevelNumber,
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelRewardCalculation extends StatelessWidget {
  const LevelRewardCalculation({
    super.key,
    required this.failedAttempts,
    required this.starsForFailedAttempts,
    required this.difficulty,
    required this.starsForDifficulty,
    required this.totalStars,
  });

  final int failedAttempts;
  final int starsForFailedAttempts;
  final Difficulty difficulty;
  final int starsForDifficulty;
  final int totalStars;

  @override
  Widget build(BuildContext context) {
    return Column(
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

class _BottomContent extends StatelessWidget {
  const _BottomContent({
    super.key,
    required this.onContinue,
    required this.type,
    required this.nextLevelNumber,
  });

  final Function(LevelCompletedDialogResult) onContinue;
  final LevelCompletedDialogType type;
  final int nextLevelNumber;

  @override
  Widget build(BuildContext context) {
    if (type == LevelCompletedDialogType.classic) {
      return MyPrimaryTextButtonLarge(
        text: "Weiter",
        onPressed: () {
          onContinue(LevelCompletedDialogResult(
            type: LevelCompletedDialogResultType.classic_continue,
            starCountIncrease: 3,
          ));
        },
      );
    } else if (type == LevelCompletedDialogType.daily) {
      return Column(
        children: [
          MySecondaryTextButton(
            text: "Zurück zur Übersicht",
            onPressed: () {
              onContinue(LevelCompletedDialogResult(
                type: LevelCompletedDialogResultType.daily_backToOverview,
                starCountIncrease: 3,
              ));
            },
          ),
          SizedBox(height: 8),
          MyPrimaryTextButton(
            text: "Level $nextLevelNumber",
            onPressed: () {
              onContinue(LevelCompletedDialogResult(
                type: LevelCompletedDialogResultType.daily_continueWithClassic,
                starCountIncrease: 3,
              ));
            },
          ),
        ],
      );
    }
    return Container();
  }
}

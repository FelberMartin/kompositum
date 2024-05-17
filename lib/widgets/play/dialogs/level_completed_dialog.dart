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
import '../../../data/models/daily_goal.dart';
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
        dailyGoalSet: DailyGoalSet(
          date: DateTime.now(),
          goals: [
            FindCompoundsDailyGoal(targetValue: 20)..increaseCurrentValue(amount: 12),
            EarnDiamondsDailyGoal(targetValue: 30)..increaseCurrentValue(amount: 15),
            CompleteAnyLevelsDailyGoal(targetValue: 3)..increaseCurrentValue(amount: 2),
          ],
        ),
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
    required this.dailyGoalSet,
  }) {
    title = titles[Random().nextInt(titles.length)];
  }

  final LevelCompletedDialogType type;
  final int failedAttempts;
  final Difficulty difficulty;
  final int nextLevelNumber;
  final Function(LevelCompletedDialogResult) onContinue;
  late final String title;

  final DailyGoalSet? dailyGoalSet;

  @override
  State<LevelCompletedDialog> createState() => _LevelCompletedDialogState();
}

class _LevelCompletedDialogState extends State<LevelCompletedDialog> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final starsForFailedAttempts = Rewards.getStarCountForFailedAttempts(
      widget.failedAttempts,
    );
    final starsForDifficulty = Rewards.byDifficulty(
      widget.difficulty,
    );

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

class LevelRewardCalculation extends StatefulWidget {
  const LevelRewardCalculation({
    super.key,
    required this.failedAttempts,
    required this.starsForFailedAttempts,
    required this.difficulty,
    required this.starsForDifficulty,
  });

  final int failedAttempts;
  final int starsForFailedAttempts;
  final Difficulty difficulty;
  final int starsForDifficulty;

  @override
  State<LevelRewardCalculation> createState() => _LevelRewardCalculationState();
}

class _LevelRewardCalculationState extends State<LevelRewardCalculation> {

  int _totalStars = 0;
  bool _hideDifficulty = true;
  bool _hideFailedAttempts = true;

  static Duration startDelay = Duration(milliseconds: 0);
  static Duration showDelay = Duration(milliseconds: 400);
  static Duration increaseCounterDelay = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    Future.delayed(startDelay + showDelay, () {
      _showDifficulty();
      Future.delayed(showDelay + increaseCounterDelay, () {
        _showFailedAttempts();
      });
    });
  }

  void _showDifficulty() {
    setState(() {
      _hideDifficulty = false;
      Future.delayed(increaseCounterDelay, () {
        setState(() {
          _totalStars += widget.starsForDifficulty;
        });
      });
    });
  }

  void _showFailedAttempts() {
    setState(() {
      _hideFailedAttempts = false;
      Future.delayed(increaseCounterDelay, () {
        setState(() {
          _totalStars += widget.starsForFailedAttempts;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedFlipCounter(
              value: _totalStars,
              prefix: "+",
              textStyle: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(width: 8.0),
            Icon(
              MyIcons.star,
              size: 32,
              color: MyColorPalette.of(context).star,
            ),
          ],
        ),
        SizedBox(height: 16.0),
        LevelInfo(
          infoName: "Schwierigkeit",
          infoValue: widget.difficulty.toUiString(),
          hidden: _hideDifficulty,
        ),
        SizedBox(height: 4.0),
        LevelInfo(
          infoName: "Fehler",
          infoValue: widget.failedAttempts.toString(),
          hidden: _hideFailedAttempts,
        ),
      ],
    );
  }
}

class LevelInfo extends StatelessWidget {
  const LevelInfo({
    super.key,
    required this.infoName,
    required this.infoValue,
    required this.hidden,
  });

  final String infoName;
  final String infoValue;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: hidden ? 0 : 1,
      duration: Duration(milliseconds: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$infoName: ",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: MyColorPalette.of(context).textSecondary,
            ),
          ),
          Text(
            infoValue,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
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

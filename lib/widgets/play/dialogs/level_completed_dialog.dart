import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:kompositum/config/locator.dart';
import 'package:kompositum/game/difficulty.dart';
import 'package:kompositum/game/modi/chain/chain_game_page_state.dart';
import 'package:kompositum/screens/game_page.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/home/daily_goals_container.dart';

import '../../../config/my_icons.dart';
import '../../../config/my_theme.dart';
import '../../../config/star_costs_rewards.dart';
import '../../../data/models/daily_goal.dart';
import '../../../data/models/daily_goal_set.dart';
import '../../../game/goals/daily_goal_set_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();

  final goalSet = DailyGoalSet(
    date: DateTime.now(),
    goals: [
      FindCompoundsDailyGoal(targetValue: 20)..increaseCurrentValue(amount: 12),
      EarnDiamondsDailyGoal(targetValue: 30)..increaseCurrentValue(amount: 15),
      CompleteAnyLevelsDailyGoal(targetValue: 3)..increaseCurrentValue(amount: 2),
    ],
  );

  runApp(MaterialApp(
      theme: myTheme,
      home: LevelCompletedDialog(
        type: LevelCompletedDialogType.classic,
        failedAttempts: 0,
        difficulty: Difficulty.easy,
        nextLevelNumber: 2,
        onContinue: (result) {},
        dailyGoalSetProgression: DailyGoalSetProgression(goalSet, goalSet),
        isDailyGoalsFeatureLocked: false,
      )));
}


enum LevelCompletedDialogType {
  classic,
  daily,
  secretLevel,
}

enum LevelCompletedDialogResultType {
  classic_continue,
  daily_continueWithClassic,
  daily_backToOverview,
  secretLevel_continue,
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
    required this.dailyGoalSetProgression,
    required this.isDailyGoalsFeatureLocked,
  }) {
    title = titles[Random().nextInt(titles.length)];
  }

  final LevelCompletedDialogType type;
  final int failedAttempts;
  final Difficulty difficulty;
  final int nextLevelNumber;
  final Function(LevelCompletedDialogResult) onContinue;
  late final String title;

  final DailyGoalSetProgression? dailyGoalSetProgression;
  final bool isDailyGoalsFeatureLocked;

  @override
  State<LevelCompletedDialog> createState() => _LevelCompletedDialogState();
}

class _LevelCompletedDialogState extends State<LevelCompletedDialog> {

  late int starsForFailedAttempts = Rewards.getStarCountForFailedAttempts(
    widget.failedAttempts,
  );
  late int starsForDifficulty = Rewards.byDifficulty(
    widget.difficulty,
  );

  bool _rewardAnimationFinished = false;
  bool _dailyGoalsAnimationFinished = false;

  @override
  void initState() {
    super.initState();
  }

  void _onRewardAnimationEnd() {
    if (!mounted) return;
    setState(() { _rewardAnimationFinished = true; });
  }

  void _onDailyGoalsAnimationEnd() {
    if (!mounted) return;
    setState(() { _dailyGoalsAnimationFinished = true; });
  }

  void _launchSecretLevel() {
    final date = widget.dailyGoalSetProgression!.current.date;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(
          state: ChainGamePageState.fromLocator(date))),
    ).then((value) {
      if (widget.type == LevelCompletedDialogType.classic) {
        onContinue(LevelCompletedDialogResultType.classic_continue);
      }
      if (widget.type == LevelCompletedDialogType.daily) {
        onContinue(LevelCompletedDialogResultType.daily_continueWithClassic);
      }
    });
  }

  void onContinue(LevelCompletedDialogResultType resultType) {
    widget.onContinue(LevelCompletedDialogResult(
      type: resultType,
      starCountIncrease: starsForFailedAttempts + starsForDifficulty,
    ));
  }

  @override
  Widget build(BuildContext context) {
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
                onAnimationEnd: _onRewardAnimationEnd,
              ),
              Expanded(child: Container()),
              widget.dailyGoalSetProgression != null ? DailyGoalsContainer(
                progression: widget.dailyGoalSetProgression!,
                onPlaySecretLevel: _launchSecretLevel,
                onAnimationEnd: _onDailyGoalsAnimationEnd,
                isLocked: widget.isDailyGoalsFeatureLocked,
              ) : Container(),
              Expanded(child: Container()),
              _BottomContent(
                onContinue: onContinue,
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
    this.onAnimationEnd,
  });

  final int failedAttempts;
  final int starsForFailedAttempts;
  final Difficulty difficulty;
  final int starsForDifficulty;
  final Function? onAnimationEnd;

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
  static Duration increaseCounterDuration = Duration(milliseconds: 300);

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
        Future.delayed(increaseCounterDuration, () {
          widget.onAnimationEnd?.call();
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
              duration: increaseCounterDuration,
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
          infoValue: widget.difficulty.uiText,
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

  final Function(LevelCompletedDialogResultType) onContinue;
  final LevelCompletedDialogType type;
  final int nextLevelNumber;

  @override
  Widget build(BuildContext context) {
    if (type == LevelCompletedDialogType.classic) {
      return MyPrimaryTextButtonLarge(
        text: "Weiter",
        onPressed: () {
          onContinue(LevelCompletedDialogResultType.classic_continue);
        },
      );
    } else if (type == LevelCompletedDialogType.daily) {
      return Column(
        children: [
          MySecondaryTextButton(
            text: "Zurück zur Übersicht",
            onPressed: () {
              onContinue(LevelCompletedDialogResultType.daily_backToOverview);
            },
          ),
          SizedBox(height: 8),
          MyPrimaryTextButton(
            text: "Level $nextLevelNumber",
            onPressed: () {
              onContinue(LevelCompletedDialogResultType.daily_continueWithClassic);
            },
          ),
        ],
      );
    } else if (type == LevelCompletedDialogType.secretLevel) {
      return MyPrimaryTextButtonLarge(
        text: "Weiter",
        onPressed: () {
          onContinue(LevelCompletedDialogResultType.secretLevel_continue);
        },
      );
    }
    throw Exception("Unknown LevelCompletedDialogType: $type");
  }
}

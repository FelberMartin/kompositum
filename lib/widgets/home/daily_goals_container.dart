import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/data/models/daily_goal_set.dart';
import 'package:kompositum/game/goals/daily_goal_set_manager.dart';
import 'package:kompositum/util/extensions/color_util.dart';
import 'package:kompositum/util/feature_lock_manager.dart';

import '../../data/models/daily_goal.dart';
import '../../util/audio_manager.dart';
import '../common/my_buttons.dart';


void main() async {
  final goalSet = DailyGoalSet(
    date: DateTime.now(),
    goals: [
      FindCompoundsDailyGoal(targetValue: 20)..increaseCurrentValue(amount: 12),
      EarnDiamondsDailyGoal(targetValue: 30)..increaseCurrentValue(amount: 15),
      CompleteAnyLevelsDailyGoal(targetValue: 3)..increaseCurrentValue(amount: 1),
    ],
  );
  // goalSet.isSecretLevelCompleted = true;

  final goalSet2 = goalSet.copy();
  goalSet2.goals[0].increaseCurrentValue(amount: 8);
  goalSet2.goals[1].increaseCurrentValue(amount: 20);
  goalSet2.goals[2].increaseCurrentValue(amount: 2);

  runApp(MaterialApp(
    theme: myTheme,
    home: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: DailyGoalsContainer(
            progression: DailyGoalSetProgression(goalSet, goalSet2),
            onPlaySecretLevel: () {},
            isLocked: true,
          ),
        )
      ],
  ),
  ));
}

class DailyGoalsContainer extends StatefulWidget {
  DailyGoalsContainer({
    super.key,
    required this.progression,
    required this.onPlaySecretLevel,
    required this.isLocked,
    this.animationStartDelay = const Duration(milliseconds: 2000),
    this.onAnimationEnd,
    this.headerColor,
  });

  final DailyGoalSetProgression progression;
  final Function onPlaySecretLevel;
  final Duration animationStartDelay;
  final Function? onAnimationEnd;
  final Color? headerColor;
  final bool isLocked;

  @override
  State<DailyGoalsContainer> createState() => _DailyGoalsContainerState();
}

class _DailyGoalsContainerState extends State<DailyGoalsContainer> with SingleTickerProviderStateMixin {

  late DailyGoalSet dailyGoalSet = widget.progression.previous;

  late AnimationController _controller;
  late Animation<double> _animation;
  late double _currentProgress;

  int _goalIndex = 0;
  late bool _showAllAchieved = dailyGoalSet.isAchieved;

  static Duration goalAnimationDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();

    _currentProgress = dailyGoalSet.progress;
    _controller = AnimationController(vsync: this);

    Future.delayed(widget.animationStartDelay, () {
      _transitionToNextGoalProgression();
    });
  }

  void _transitionToNextGoalProgression() async {
    final goalBefore = dailyGoalSet.goals[_goalIndex];
    final goalAfter = widget.progression.current.goals[_goalIndex];
    final delta = goalAfter.currentValue - goalBefore.currentValue;
    if (delta > 0) {
      final nextGoalSet = dailyGoalSet.copy();
      nextGoalSet.goals[_goalIndex].increaseCurrentValue(amount: delta);
      setState(() {
        dailyGoalSet = nextGoalSet;
        _updateProgressAnimation();
      });
      var delay = goalAnimationDuration;
      if (goalAfter.isAchieved) {
        delay += _DailyGoalCardState.checkmarkAnimationDuration + _DailyGoalCardState.checkmarkDelay;
      }
      await Future.delayed(delay);
    }

    _goalIndex++;
    if (_goalIndex < dailyGoalSet.goals.length) {
      _transitionToNextGoalProgression();
    } else {
      widget.onAnimationEnd?.call();
      if (dailyGoalSet.isAchieved) {
        _allAchievedAnimation();
      }
    }
  }

  void _updateProgressAnimation() {
    _animation = Tween<double>(begin: _currentProgress, end: dailyGoalSet.progress).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    _animation.addListener(() {
      setState(() {
        _currentProgress = _animation.value;
      });
    });
    _controller.duration = goalAnimationDuration;
    _controller.forward(from: 0.0);
  }

  void _allAchievedAnimation() {
    _showAllAchieved = true;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TitleRow(headerColor: widget.headerColor),
        ),
        Material(
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            constraints: BoxConstraints(
              maxWidth: 320,
              minHeight: 80,
            ),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: getContainerGradient(
                progress: _currentProgress,
                allAchieved: _showAllAchieved,
                isLocked: widget.isLocked,
                context: context,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: fillContainer(context),
          ),
        ),
      ],
    );
  }

  Widget fillContainer(BuildContext context) {
    // Locked
    if (widget.isLocked) {
      return _Locked();
    }

    // Secret level completed
    if (dailyGoalSet.isSecretLevelCompleted) {
      return _SecretLevelDone();
    }

    // All goal achieved, Play secret level
    if (_showAllAchieved) {
      return _PlaySecretLevel(onSecretLevelPlay: widget.onPlaySecretLevel);
    }

    // Goal progression
    return Column(
      children: [
        GoalsRow(dailyGoalSet: dailyGoalSet),
        SizedBox(height: 8),
        ProgressRow(progress: _currentProgress),
      ],
    );

  }

  static Gradient getContainerGradient({
    required double progress,
    required bool allAchieved,
    required bool isLocked,
    required BuildContext context,
  }) {
    if (isLocked) {
      // No gradient
      return LinearGradient(colors: [
        MyColorPalette.of(context).secondary,
        MyColorPalette.of(context).secondary,
      ]);
    }

    if (allAchieved) {
      return RadialGradient(
        colors: [
          MyColorPalette.of(context).secondary,
          MyColorPalette.of(context).primary,
        ],
        stops: [0.0, 1.0],
        center: Alignment.bottomCenter * 1.5,
        radius: 1.5,
      );
    }
    var stop1 = 0.0 + progress;
    var stop2 = 0.3 + progress * 0.8;

    return LinearGradient(
      colors: [
        MyColorPalette.of(context).primary,
        MyColorPalette.of(context).secondary,
        // Color.lerp(MyColorPalette.of(context).secondary, MyColorPalette.of(context).primary, progress)!,
      ],
      stops: [stop1, stop2],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}

class _Locked extends StatelessWidget {
  const _Locked({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MyIcons.lock,
            color: MyColorPalette.of(context).textSecondary,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'ab Level ${FeatureLockManager.dailyGoalsFeatureLockLevel}',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: MyColorPalette.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecretLevelDone extends StatelessWidget {
  const _SecretLevelDone({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Verstecktes Level absolviert!',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: MyColorPalette.of(context).onPrimary,
            ),
          ),
          SizedBox(width: 12),
          SvgPicture.asset(
            MyIcons.treasureChestOpenSvg,
            width: 32,
          ),
        ],
      ),
    );
  }
}

class _PlaySecretLevel extends StatelessWidget {
  const _PlaySecretLevel({
    super.key,
    required this.onSecretLevelPlay,
  });

  final Function onSecretLevelPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SvgPicture.asset(
            MyIcons.treasureChestClosedSvg,
            width: 32,
          ),
          SizedBox(width: 12),
          Text(
            'Verstecktes Level',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: MyColorPalette.of(context).onPrimary,
            ),
          ),
          Expanded(child: Container()),
          MySecondaryTextButton(
            onPressed: onSecretLevelPlay,
            text: 'Spielen',
          ),
        ],
      ),
    );
  }
}

class ProgressRow extends StatelessWidget {
  const ProgressRow({
    super.key,
    required this.progress,
  });

  final double progress;

  static const double minProgress = 0.03;

  @override
  Widget build(BuildContext context) {
    final shownProgress = progress.clamp(minProgress, 1.0);
    return Row(
      children: [
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: MyColorPalette.of(context).onPrimary,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: shownProgress,
            valueColor: AlwaysStoppedAnimation(MyColorPalette.of(context).onPrimary),
            backgroundColor: MyColorPalette.of(context).primaryShade,
            borderRadius: BorderRadius.circular(12),
            minHeight: 8,
          ),
        ),
        SizedBox(width: 8),
        SvgPicture.asset(
          MyIcons.treasureChestClosedSvg,
          width: 16,
        ),
      ],
    );
  }
}

class GoalsRow extends StatelessWidget {
  const GoalsRow({
    super.key,
    required this.dailyGoalSet,
  });

  final DailyGoalSet dailyGoalSet;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DailyGoalCard(
                dailyGoal: dailyGoalSet.goals[0],
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: DailyGoalCard(
                dailyGoal: dailyGoalSet.goals[1],
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: DailyGoalCard(
                dailyGoal: dailyGoalSet.goals[2],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleRow extends StatelessWidget {
  const TitleRow({
    super.key,
    this.headerColor,
  });

  final Color? headerColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Tagesziele',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: headerColor ?? MyColorPalette.of(context).onSecondary,
          ),
        ),
      ],
    );
  }
}

class DailyGoalCard extends StatefulWidget {
  const DailyGoalCard({
    super.key,
    required this.dailyGoal,
  });

  final DailyGoal dailyGoal;

  @override
  State<DailyGoalCard> createState() => _DailyGoalCardState();
}

class _DailyGoalCardState extends State<DailyGoalCard> {

  late bool _showCheckmark = widget.dailyGoal.isAchieved;

  static Duration counterAnimationDuration = Duration(milliseconds: 500);
  static Duration checkmarkAnimationDuration = Duration(milliseconds: 300);
  static Duration checkmarkDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DailyGoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.dailyGoal.isAchieved && widget.dailyGoal.isAchieved) {
      Future.delayed(counterAnimationDuration + checkmarkDelay, () {
        if (mounted) {
          setState(() {
            AudioManager.instance.playDailyGoalCompleted();
            _showCheckmark = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.dailyGoal.isAchieved ? MyColorPalette.of(context).background.lighten(0.1) : MyColorPalette.of(context).onPrimary,
      ),
      duration: checkmarkAnimationDuration,
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: checkmarkAnimationDuration,
            transitionBuilder: (child, animation) {
              if (child.runtimeType == AnimatedFlipCounter) {
                return ScaleTransition(
                  scale: Tween<double>(
                    begin: 0,
                    end: 1,
                  ).animate(animation),
                  child: child,
                );
              }
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 1),
                  end: Offset(0, 0),
                ).animate(animation),
                child: child,
              );
            },
            child: _showCheckmark ?
                Icon(
                FontAwesomeIcons.solidCircleCheck,
                color: MyColorPalette.of(context).secondaryShade,
                size: 19,
              ) : AnimatedFlipCounter(
                value: widget.dailyGoal.currentValue,
                suffix: "/${widget.dailyGoal.targetValue}",
                duration: counterAnimationDuration,
                textStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: MyColorPalette.of(context).secondaryShade,
                ),
              ),
          ),
          SizedBox(height: 0),
          Text(
            widget.dailyGoal.uiText,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: MyColorPalette.of(context).secondary,
              decoration: widget.dailyGoal.isAchieved ? TextDecoration.lineThrough : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
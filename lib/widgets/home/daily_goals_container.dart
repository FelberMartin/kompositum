import 'package:flutter/material.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/data/models/daily_goal_set.dart';
import 'package:kompositum/util/color_util.dart';

import '../../data/models/daily_goal.dart';


void main() async {
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
    home: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: DailyGoalsContainer(
            dailyGoalSet: goalSet,
          ),
        )
      ],
  ),
  ));
}

class DailyGoalsContainer extends StatefulWidget {
  DailyGoalsContainer({
    super.key, required this.dailyGoalSet
  });

  final DailyGoalSet dailyGoalSet;

  @override
  State<DailyGoalsContainer> createState() => _DailyGoalsContainerState();
}

class _DailyGoalsContainerState extends State<DailyGoalsContainer> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TitleRow(),
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: 320,
          ),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MyColorPalette.of(context).background.darken(0.00),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              GoalsRow(dailyGoalSet: widget.dailyGoalSet),
              SizedBox(height: 8),
              ProgressRow(progress: widget.dailyGoalSet.progress),
            ],
          ),
        ),
      ],
    );
  }
}

class ProgressRow extends StatelessWidget {
  const ProgressRow({
    super.key,
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: MyColorPalette.of(context).primaryShade,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: MyColorPalette.of(context).onPrimary,
            valueColor: AlwaysStoppedAnimation(MyColorPalette.of(context).primary),
            borderRadius: BorderRadius.circular(12),
            minHeight: 8,
          ),
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
      borderRadius: BorderRadius.circular(12),
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
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Tagesziele',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            // color: MyColorPalette.of(context).primary,
          ),
        ),
      ],
    );
  }
}

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.dailyGoal,
  });

  final DailyGoal dailyGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dailyGoal.isAchieved ? MyColorPalette.of(context).background.lighten(0.15) : MyColorPalette.of(context).onPrimary,
      ),
      child: Column(
        children: [
          Text(
            dailyGoal.isAchieved ? "✔️" : '${dailyGoal.currentValue} / ${dailyGoal.targetValue}',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: MyColorPalette.of(context).secondaryShade,
            ),
          ),
          SizedBox(height: 0),
          Text(
            dailyGoal.uiText,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: MyColorPalette.of(context).secondary,
              decoration: dailyGoal.isAchieved ? TextDecoration.lineThrough : null,
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
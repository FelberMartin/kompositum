import 'package:flutter/material.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/data/models/daily_goal_set.dart';
import 'package:kompositum/util/color_util.dart';

import '../../data/models/daily_goal.dart';


void main() async {
  final goalSet = DailyGoalSet(
    id: 1,
    date: DateTime.now(),
    goals: [
      DailyGoal(
        id: 1,
        UiText: 'Beliebige Level',
        targetValue: 10,
        currentValue: 5,
      ),
      DailyGoal(
        id: 2,
        UiText: 'Hinweise',
        targetValue: 1,
        currentValue: 0,
      ),
      DailyGoal(
        id: 3,
        UiText: 'Keine Fehlversuche',
        targetValue: 1,
        currentValue: 0,
      ),
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: MyColorPalette.of(context).background.darken(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Tagesziele',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: MyColorPalette.of(context).primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DailyGoalCard(
                    dailyGoal: widget.dailyGoalSet.goals[0],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: DailyGoalCard(
                    dailyGoal: widget.dailyGoalSet.goals[1],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: DailyGoalCard(
                    dailyGoal: widget.dailyGoalSet.goals[2],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                (widget.dailyGoalSet.progress * 100).toStringAsFixed(0) + '%',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: MyColorPalette.of(context).primary,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: widget.dailyGoalSet.progress,
                  backgroundColor: MyColorPalette.of(context).onPrimary,
                  valueColor: AlwaysStoppedAnimation(MyColorPalette.of(context).primary),
                  borderRadius: BorderRadius.circular(12),
                  minHeight: 8,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key, required this.dailyGoal
  });

  final DailyGoal dailyGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: MyColorPalette.of(context).onPrimary,
      ),
      height: 82,
      child: Column(
        children: [
          Text(
            '${dailyGoal.currentValue} / ${dailyGoal.targetValue}',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: MyColorPalette.of(context).secondaryShade,
            ),
          ),
          SizedBox(height: 8),
          Text(
            dailyGoal.UiText,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: MyColorPalette.of(context).secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
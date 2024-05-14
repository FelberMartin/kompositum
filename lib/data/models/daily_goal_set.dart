import 'dart:math';

import '../../objectbox.g.dart';
import 'daily_goal.dart';

class DailyGoalSet {

  final DateTime date;
  final List<DailyGoal> goals;

  DailyGoalSet({
    required this.date,
    required this.goals,
  });

  bool get isAchieved => goals.every((goal) => goal.isAchieved);
  double get progress => goals.map((goal) => goal.progress).reduce((a, b) => a + b) / goals.length;

  factory DailyGoalSet.fromJson({
    required Map<String, dynamic> map,
    required int creationSeed,
  }) {
    final date = DateTime.parse(map['date'] as String);
    final created = DailyGoalSet.generate(creationSeed: creationSeed, date: date);
    created.goals[0].increaseCurrentValue(amount: map['goal1CurrentValue'] as int);
    created.goals[1].increaseCurrentValue(amount: map['goal2CurrentValue'] as int);
    created.goals[2].increaseCurrentValue(amount: map['goal3CurrentValue'] as int);
    return created;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'goal1CurrentValue': goals[0].currentValue,
      'goal2CurrentValue': goals[1].currentValue,
      'goal3CurrentValue': goals[2].currentValue,
    };
  }

  factory DailyGoalSet.generate({required int creationSeed, required DateTime date}) {
    final goals = <DailyGoal>[];
    final seed = creationSeed + date.day + date.month + date.year;
    final random = Random(seed);

    final allGoals = [
      FindCompoundsDailyGoal.generate(random: random),
      EarnDiamondsDailyGoal.generate(random: random),
      UseHintsDailyGoal.generate(random: random),
      CompleteDailyLevelDailyGoal.generate(random: random),
      CompleteClassicLevelsDailyGoal.generate(random: random),
      CompleteAnyLevelsDailyGoal.generate(random: random),
      CompleteEasyLevelsDailyGoal.generate(random: random),
      CompleteMediumLevelsDailyGoal.generate(random: random),
      CompleteHardLevelsDailyGoal.generate(random: random),
      FailedAttemptsDailyGoal.generate(random: random),
    ];

    for (var i = 0; i < 3; i++) {
      final goal = allGoals.removeAt(random.nextInt(allGoals.length));
      goals.add(goal);
    }

    return DailyGoalSet(date: date, goals: goals);
  }

}
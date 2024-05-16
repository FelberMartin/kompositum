import 'package:kompositum/data/models/daily_goal.dart';
import 'package:kompositum/data/models/daily_goal_set.dart';
import 'package:kompositum/game/goals/daily_goal_set_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockDailyGoalSetManager extends Mock implements DailyGoalSetManager {

  DailyGoalSet dailyGoalSet = DailyGoalSet(
    date: DateTime.now(),
    goals: [
      FindCompoundsDailyGoal(targetValue: 20)..increaseCurrentValue(amount: 12),
      EarnDiamondsDailyGoal(targetValue: 30)..increaseCurrentValue(amount: 15),
      CompleteAnyLevelsDailyGoal(targetValue: 3)..increaseCurrentValue(amount: 2),
    ],
  );

  @override
  Future<DailyGoalSet> getDailyGoalSet() async {
    return dailyGoalSet!;
  }
}
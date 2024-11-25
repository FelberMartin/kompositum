import 'dart:math';

import 'package:kompositum/game/level_setup.dart';

import '../../game/game_event/game_event.dart';
import '../../util/extensions/random_util.dart';
import 'daily_goal.dart';


/// A set of 3 daily goals that the player can achieve. Is valid for a single day.
class DailyGoalSet {

  final DateTime date;
  final List<DailyGoal> goals;
  bool isSecretLevelCompleted;

  DailyGoalSet({
    required this.date,
    required this.goals,
    this.isSecretLevelCompleted = false,
  });

  bool get isAchieved => goals.every((goal) => goal.isAchieved);
  double get progress => goals.map((goal) => goal.progress).reduce((a, b) => a + b) / goals.length;

  factory DailyGoalSet.fromJson({
    required Map<String, dynamic> map,
    required int creationSeed,
  }) {
    final date = DateTime.parse(map['date'] as String);
    final created = DailyGoalSet.generate(creationSeed: creationSeed, date: date);
    created.isSecretLevelCompleted = map['isSecretLevelCompleted'] as bool;
    created.goals[0].increaseCurrentValue(amount: map['goal1CurrentValue'] as int);
    created.goals[1].increaseCurrentValue(amount: map['goal2CurrentValue'] as int);
    created.goals[2].increaseCurrentValue(amount: map['goal3CurrentValue'] as int);
    return created;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'isSecretLevelCompleted': isSecretLevelCompleted,
      'goal1CurrentValue': goals[0].currentValue,
      'goal2CurrentValue': goals[1].currentValue,
      'goal3CurrentValue': goals[2].currentValue,
    };
  }

  factory DailyGoalSet.generate({required int creationSeed, required DateTime date}) {
    final seed = creationSeed + date.day + date.month + date.year;
    final random = Random(seed);

    final Map<DailyGoal, double> allGoalsWeighted = {
      FindCompoundsDailyGoal.generate(random: random): 2,
      EarnDiamondsDailyGoal.generate(random: random): 2,
      UseHintsDailyGoal.generate(random: random): 0,    // Not used anymore (anti-rewarding for the user)
      CompleteDailyLevelDailyGoal.generate(random: random): 0.5,
      CompleteClassicLevelsDailyGoal.generate(random: random): 0.5,
      CompleteAnyLevelsDailyGoal.generate(random: random): 0.5,
      CompleteEasyLevelsDailyGoal.generate(random: random): 0.5,
      CompleteMediumLevelsDailyGoal.generate(random: random): 0.5,
      CompleteHardLevelsDailyGoal.generate(random: random): 0.5,
      FailedAttemptsDailyGoal.generate(random: random): 1,
    };

    final goals = randomWeightedElementsWithoutReplacement(allGoalsWeighted, 3, random: random);
    return DailyGoalSet(date: date, goals: goals);
  }

  void processGameEvent(GameEvent event) {
    if (event is LevelCompletedGameEvent && event.levelSetup.levelType == LevelType.secretChain) {
      isSecretLevelCompleted = true;
    }
    for (final goal in goals) {
      goal.processGameEvent(event);
    }
  }

  @override
  String toString() {
    return 'DailyGoalSet{date: $date, secretLevel: $isSecretLevelCompleted, goals: $goals}';
  }

  DailyGoalSet copy() {
    return DailyGoalSet(
      date: date,
      goals: goals.map((goal) => goal.copy()).toList(),
      isSecretLevelCompleted: isSecretLevelCompleted,
    );
  }

}
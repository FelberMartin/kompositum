import 'package:kompositum/data/models/daily_goal.dart';
import 'package:kompositum/game/game_event.dart';
import 'package:test/test.dart';

class TestDailyGoal extends DailyGoal {
  TestDailyGoal({required super.uiText, required super.targetValue});

  @override
  void processGameEvent(GameEvent event) {
    // do nothing
  }

}
void main() {
  group("general tests", () {
    test("a new goal has current value zero", () {
      final goal = TestDailyGoal(uiText: 'Test', targetValue: 10);
      expect(goal.currentValue, 0);
    });

    test("a goal is not achieved if its current value is less than the target value", () {
      final goal = TestDailyGoal(uiText: 'Test', targetValue: 10);
      expect(goal.isAchieved, false);
    });

    test("a goal is achieved if its current value is equal to the target value", () {
      final goal = TestDailyGoal(uiText: 'Test', targetValue: 10);
      goal.increaseCurrentValue(amount: 10);
      expect(goal.isAchieved, true);
    });

    test("a goal is achieved if its current value is greater than the target value", () {
      final goal = TestDailyGoal(uiText: 'Test', targetValue: 10);
      goal.increaseCurrentValue(amount: 11);
      expect(goal.isAchieved, true);
    });

    test("increasing the current value does not exceed the target value", () {
      final goal = TestDailyGoal(uiText: 'Test', targetValue: 10);
      goal.increaseCurrentValue(amount: 20);
      expect(goal.currentValue, 10);
    });

    test("progress is zero if the current value is zero", () {
      final goal = TestDailyGoal(uiText: 'Test', targetValue: 10);
      expect(goal.progress, 0);
    });

    test("progess does not exceed 1", () {
      final goal = TestDailyGoal(uiText: 'Test', targetValue: 10);
      goal.increaseCurrentValue(amount: 20);
      expect(goal.progress, 1);
    });
  });


}
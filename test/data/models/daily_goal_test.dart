import 'package:kompositum/data/models/daily_goal.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/attempts_watcher.dart';
import 'package:kompositum/game/game_event/game_event.dart';
import 'package:kompositum/game/hints/hint.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../../config/test_locator.dart';
import '../../mocks/mock_level_setup.dart';
import '../../mocks/mock_pool_game_level.dart';
import '../../test_data/compounds.dart';

class TestDailyGoal extends DailyGoal {
  TestDailyGoal({required super.uiText, required super.targetValue});

  @override
  void processGameEvent(GameEvent event) {
    // do nothing
  }

  @override
  DailyGoal copy() {
    throw UnimplementedError();
  }
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    setupTestLocator();
  });

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

  test("FindCompoundsDailyGoal", () {
    final goal = FindCompoundsDailyGoal(targetValue: 1);
    goal.processGameEvent(CompoundFoundGameEvent(Compounds.Krankenhaus));
    expect(goal.currentValue, 1);
  });

  test("EarnDiamondsDailyGoal", () {
    final goal = EarnDiamondsDailyGoal(targetValue: 1);
    goal.processGameEvent(StarIncreaseRequestGameEvent(1, StarIncreaseRequestOrigin.compoundCompletion));
    expect(goal.currentValue, 1);
  });

  test("UseHintsDailyGoal", () {
    final goal = UseHintsDailyGoal(targetValue: 1);
    final hint = Hint(UniqueComponent("test"), HintComponentType.head);
    goal.processGameEvent(HintBoughtGameEvent(hint));
    expect(goal.currentValue, 1);
  });

  test("CompleteDailyLevelDailyGoal", () {
    final goal = CompleteDailyLevelDailyGoal();
    final levelSetup = DailyLevelProvider().generateLevelSetup(DateTime.now());
    final poolGameLevel = MockPoolGameLevel();
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 1);
  });

  test("CompleteDailyLevelDailyGoal: dont increase if a classic level is completed", () {
    final goal = CompleteDailyLevelDailyGoal();
    final levelSetup = locator<LevelProvider>().generateLevelSetup(1);
    final poolGameLevel = MockPoolGameLevel();
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 0);
  });

  test("CompleteClassicLevelsDailyGoal", () {
    final goal = CompleteClassicLevelsDailyGoal(targetValue: 1);
    final levelSetup = locator<LevelProvider>().generateLevelSetup(1);
    final poolGameLevel = MockPoolGameLevel();
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 1);
  });

  test("CompleteClassicLevelsDailyGoal: dont increase if a daily level is completed", () {
    final goal = CompleteClassicLevelsDailyGoal(targetValue: 1);
    final levelSetup = DailyLevelProvider().generateLevelSetup(DateTime.now());
    final poolGameLevel = MockPoolGameLevel();
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 0);
  });

  test("CompleteAnyLevelsDailyGoal", () {
    final goal = CompleteAnyLevelsDailyGoal(targetValue: 2);
    var levelSetup = locator<LevelProvider>().generateLevelSetup(1);
    final poolGameLevel = MockPoolGameLevel();
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 1);

    levelSetup = DailyLevelProvider().generateLevelSetup(DateTime.now());
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 2);
  });

  test("CompleteEasyLevelsDailyGoal", () {
    final goal = CompleteEasyLevelsDailyGoal(targetValue: 3);
    var levelSetup = MockLevelSetup();
    when(() => levelSetup.displayedDifficulty).thenReturn(Difficulty.easy);
    final poolGameLevel = MockPoolGameLevel();
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 1);

    // test that it does not increase for other difficulties
    when(() => levelSetup.displayedDifficulty).thenReturn(Difficulty.medium);
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 1);

    when(() => levelSetup.displayedDifficulty).thenReturn(Difficulty.hard);
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 1);
  });

  test("CompleteMediumLevelsDailyGoal", () {
    final goal = CompleteMediumLevelsDailyGoal(targetValue: 1);
    var levelSetup = MockLevelSetup();
    when(() => levelSetup.displayedDifficulty).thenReturn(Difficulty.medium);
    final poolGameLevel = MockPoolGameLevel();
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 1);
  });

  test("CompleteHardLevelsDailyGoal", () {
    final goal = CompleteHardLevelsDailyGoal(targetValue: 1);
    var levelSetup = MockLevelSetup();
    when(() => levelSetup.displayedDifficulty).thenReturn(Difficulty.hard);
    final poolGameLevel = MockPoolGameLevel();
    goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
    expect(goal.currentValue, 1);
  });

  group("FailedAttemptsDailyGoal", () {
    test("Increases value if under maxFailedAttempts", () {
      final goal = FailedAttemptsDailyGoal(maxFailedAttempts: 3);
      final levelSetup = MockLevelSetup();
      final poolGameLevel = MockPoolGameLevel();
      final attemptsWatcher = AttemptsWatcher();
      attemptsWatcher.attemptUsed("a", "b");
      attemptsWatcher.attemptUsed("b", "c");
      when(() => poolGameLevel.attemptsWatcher).thenReturn(attemptsWatcher);

      goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
      expect(goal.currentValue, 1);
    });

    test("Does not increase if more attempts were used", () {
      final goal = FailedAttemptsDailyGoal(maxFailedAttempts: 1);
      final levelSetup = MockLevelSetup();
      final poolGameLevel = MockPoolGameLevel();
      final attemptsWatcher = AttemptsWatcher();
      attemptsWatcher.attemptUsed("a", "b");
      attemptsWatcher.attemptUsed("b", "c");
      when(() => poolGameLevel.attemptsWatcher).thenReturn(attemptsWatcher);

      goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
      expect(goal.currentValue, 0);
    });

    test("Does increase if exactly the maxAttempts were used", () {
      final goal = FailedAttemptsDailyGoal(maxFailedAttempts: 1);
      final levelSetup = MockLevelSetup();
      final poolGameLevel = MockPoolGameLevel();
      final attemptsWatcher = AttemptsWatcher();
      attemptsWatcher.attemptUsed("a", "b");
      when(() => poolGameLevel.attemptsWatcher).thenReturn(attemptsWatcher);

      goal.processGameEvent(LevelCompletedGameEvent(levelSetup, poolGameLevel));
      expect(goal.currentValue, 1);
    });
  });
}
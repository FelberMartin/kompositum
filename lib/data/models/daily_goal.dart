import 'dart:math';

import 'package:kompositum/objectbox.g.dart';

import '../../game/game_event/game_event.dart';
import '../../game/level_provider.dart';


// This can not be an entity for objectbox, because it does currently not support
// abstract classes.
abstract class DailyGoal {

  final String uiText;
  final int targetValue;
  int _currentValue = 0;

  int get currentValue => _currentValue;

  DailyGoal({
    required this.uiText,
    required this.targetValue,
  });

  bool get isAchieved => currentValue >= targetValue;
  double get progress => currentValue / targetValue;

  void increaseCurrentValue({int amount = 1}) {
    _currentValue += amount;
    if (_currentValue > targetValue) {
      _currentValue = targetValue;
    }
  }

  void processGameEvent(GameEvent event);

  @override
  String toString() {
    return 'DailyGoal{uiText: $uiText, targetValue: $targetValue, currentValue: $_currentValue}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyGoal &&
          runtimeType == other.runtimeType &&
          uiText == other.uiText &&
          targetValue == other.targetValue &&
          _currentValue == other._currentValue;

  @override
  int get hashCode =>
      uiText.hashCode ^
      targetValue.hashCode ^
      _currentValue.hashCode;

}

class FindCompoundsDailyGoal extends DailyGoal {
  FindCompoundsDailyGoal({required super.targetValue})
      : super(uiText: "Wörter gefunden");

  factory FindCompoundsDailyGoal.generate({required Random random}) {
    final value = random.nextInt(7) * 5 + 15;
    return FindCompoundsDailyGoal(targetValue: value);
  }

  @override
  void processGameEvent(GameEvent event) {
    if (event is CompoundFoundGameEvent) {
      increaseCurrentValue();
    }
  }
}

class EarnDiamondsDailyGoal extends DailyGoal {
  EarnDiamondsDailyGoal({required super.targetValue})
      : super(uiText: "Diamanten gesammelt");

  factory EarnDiamondsDailyGoal.generate({required Random random}) {
    final value = random.nextInt(5) * 10 + 40;
    return EarnDiamondsDailyGoal(targetValue: value);
  }

  @override
  void processGameEvent(GameEvent event) {
    if (event is StarIncreaseRequestGameEvent) {
      increaseCurrentValue(amount: event.amount);
    }
  }
}

class UseHintsDailyGoal extends DailyGoal {
  UseHintsDailyGoal({required super.targetValue})
      : super(uiText: "Hinweise");

  factory UseHintsDailyGoal.generate({required Random random}) {
    final value = random.nextInt(1) + 1;
    return UseHintsDailyGoal(targetValue: value);
  }

  @override
  void processGameEvent(GameEvent event) {
    if (event is HintBoughtGameEvent) {
      increaseCurrentValue();
    }
  }
}

abstract class LevelCompletionDailyGoal extends DailyGoal {
  final List<LevelType> acceptedLevelTypes;

  LevelCompletionDailyGoal({
      required super.uiText,
      required super.targetValue,
      required this.acceptedLevelTypes});

  @override
  void processGameEvent(GameEvent event) {
    if (event is LevelCompletedGameEvent && acceptedLevelTypes.contains(event.levelSetup.levelType)) {
      increaseCurrentValue();
    }
  }
}

class CompleteDailyLevelDailyGoal extends LevelCompletionDailyGoal {
  CompleteDailyLevelDailyGoal()
      : super(uiText: "Tägliches Rätsel", targetValue: 1, acceptedLevelTypes: [LevelType.daily]);

  // Pointless factory method, but here for consistency
  factory CompleteDailyLevelDailyGoal.generate({required Random random}) {
    return CompleteDailyLevelDailyGoal();
  }
}

class CompleteClassicLevelsDailyGoal extends LevelCompletionDailyGoal {
  CompleteClassicLevelsDailyGoal(
      {required super.targetValue})
      : super(uiText: "Klassische Level", acceptedLevelTypes: [LevelType.classic]);

  factory CompleteClassicLevelsDailyGoal.generate({required Random random}) {
    final value = random.nextInt(8) + 3;
    return CompleteClassicLevelsDailyGoal(targetValue: value);
  }
}

class CompleteAnyLevelsDailyGoal extends LevelCompletionDailyGoal {
  CompleteAnyLevelsDailyGoal({required super.targetValue})
      : super(uiText: "Beliebige Level", acceptedLevelTypes: [LevelType.classic, LevelType.daily]);

  factory CompleteAnyLevelsDailyGoal.generate({required Random random}) {
    final value = random.nextInt(10) + 3;
    return CompleteAnyLevelsDailyGoal(targetValue: value);
  }
}

abstract class CompleteDifficultyDailyGoal extends DailyGoal {
  final Difficulty difficulty;

  CompleteDifficultyDailyGoal({
      required super.uiText,
      required super.targetValue,
      required this.difficulty});

  @override
  void processGameEvent(GameEvent event) {
    if (event is LevelCompletedGameEvent &&
        event.levelSetup.displayedDifficulty == difficulty) {
      increaseCurrentValue();
    }
  }
}

class CompleteEasyLevelsDailyGoal extends CompleteDifficultyDailyGoal {
  CompleteEasyLevelsDailyGoal({required super.targetValue})
      : super(uiText: "Leichte Level", difficulty: Difficulty.easy);

  factory CompleteEasyLevelsDailyGoal.generate({required Random random}) {
    final value = random.nextInt(3) + 1;
    return CompleteEasyLevelsDailyGoal(targetValue: value);
  }
}

class CompleteMediumLevelsDailyGoal extends CompleteDifficultyDailyGoal {
  CompleteMediumLevelsDailyGoal({required super.targetValue})
      : super(uiText: "Mittel Level", difficulty: Difficulty.medium);

  factory CompleteMediumLevelsDailyGoal.generate({required Random random}) {
    final value = random.nextInt(3) + 1;
    return CompleteMediumLevelsDailyGoal(targetValue: value);
  }
}

class CompleteHardLevelsDailyGoal extends CompleteDifficultyDailyGoal {
  CompleteHardLevelsDailyGoal({required super.targetValue})
      : super(uiText: "Schwere Level", difficulty: Difficulty.hard);

  factory CompleteHardLevelsDailyGoal.generate({required Random random}) {
    final value = random.nextInt(3) + 1;
    return CompleteHardLevelsDailyGoal(targetValue: value);
  }
}

class FailedAttemptsDailyGoal extends DailyGoal {
  final int maxFailedAttempts;
  FailedAttemptsDailyGoal({required this.maxFailedAttempts})
      : super(uiText: "Max $maxFailedAttempts Fehlversuche", targetValue: 1);

  factory FailedAttemptsDailyGoal.generate({required Random random}) {
    final value = random.nextInt(5) + 1;
    return FailedAttemptsDailyGoal(maxFailedAttempts: value);
  }

  @override
  void processGameEvent(GameEvent event) {
    if (event is LevelCompletedGameEvent &&
        event.poolGameLevel.attemptsWatcher.overAllAttemptsFailed <= maxFailedAttempts) {
      increaseCurrentValue();
    }
  }
}

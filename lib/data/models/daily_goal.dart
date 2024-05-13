import 'package:kompositum/objectbox.g.dart';

import '../../game/game_event.dart';
import '../../game/level_provider.dart';

@Entity()
abstract class DailyGoal {
  @Id()
  int id;

  final String uiText;
  final int targetValue;
  int _currentValue = 0;

  int get currentValue => _currentValue;

  DailyGoal({
    required this.id,
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
}

class FindCompoundsDailyGoal extends DailyGoal {
  FindCompoundsDailyGoal({required super.id, required super.targetValue})
      : super(uiText: "Wörter gefunden");

  @override
  void processGameEvent(GameEvent event) {
    if (event is CompoundFoundGameEvent) {
      increaseCurrentValue();
    }
  }
}

class EarnDiamondsDailyGoal extends DailyGoal {
  EarnDiamondsDailyGoal({required super.id, required super.targetValue})
      : super(uiText: "Diamanten gesammelt");

  @override
  void processGameEvent(GameEvent event) {
    if (event is StarIncreaseRequestGameEvent) {
      increaseCurrentValue(amount: event.amount);
    }
  }
}

class UseHintsDailyGoal extends DailyGoal {
  UseHintsDailyGoal({required super.id, required super.targetValue})
      : super(uiText: "Hinweise");

  @override
  void processGameEvent(GameEvent event) {
    if (event is HintBoughtGameEvent) {
      increaseCurrentValue();
    }
  }
}

abstract class LevelCompletionDailyGoal extends DailyGoal {
  final List<LevelType> acceptedLevelTypes;

  LevelCompletionDailyGoal(
      {required super.id,
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
  CompleteDailyLevelDailyGoal(
      {required super.id, required super.targetValue})
      : super(uiText: "Tägliches Rätsel", acceptedLevelTypes: [LevelType.daily]);
}

class CompleteClassicLevelsDailyGoal extends LevelCompletionDailyGoal {
  CompleteClassicLevelsDailyGoal(
      {required super.id, required super.targetValue})
      : super(uiText: "Klassische Level", acceptedLevelTypes: [LevelType.classic]);
}

class CompleteAnyLevelsDailyGoal extends LevelCompletionDailyGoal {
  CompleteAnyLevelsDailyGoal({required super.id, required super.targetValue})
      : super(uiText: "Beliebige Level", acceptedLevelTypes: [LevelType.classic, LevelType.daily]);
}

abstract class CompleteDifficultyDailyGoal extends DailyGoal {
  final Difficulty difficulty;

  CompleteDifficultyDailyGoal(
      {required super.id,
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
  CompleteEasyLevelsDailyGoal({required super.id, required super.targetValue})
      : super(uiText: "Leichte Level", difficulty: Difficulty.easy);
}

class CompleteMediumLevelsDailyGoal extends CompleteDifficultyDailyGoal {
  CompleteMediumLevelsDailyGoal({required super.id, required super.targetValue})
      : super(uiText: "Mittel Level", difficulty: Difficulty.medium);
}

class CompleteHardLevelsDailyGoal extends CompleteDifficultyDailyGoal {
  CompleteHardLevelsDailyGoal({required super.id, required super.targetValue})
      : super(uiText: "Schwere Level", difficulty: Difficulty.hard);
}

class FailedAttemptsDailyGoal extends DailyGoal {
  final int maxFailedAttempts;
  FailedAttemptsDailyGoal({required super.id, required super.targetValue, required this.maxFailedAttempts})
      : super(uiText: "Max $maxFailedAttempts Fehlversuche");

  @override
  void processGameEvent(GameEvent event) {
    if (event is LevelCompletedGameEvent &&
        event.poolGameLevel.attemptsWatcher.overAllAttemptsFailed <= maxFailedAttempts) {
      increaseCurrentValue();
    }
  }
}

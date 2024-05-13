import 'dart:math';

import '../data/models/compact_frequency_class.dart';

enum LevelType {
  classic,
  daily,
}

class LevelSetup {
  final Object levelIdentifier;
  final LevelType levelType;
  final int compoundCount;
  final int poolGenerationSeed;
  final int maxShownComponentCount;
  final CompactFrequencyClass frequencyClass;
  final Difficulty displayedDifficulty;
  final bool ignoreBlockedCompounds;

  LevelSetup({
    required this.levelIdentifier,
    required this.compoundCount,
    required this.poolGenerationSeed,
    this.levelType = LevelType.classic,
    this.frequencyClass = CompactFrequencyClass.easy,
    this.maxShownComponentCount = 11,
    this.displayedDifficulty = Difficulty.easy,
    this.ignoreBlockedCompounds = false,
  });

  @override
  String toString() {
    return "LevelSetup("
        "levelIdentifier: $levelIdentifier, "
        "levelType: $levelType,"
        "compoundCount: $compoundCount, "
        "poolGenerationSeed: $poolGenerationSeed, "
        "maxShownComponentCount: $maxShownComponentCount, "
        "frequencyClass: $frequencyClass, "
        "displayedDifficulty: $displayedDifficulty)"
        "ignoreBlockedCompounds: $ignoreBlockedCompounds";
  }
}

abstract class LevelProvider {

  LevelSetup generateLevelSetup(Object levelIdentifier);

  int getSeedForLevel(int level) {
    return level + 8;
  }

  static CompactFrequencyClass _getCompactFrequencyClass(Difficulty difficulty) {
    if (difficulty == Difficulty.easy) {
      return CompactFrequencyClass.easy;
    } else if (difficulty == Difficulty.medium) {
      return CompactFrequencyClass.medium;
    } else {
      return CompactFrequencyClass.hard;
    }
  }

  static Difficulty _getRandomDifficulty(double weightEasy, double weightMedium, double weightHard, {int? seed}) {
    final random = seed == null ? Random() : Random(seed);
    final sum = weightEasy + weightMedium + weightHard;
    final randomValue = random.nextDouble() * sum;
    if (randomValue < weightEasy) {
      return Difficulty.easy;
    } else if (randomValue < weightEasy + weightMedium) {
      return Difficulty.medium;
    } else {
      return Difficulty.hard;
    }
  }

  static _getMaxShownComponentsCount(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 9;
      case Difficulty.medium:
        return 10;
      case Difficulty.hard:
        return 11;
    }
  }
}

class BasicLevelProvider extends LevelProvider {
  @override
  LevelSetup generateLevelSetup(Object levelIdentifier) {
    assert(levelIdentifier is int);
    final levelNumber = levelIdentifier as int;
    return LevelSetup(
      levelIdentifier: levelNumber,
      compoundCount: 2 + levelNumber~/2,
      poolGenerationSeed: getSeedForLevel(levelNumber),
    );
  }
}

enum Difficulty {
  easy,
  medium,
  hard;

  String toUiString() {
    switch (this) {
      case Difficulty.easy:
        return "Einfach";
      case Difficulty.medium:
        return "Mittel";
      case Difficulty.hard:
        return "Schwer";
    }
  }
}

/// This LevelProvider should produce levels that globally increase in
/// difficulty, in a logarithmic way.
class LogarithmicLevelProvider extends LevelProvider {

  LevelSetup _generateForFirstLevels(int levelNumber) {
    return LevelSetup(
        levelIdentifier: levelNumber,
        compoundCount: _baseLevel(levelNumber).floor(),
        poolGenerationSeed: getSeedForLevel(levelNumber),
    );
  }

  @override
  LevelSetup generateLevelSetup(Object levelIdentifier) {
    assert(levelIdentifier is int);
    final levelNumber = levelIdentifier as int;

    if (levelNumber < 5) {
      return _generateForFirstLevels(levelNumber);
    }

    final seed = getSeedForLevel(levelNumber);
    final baseLevel = _baseLevel(levelNumber);
    final difficulty = _getDifficulty(levelNumber, seed: seed);
    final compoundCount = _getCompoundCount(baseLevel, levelNumber, difficulty, seed: seed);

    return LevelSetup(
      levelIdentifier: levelNumber,
      compoundCount: compoundCount,
      poolGenerationSeed: seed,
      displayedDifficulty: difficulty,
      frequencyClass: LevelProvider._getCompactFrequencyClass(difficulty),
      maxShownComponentCount: LevelProvider._getMaxShownComponentsCount(difficulty),
    );
  }

  double _baseLevel(int x) {
    return 3 * log(x/4 + 1) + 1;
  }

  Difficulty _getDifficulty(int x, {int? seed}) {
    final weightEasy = 10.0;
    final weightMedium = 2 * log(0.3 * x * x);
    final weightHard = min(0.2 * x, 25.0);
    return LevelProvider._getRandomDifficulty(weightEasy, weightMedium, weightHard, seed: seed);
  }

  int _getCompoundCount(double baseLevel, int levelNumber, Difficulty difficulty, {int? seed}) {
    final random = seed == null ? Random() : Random(seed);
    var compoundCount = baseLevel.floor();
    final maxReduction = compoundCount ~/ 2;
    if (maxReduction > 0) {
      compoundCount -= random.nextInt(maxReduction);
    }
    return compoundCount;
  }

}

class DailyLevelProvider extends LevelProvider {
  @override
  LevelSetup generateLevelSetup(Object levelIdentifier) {
    assert(levelIdentifier is DateTime);
    final date = levelIdentifier as DateTime;
    final seed = date.day + date.month * 100 + date.year * 10000;

    final difficulty = LevelProvider._getRandomDifficulty(1, 1, 1, seed: seed);
    final compoundCount = Random(seed).nextInt(11) + 4;

    return LevelSetup(
      levelIdentifier: date,
      levelType: LevelType.daily,
      compoundCount: compoundCount,
      poolGenerationSeed: seed,
      displayedDifficulty: difficulty,
      frequencyClass: LevelProvider._getCompactFrequencyClass(difficulty),
      maxShownComponentCount: LevelProvider._getMaxShownComponentsCount(difficulty),
      ignoreBlockedCompounds: true,
    );
  }
}

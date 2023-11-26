import 'dart:math';

import 'package:kompositum/data/compound.dart';

import 'compact_frequency_class.dart';
import 'pool_generator/compound_pool_generator.dart';

class LevelSetup {
  final int compoundCount;
  final int poolGenerationSeed;
  final int maxShownComponentCount;
  final CompactFrequencyClass frequencyClass;
  final Difficulty displayedDifficulty;

  LevelSetup({
    required this.compoundCount,
    required this.poolGenerationSeed,
    this.frequencyClass = CompactFrequencyClass.easy,
    this.maxShownComponentCount = 11,
    this.displayedDifficulty = Difficulty.easy,
  });
}

abstract class LevelProvider {

  LevelSetup generateLevelSetup(int levelNumber);

  int getSeedForLevel(int level) {
    return level + 8;
  }
}

class BasicLevelProvider extends LevelProvider {
  @override
  LevelSetup generateLevelSetup(int levelNumber) {
    return LevelSetup(
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
        compoundCount: _baseLevel(levelNumber).floor(),
        poolGenerationSeed: getSeedForLevel(levelNumber),
    );
  }

  @override
  LevelSetup generateLevelSetup(int levelNumber) {
    if (levelNumber < 10) {
      return _generateForFirstLevels(levelNumber);
    }


    final seed = getSeedForLevel(levelNumber);
    final baseLevel = _baseLevel(levelNumber);
    final difficulty = _getDifficulty(levelNumber, seed: seed);
    final compoundCount = _getCompoundCount(baseLevel, levelNumber, difficulty, seed: seed);
    final compactFrequencyClass = _getCompactFrequencyClass(difficulty);
    final maxShownComponentCount = 9 + difficulty.index * 1;

    return LevelSetup(
      compoundCount: compoundCount,
      poolGenerationSeed: seed,
      frequencyClass: compactFrequencyClass,
      maxShownComponentCount: maxShownComponentCount,
      displayedDifficulty: difficulty,
    );
  }

  double _baseLevel(int x) {
    return 3 * log(x/4 + 1) + 1;
  }

  Difficulty _getDifficulty(int x, {int? seed}) {
    final weightEasy = 10.0;
    final weightMedium = 1.9 * log(6 * x);
    final weightHard = min(0.1 * x, 25.0);
    return _getRandomDifficulty(weightEasy, weightMedium, weightHard, seed: seed);
  }

  Difficulty _getRandomDifficulty(double weightEasy, double weightMedium, double weightHard, {int? seed}) {
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

  int _getCompoundCount(double baseLevel, int levelNumber, Difficulty difficulty, {int? seed}) {
    final random = seed == null ? Random() : Random(seed);
    var compoundCount = baseLevel.floor();
    if (difficulty == Difficulty.easy && compoundCount >= 4) {
      compoundCount -= random.nextInt(compoundCount ~/ 4);
    } else if (difficulty == Difficulty.medium && compoundCount >= 6) {
      compoundCount -= random.nextInt(compoundCount ~/ 6);
    }
    return compoundCount;
  }

  CompactFrequencyClass _getCompactFrequencyClass(Difficulty difficulty) {
    if (difficulty == Difficulty.easy) {
      return CompactFrequencyClass.easy;
    } else if (difficulty == Difficulty.medium) {
      return CompactFrequencyClass.medium;
    } else {
      return CompactFrequencyClass.hard;
    }
  }

}

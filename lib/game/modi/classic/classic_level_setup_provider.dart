import 'dart:math';

import 'package:kompositum/game/difficulty.dart';
import 'package:kompositum/game/level_setup_provider.dart';
import 'package:kompositum/game/level_setup.dart';


abstract class ClassicLevelSetupProvider extends LevelSetupProvider {}


/// This LevelProvider should produce levels that globally increase in
/// difficulty, in a logarithmic way.
class LogarithmicLevelSetupProvider extends ClassicLevelSetupProvider {

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
      difficulty: difficulty,
    );
  }

  double _baseLevel(int x) {
    return 3 * log(x/4 + 1) + 1;
  }

  Difficulty _getDifficulty(int x, {int? seed}) {
    final weightEasy = 10.0;
    final weightMedium = 2 * log(0.1 * x * x);
    final weightHard = min(0.15 * x, weightMedium + 5);
    return LevelSetupProvider.getRandomDifficulty(weightEasy, weightMedium, weightHard, seed: seed);
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

class DailyLevelSetupProvider extends ClassicLevelSetupProvider {
  @override
  LevelSetup generateLevelSetup(Object levelIdentifier) {
    assert(levelIdentifier is DateTime);
    final date = levelIdentifier as DateTime;
    final seed = date.day + date.month * 100 + date.year * 10000;

    final difficulty = LevelSetupProvider.getRandomDifficulty(1, 1, 1, seed: seed);
    final compoundCount = Random(seed).nextInt(11) + 4;

    return LevelSetup(
      levelIdentifier: date,
      levelType: LevelType.dailyClassic,
      compoundCount: compoundCount,
      poolGenerationSeed: seed,
      difficulty: difficulty,
      ignoreBlockedCompounds: true,
    );
  }
}
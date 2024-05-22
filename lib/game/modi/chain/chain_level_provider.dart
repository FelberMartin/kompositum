import 'dart:math';

import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/level_setup.dart';

class ChainLevelProvider extends LevelProvider {
  @override
  LevelSetup generateLevelSetup(Object levelIdentifier) {
    assert(levelIdentifier is DateTime);
    final date = levelIdentifier as DateTime;
    final seed = date.day + date.month * 100 + date.year * 10000;

    final difficulty = LevelProvider.getRandomDifficulty(1, 1, 1, seed: seed);
    final compoundCount = Random(seed).nextInt(11) + 7;

    return LevelSetup(
      levelIdentifier: date,
      levelType: LevelType.daily,
      compoundCount: compoundCount,
      poolGenerationSeed: seed,
      difficulty: difficulty,
      ignoreBlockedCompounds: true,
    );
  }
}
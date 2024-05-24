import 'dart:math';

import 'package:kompositum/game/level_setup_provider.dart';
import 'package:kompositum/game/level_setup.dart';

class ChainLevelSetupProvider extends LevelSetupProvider {
  @override
  LevelSetup generateLevelSetup(Object levelIdentifier) {
    assert(levelIdentifier is DateTime);
    final date = levelIdentifier as DateTime;
    final seed = date.day + date.month * 100 + date.year * 10000;

    // Chains for easy difficulty are very rare / hard to find, therefore use
    // use only medium and hard frequency classes
    final difficulty = LevelSetupProvider.getRandomDifficulty(0, 1, 1, seed: seed);
    final compoundCount = Random(seed).nextInt(11) + 7;

    return LevelSetup(
      levelIdentifier: date,
      levelType: LevelType.secretChain,
      compoundCount: compoundCount,
      poolGenerationSeed: seed,
      difficulty: difficulty,
      ignoreBlockedCompounds: true,
    );
  }
}
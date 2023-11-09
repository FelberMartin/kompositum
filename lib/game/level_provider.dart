import 'package:kompositum/data/compound.dart';

import 'compact_frequency_class.dart';
import 'pool_generator/compound_pool_generator.dart';

class LevelSetup {
  final int compoundCount;
  final int poolGenerationSeed;
  final int maxShownComponentCount;
  final CompactFrequencyClass frequencyClass;

  LevelSetup({
    required this.compoundCount,
    required this.poolGenerationSeed,
    this.frequencyClass = CompactFrequencyClass.easy,
    this.maxShownComponentCount = 11,
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

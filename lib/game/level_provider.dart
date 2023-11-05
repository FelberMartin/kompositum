import 'package:kompositum/data/compound.dart';

import 'compact_frequency_class.dart';
import 'pool_generator/compound_pool_generator.dart';

abstract class LevelProvider {
  final CompoundPoolGenerator _compoundPoolGenerator;

  LevelProvider(this._compoundPoolGenerator);

  Future<List<Compound>> generateCompoundPool(int levelNumber) {
    final frequencyClass = getFrequencyClassByLevel(levelNumber);
    final compoundCount = getCompoundCountByLevel(levelNumber);
    return _compoundPoolGenerator.generate(
      frequencyClass: frequencyClass,
      compoundCount: compoundCount,
      seed: getSeedForLevel(levelNumber),
    );
  }

  int getCompoundCountByLevel(int level);

  CompactFrequencyClass getFrequencyClassByLevel(int level);

  int getSeedForLevel(int level) {
    return level + 8;
  }
}

class BasicLevelProvider extends LevelProvider {
  BasicLevelProvider(CompoundPoolGenerator compoundPoolGenerator)
      : super(compoundPoolGenerator);

  @override
  int getCompoundCountByLevel(int level) {
    return 2 + level ~/ 2;
  }

  @override
  CompactFrequencyClass getFrequencyClassByLevel(int level) {
    return CompactFrequencyClass.easy;
  }
}

import 'package:kompositum/compound_pool_generator.dart';
import 'package:kompositum/data/compound.dart';

abstract class LevelProvider {
  final CompoundPoolGenerator _compoundPoolGenerator;

  LevelProvider(this._compoundPoolGenerator);

  Future<List<Compound>> generateCompoundPool(int levelNumber) {
    final frequencyClass = getFrequencyClassByLevel(levelNumber);
    final compoundCount = getCompoundCountByLevel(levelNumber);
    return _compoundPoolGenerator.generate(
      frequencyClass: frequencyClass,
      compoundCount: compoundCount,
    );
  }

  int getCompoundCountByLevel(int level);

  CompactFrequencyClass getFrequencyClassByLevel(int level);
}

class BasicLevelProvider extends LevelProvider {
  BasicLevelProvider(super.compoundPoolGenerator);

  @override
  int getCompoundCountByLevel(int level) {
    return 5;
  }

  @override
  CompactFrequencyClass getFrequencyClassByLevel(int level) {
    return CompactFrequencyClass.easy;
  }
}



import 'package:kompositum/compound_pool_generator.dart';
import 'package:kompositum/data/compound.dart';

abstract class LevelProvider {

  late int _levelNumber;
  final CompoundPoolGenerator _compoundPoolGenerator;

  LevelProvider(this._compoundPoolGenerator, {required startingLevelNumber}) {
    _levelNumber = startingLevelNumber;
  }

  int getLevelNumber() {
    return _levelNumber;
  }

  void increaseLevelNumber() {
    _levelNumber++;
  }

  Future<List<Compound>> generateCompoundPoolForCurrentLevel() {
    final frequencyClass = getFrequencyClassByLevel(_levelNumber);
    final compoundCount = getCompoundCountByLevel(_levelNumber);
    return _compoundPoolGenerator.generate(
      frequencyClass: frequencyClass,
      compoundCount: compoundCount,
    );
  }

  int getCompoundCountByLevel(int level);
  CompactFrequencyClass getFrequencyClassByLevel(int level);

}

class BasicLevelProvider extends LevelProvider {

    BasicLevelProvider(CompoundPoolGenerator compoundPoolGenerator, {required startingLevelNumber})
        : super(compoundPoolGenerator, startingLevelNumber: startingLevelNumber);

    @override
    int getCompoundCountByLevel(int level) {
      return 5;
    }

    @override
    CompactFrequencyClass getFrequencyClassByLevel(int level) {
      return CompactFrequencyClass.easy;
    }
}
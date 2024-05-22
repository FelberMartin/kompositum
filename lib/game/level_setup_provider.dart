import 'dart:math';

import 'package:kompositum/game/difficulty.dart';
import 'package:kompositum/game/level_setup.dart';


abstract class LevelSetupProvider {

  LevelSetup generateLevelSetup(Object levelIdentifier);

  int getSeedForLevel(int level) {
    return level + 8;
  }

  static Difficulty getRandomDifficulty(double weightEasy, double weightMedium,
      double weightHard, {int? seed}) {
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
}



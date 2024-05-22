
import 'package:kompositum/game/difficulty.dart';

import '../game/level_provider.dart';

class Costs {
  static const int hintCostBase = 30;
  static const int hintCostIncreasePerFailedAttempt = 3;

  static const int pastDailyCost = 60;

  static bool freeHintAvailable = false;

  static int hintCost({required int failedAttempts}) {
    if (freeHintAvailable) {
      return 0;
    }
    return hintCostBase + failedAttempts * hintCostIncreasePerFailedAttempt;
  }
}

class Rewards {
  static const int starsCompoundCompleted = 1;
  static const int starsEasyLevel = 3;
  static const int starsMediumLevel = 5;
  static const int starsHardLevel = 10;

  static int byDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return starsEasyLevel;
      case Difficulty.medium:
        return starsMediumLevel;
      case Difficulty.hard:
        return starsHardLevel;
      default:
        throw Exception("Unknown difficulty: $difficulty");
    }
  }

  static int getStarCountForFailedAttempts(
    int failedAttempts,
  ) {
    if (failedAttempts == 0) {
      return 3;
    } else if (failedAttempts <= 3) {
      return 2;
    } else if (failedAttempts <=5) {
      return 1;
    } else {
      return 0;
    }
  }
}
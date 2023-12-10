
import '../game/level_provider.dart';

class Costs {
  static const int hintCostNormal = 30;
  static const int hintCostNoAttemptsLeft = 40;
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
    }
  }
}
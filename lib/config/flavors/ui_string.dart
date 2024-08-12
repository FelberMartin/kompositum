import 'package:kompositum/game/difficulty.dart';

abstract class UiString {
  static final String placeholder = "####";

  abstract String btnPlayDailyLevel;
  abstract String ttlDailyLevelContainer;
  abstract String lblFeatureLockedTillLevel;
  abstract String lblLevelIndicator;

  String getDifficultyText(Difficulty difficulty);
}

class UiStringDe extends UiString {
  String btnPlayDailyLevel = "Start";
  String ttlDailyLevelContainer = "Tägliches Rätsel";
  String lblFeatureLockedTillLevel = "ab Level ${UiString.placeholder}";
  String lblLevelIndicator = "Level";

  @override
  String getDifficultyText(Difficulty difficulty) {
    switch(difficulty) {
      case Difficulty.easy:
        return "Einfach";
      case Difficulty.medium:
        return "Mittel";
      case Difficulty.hard:
        return "Schwer";
      default:
        throw ArgumentError("Unkown difficulty");
    }
  }
}

class UiStringEn extends UiString {
  String btnPlayDailyLevel = "Play";
  String ttlDailyLevelContainer = "Daily Level";
  String lblFeatureLockedTillLevel = "from level ${UiString.placeholder}";
  String lblLevelIndicator = "Level";

  @override
  String getDifficultyText(Difficulty difficulty) {
    switch(difficulty) {
      case Difficulty.easy:
        return "easy";
      case Difficulty.medium:
        return "medium";
      case Difficulty.hard:
        return "hard";
      default:
        throw ArgumentError("Unkown difficulty");
    }
  }
}
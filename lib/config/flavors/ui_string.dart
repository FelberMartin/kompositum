import 'package:kompositum/game/difficulty.dart';

abstract class UiString {
  static final String placeholder = "####";

  // Home
  abstract String btnPlayDailyLevel;
  abstract String ttlDailyLevelContainer;
  abstract String lblFeatureLockedTillLevel;
  abstract String lblLevelIndicator;

  // Settings
  abstract String ttlSettings;
  abstract String ttlNotifications;
  abstract String lblNotificationForDailies;
  abstract String ttlPrivacyPolicy;
  abstract String lblClickForPrivacyPolicy;

  String getDifficultyText(Difficulty difficulty);
}

class UiStringDe extends UiString {
  String btnPlayDailyLevel = "Start";
  String ttlDailyLevelContainer = "Tägliches Rätsel";
  String lblFeatureLockedTillLevel = "ab Level ${UiString.placeholder}";
  String lblLevelIndicator = "Level";

  String ttlSettings = "Einstellungen";
  String ttlNotifications = "Benachrichtigungen";
  String lblNotificationForDailies = "für Tägliche Rätsel";
  String ttlPrivacyPolicy = "Datenschutzerklärung";
  String lblClickForPrivacyPolicy = "Klicke hier, um unsere Datenschutzerklärung zu lesen (Englisch).";

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

  String ttlSettings = "Settings";
  String ttlNotifications = "Notifications";
  String lblNotificationForDailies = "for Daily Levels";
  String ttlPrivacyPolicy = "Privacy Policy";
  String lblClickForPrivacyPolicy = "Click here to read our privacy policy.";

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
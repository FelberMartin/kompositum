import 'package:kompositum/config/flavors/flavor.dart';
import 'package:kompositum/game/difficulty.dart';

/// Abstract class for UI strings. Implementations should provide the strings for the app in a specific language.
/// For naming the variables, use the following pattern:
/// - Use `btn` for buttons
/// - Use `ttl` for titles
/// - Use `lbl` for labels
/// - Use `smt` for semantic texts (toolstips, screen reader texts)
///
abstract class UiString {

  final Flavor flavor;

  UiString(this.flavor);

  static final String placeholder = "####";

  // Home
  abstract String btnPlayDailyLevel;
  abstract String ttlDailyLevelContainer;
  abstract String lblFeatureLockedTillLevel;
  abstract String lblLevelIndicator;
  abstract String lblHiddenLevelDone;
  abstract String lblHiddenLevel;
  abstract String btnPlayHiddenLevel;
  abstract String lblDailyGoals;

  // Settings
  abstract String ttlSettings;
  abstract String ttlNotifications;
  abstract String lblNotificationForDailies;
  abstract String ttlPrivacyPolicy;
  abstract String lblClickForPrivacyPolicy;

  // DailyOverview
  abstract String ttlDailyLevels;
  abstract String smtPreviousMonth;
  abstract String smtNextMonth;
  abstract String ttlDialogPlayPastDaily;
  abstract String lblDialogPlayPastDailySubtitle;
  abstract String lblAd;

  // Game
  abstract String ttlHiddenLevel;
  abstract String lblChainGameLevel;

  // Ads
  abstract String lblDoYouEnjoy;
  abstract String lblThenTellYourFriends;
  abstract String btnShare;

  // Notification
  abstract String ttlDefaultNotificationTitle;
  abstract List<String> ttlNotificationVariants;
  abstract String lblNotificationDescription;

  // Misc
  abstract String shareText;

  String getDifficultyText(Difficulty difficulty);
}

class UiStringDe extends UiString {
  UiStringDe(super.flavor);

  // Home
  String btnPlayDailyLevel = "Start";
  String ttlDailyLevelContainer = "Tägliches Rätsel";
  String lblFeatureLockedTillLevel = "ab Level ${UiString.placeholder}";
  String lblLevelIndicator = "Level";
  String lblHiddenLevelDone = "Verstecktes Level absolviert!";
  String lblHiddenLevel = "Verstecktes Level";
  String btnPlayHiddenLevel = "Spielen";
  String lblDailyGoals = "Tagesziele";

  // Settings
  String ttlSettings = "Einstellungen";
  String ttlNotifications = "Benachrichtigungen";
  String lblNotificationForDailies = "für Tägliche Rätsel";
  String ttlPrivacyPolicy = "Datenschutzerklärung";
  String lblClickForPrivacyPolicy = "Klicke hier, um unsere Datenschutzerklärung zu lesen (Englisch).";

  // DailyOverview
  String ttlDailyLevels = "Tägliche Rätsel";
  String smtPreviousMonth = "Vorheriger Monat";
  String smtNextMonth = "Nächster Monat";
  String ttlDialogPlayPastDaily = "Vergangenes tägliches Rätsel!";
  String lblDialogPlayPastDailySubtitle = "Aber keine Sorge, du kannst es noch nachholen!";
  String lblAd = "Werbung";

  // Game
  String ttlHiddenLevel = "Verstecktes Level";
  String lblChainGameLevel = "Wortkette";

  // Ads
  String lblDoYouEnjoy = "Gefällt dir";
  String lblThenTellYourFriends = "Dann empfehle es deinen Freunden!";
  String btnShare = "Teilen";

  // Notification
  String ttlDefaultNotificationTitle = "Tägliches Rätsel";
  List<String> ttlNotificationVariants = ["Wer rastet, der rostet", "Täglich grüßt das Murmeltier"];
  String lblNotificationDescription = "Dein tägliches Rätsel wartet noch darauf gelöst zu werden!";

  // Misc
  late String shareText = "Entdecke jetzt meine neue Lieblings-App '${flavor.storeAppName}'!\n\n"
      "Android: ${flavor.playStoreLink}\niOS: ${flavor.appStoreLink}";

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
  UiStringEn(super.flavor);

  // Home
  String btnPlayDailyLevel = "Play";
  String ttlDailyLevelContainer = "Daily Level";
  String lblFeatureLockedTillLevel = "from level ${UiString.placeholder}";
  String lblLevelIndicator = "Level";
  String lblHiddenLevelDone = "Hidden level completed!";
  String lblHiddenLevel = "Hidden Level";
  String btnPlayHiddenLevel = "Play";
  String lblDailyGoals = "Daily Goals";

  // Settings
  String ttlSettings = "Settings";
  String ttlNotifications = "Notifications";
  String lblNotificationForDailies = "for Daily Levels";
  String ttlPrivacyPolicy = "Privacy Policy";
  String lblClickForPrivacyPolicy = "Click here to read our privacy policy.";

  // DailyOverview
  String ttlDailyLevels = "Daily Levels";
  String smtPreviousMonth = "Previous Month";
  String smtNextMonth = "Next Month";
  String ttlDialogPlayPastDaily = "Past Daily Level!";
  String lblDialogPlayPastDailySubtitle = "But don't worry, you can still catch up!";
  String lblAd = "Ad";

  // Game
  String ttlHiddenLevel = "Hidden Level";
  String lblChainGameLevel = "Chain";

  // Ads
  String lblDoYouEnjoy = "Do you enjoy";
  String lblThenTellYourFriends = "Then tell your friends!";
  String btnShare = "Share";

  // Notification
  String ttlDefaultNotificationTitle = "Daily Level";
  List<String> ttlNotificationVariants = ["Who rests, rusts", "Every day is Groundhog Day"];
  String lblNotificationDescription = "Your daily level is waiting to be solved!";

  // Misc
  late String shareText = "Discover my new favorite app '${flavor.storeAppName}'!\n\n"
      "Android: ${flavor.playStoreLink}\niOS: ${flavor.appStoreLink}";

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
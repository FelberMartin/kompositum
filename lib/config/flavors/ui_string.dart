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
  abstract String lblHiddenWords;
  abstract String lblSnackbarMuted;
  abstract String lblSnackbarUnmuted;

  // Game - Dialogs
  abstract String ttlChainNewGameMode;
  abstract String lblChainNewGameModeDescription;
  abstract String lblChainNewGameModeTryIt;
  abstract String btnGotIt;

  abstract String ttlHiddenComponents;
  abstract String lblHiddenComponentsDescription;

  abstract String ttlHints;
  abstract String lblHintsDescription;
  abstract String lblHintsTryIt;

  abstract String ttlMissingCompounds;
  abstract String lblMissingCompoundsDescription;
  abstract String lblMissingCompoundsDescription2;

  abstract List<String> ttlLevelCompletedVariants;
  abstract String lblLevelCompleted;
  abstract String lblDifficulty;
  abstract String lblMistakes;
  abstract String btnContinue;
  abstract String btnBackToOverview;

  abstract String ttlNoAttemptsLeft;
  abstract String btnContinueWithHint;
  abstract String btnRestartGame;

  abstract String ttlReport;
  abstract String lblReportDescription;
  abstract String btnCancel;
  abstract String btnSend;
  abstract String lblEnterWordHint;


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
  String lblHiddenWords = "Versteckte Wörter";
  String lblSnackbarMuted = "Lautlos";
  String lblSnackbarUnmuted = "Ton an";

  // Game - Dialogs
  String ttlChainNewGameMode = "💡 Neuer Spielmodus: Wortkette!";
  String lblChainNewGameModeDescription = "Bei diesem Spielmodus ist das erste Wort gegeben und du musst nur das dazugehörige zweite Wort finden. "
      "Danach geht es immer so weiter und es bildet sich ein lange Wortkette.";
  String lblChainNewGameModeTryIt = "Probier es einfach aus!";
  String btnGotIt = "Alles klar";

  String ttlHiddenComponents = "💡 Verdeckte Wörter";
  String lblHiddenComponentsDescription = "Verdeckte Wörter werden erst sichtbar, wenn du andere Wörter richtig kombinierst!";

  String ttlHints = "💡 Tipps";
  String lblHintsDescription = "Wenn du Hilfe brauchst und nicht mehr weiter weißt, benutze einen Tipp!";
  String lblHintsTryIt = "Probier es einfach aus, der erste Tipp geht aufs Haus!";

  String ttlMissingCompounds = "💡 Fehlende Wörter";
  String lblMissingCompoundsDescription = "Hast du ein richtiges Wort kombiniert, aber es wird nicht aktzeptiert? "
      "Du kannst diese Wörter melden und wir kümmern uns darum!";
  String lblMissingCompoundsDescription2 = "Du kannst diese Wörter melden und wir kümmern uns darum!";

  List<String> ttlLevelCompletedVariants = [
    "Glückwunsch!",
    "Super!",
    "Fantastisch!",
    "Perfekt!",
    "Gut gemacht!",
    "Bravo!",
    "Genial!",
    "Sensationell!",
    "Klasse!",
    "Wow!",
    "Ausgezeichnet!",
    "Großartig!",
    "Einfach stark!"
  ];
  String lblLevelCompleted = "Level geschaft!";
  String lblDifficulty = "Schwierigkeit";
  String lblMistakes = "Fehler";
  String btnContinue = "Weiter";
  String btnBackToOverview = "Zurück zur Übersicht";

  String ttlNoAttemptsLeft = "Du hast alle Versuche aufgebraucht!";
  String btnContinueWithHint = "Mit Tipp fortfahren";
  String btnRestartGame = "Neustarten";

  String ttlReport = "Du hast ein fehlendes Wort gefunden?";
  String lblReportDescription = "Danke, dass du uns hilfst das Spiel noch besser zu machen!";
  String btnCancel = "Abbrechen";
  String btnSend = "Senden";
  String lblEnterWordHint = "Wort eingeben";


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
  String lblHiddenWords = "Hidden Words";
  String lblSnackbarMuted = "Muted";
  String lblSnackbarUnmuted = "Unmuted";

  // Game - Dialogs
  String ttlChainNewGameMode = "💡 New Game Mode: Chain!";
  String lblChainNewGameModeDescription = "In this game mode, the first word is given and you only have to find the corresponding second word. "
      "After that, it continues like this and a long chain of words is formed.";
  String lblChainNewGameModeTryIt = "Just try it out!";
  String btnGotIt = "Got it";

  String ttlHiddenComponents = "💡 Hidden Words";
  String lblHiddenComponentsDescription = "Hidden words only become visible when you combine other words correctly!";

  String ttlHints = "💡 Hints";
  String lblHintsDescription = "If you need help and don't know what to do next, use a hint!";
  String lblHintsTryIt = "Just try it out, the first hint is on the house!";

  String ttlMissingCompounds = "💡 Missing Words";
  String lblMissingCompoundsDescription = "Have you combined a correct word, but it is not accepted? "
      "You can report these words and we will take care of it!";
  String lblMissingCompoundsDescription2 = "You can report these words and we will take care of it!";

  List<String> ttlLevelCompletedVariants = [
    "Congratulations!",
    "Great!",
    "Fantastic!",
    "Perfect!",
    "Well done!",
    "Bravo!",
    "Genius!",
    "Wow!",
    "Excellent!",
    "Great!",
    "Simply great!"
  ];
  String lblLevelCompleted = "Level completed!";
  String lblDifficulty = "Difficulty";
  String lblMistakes = "Mistakes";
  String btnContinue = "Continue";
  String btnBackToOverview = "Back to Overview";

  String ttlNoAttemptsLeft = "You have used all attempts!";
  String btnContinueWithHint = "Continue with Hint";
  String btnRestartGame = "Restart";

  String ttlReport = "Did you find a missing word?";
  String lblReportDescription = "Thank you for helping us make the game even better!";
  String btnCancel = "Cancel";
  String btnSend = "Send";
  String lblEnterWordHint = "Enter word";


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
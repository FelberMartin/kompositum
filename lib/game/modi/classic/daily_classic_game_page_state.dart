import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kompositum/game/modi/classic/classic_game_page_state.dart';
import 'package:kompositum/game/modi/classic/classic_level_setup_provider.dart';
import 'package:kompositum/game/level_content_generator.dart';
import 'package:kompositum/game/modi/classic/main_classic_game_page_state.dart';
import 'package:kompositum/screens/game_page.dart';

import '../../../config/locator.dart';
import '../../../data/key_value_store.dart';
import '../../swappable_detector.dart';
import '../../../util/notifications/daily_notification_scheduler.dart';
import '../../../util/tutorial_manager.dart';
import '../../../widgets/play/dialogs/level_completed_dialog.dart';

class DailyClassicGamePageState extends ClassicGamePageState {
  DailyClassicGamePageState({
    required super.levelSetupProvider,
    required super.levelContentGenerator,
    required super.keyValueStore,
    required super.swappableDetector,
    required super.tutorialManager,
    required this.date,
  });

  factory DailyClassicGamePageState.fromLocator(DateTime date) {
    return DailyClassicGamePageState(
      levelSetupProvider: DailyLevelSetupProvider(),
      levelContentGenerator: locator<LevelContentGenerator>(),
      keyValueStore: locator<KeyValueStore>(),
      swappableDetector: locator<SwappableDetector>(),
      tutorialManager: locator<TutorialManager>(),
      date: date,
    );
  }

  final DateTime date;

  @override
  void startGame() async {
    updateGameToLevel(date, isLevelAdvance: false);
  }

  @override
  Future<void> preLevelUpdate(Object levelIdentifier, isLevelAdvance) async {
    // Do nothing
  }

  @override
  void onGameLevelUpdate() {
    // Do nothing
  }

  @override
  void levelCompleted() async {
    await _storeDailyLevelCompletion();
    _updateDailyNotification();
    super.levelCompleted();
  }

  Future<void> _storeDailyLevelCompletion() async {
    final completedDailies = await keyValueStore.getDailiesCompleted();
    completedDailies.add(date);
    await keyValueStore.storeDailiesCompleted(completedDailies);
  }

  void _updateDailyNotification() {
    final dailyScheduler = locator<DailyNotificationScheduler>();
    dailyScheduler.tryScheduleNextDailyNotifications(now: DateTime.now());
  }

  @override
  String getLevelTitle() {
    var dateText = DateFormat("dd. MMM", "de").format(date);
    return dateText;
  }

  @override
  LevelCompletedDialogType getLevelCompletedDialogType() {
    return LevelCompletedDialogType.daily;
  }

  @override
  void onLevelCompletedDialogClosed(LevelCompletedDialogResultType resultType) {
    if (resultType == LevelCompletedDialogResultType.daily_backToOverview) {
      Navigator.pop(context);
      return;
    } else if (resultType == LevelCompletedDialogResultType.daily_continueWithClassic) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GamePage(state: MainClassicGamePageState.fromLocator())),
        );
      return;
    }
  }
}

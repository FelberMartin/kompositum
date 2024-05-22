import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kompositum/game/modi/pool/generator/compound_pool_generator.dart';
import 'package:kompositum/game/modi/pool/pool_level_provider.dart';
import 'package:kompositum/screens/game_page.dart';

import '../config/locator.dart';
import '../data/key_value_store.dart';
import '../game/swappable_detector.dart';
import '../util/notifications/daily_notification_scheduler.dart';
import '../util/tutorial_manager.dart';
import '../widgets/play/dialogs/level_completed_dialog.dart';
import 'game_page_classic.dart';

class GamePageDailyState extends GamePageState {
  GamePageDailyState({
    required super.levelProvider,
    required super.poolGenerator,
    required super.keyValueStore,
    required super.swappableDetector,
    required super.tutorialManager,
    required this.date,
  });

  factory GamePageDailyState.fromLocator(DateTime date) {
    return GamePageDailyState(
      levelProvider: DailyLevelProvider(),
      poolGenerator: locator<CompoundPoolGenerator>(),
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
    dailyScheduler.tryScheduleNextDailyNotification(now: DateTime.now());
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
          MaterialPageRoute(builder: (context) => GamePage(state: GamePageClassicState.fromLocator())),
        );
      return;
    }
  }
}

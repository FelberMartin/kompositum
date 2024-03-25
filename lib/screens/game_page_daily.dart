import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kompositum/screens/game_page.dart';

import '../config/locator.dart';
import '../data/key_value_store.dart';
import '../game/level_provider.dart';
import '../game/pool_generator/compound_pool_generator.dart';
import '../game/swappable_detector.dart';
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
  Future<void> startGame() async {
    updateGameToLevel(date, isLevelAdvance: false);
  }

  @override
  Future<void> preLevelUpdate(Object levelIdentifier, isLevelAdvance) async {
    poolGenerator.setBlockedCompounds([]);
  }

  @override
  void onPoolGameLevelUpdate() {
    // Do nothing
  }

  @override
  String getLevelTitle() {
    var dateText = DateFormat("dd. MMM", "de").format(date);
    return dateText.substring(0, dateText.length - 1);
  }

  @override
  LevelCompletedDialogType getLevelCompletedDialogType() {
    return LevelCompletedDialogType.daily;
  }

  @override
  void onLevelCompletion(LevelCompletedDialogResultType resultType) {
    keyValueStore.getDailiesCompleted().then((value) {
      value.add(date);
      keyValueStore.storeDailiesCompleted(value);
    });

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

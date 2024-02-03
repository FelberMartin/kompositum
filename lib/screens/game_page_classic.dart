import 'package:flutter/material.dart';

import '../config/locator.dart';
import '../config/star_costs_rewards.dart';
import '../data/key_value_store.dart';
import '../data/models/compound.dart';
import '../game/level_provider.dart';
import '../game/pool_generator/compound_pool_generator.dart';
import '../game/swappable_detector.dart';
import '../widgets/common/my_dialog.dart';
import '../widgets/play/dialogs/level_completed_dialog.dart';
import '../widgets/play/star_fly_animation.dart';
import 'game_page.dart';

class GamePageClassicState extends GamePageState {
  GamePageClassicState({required super.levelProvider, required super.poolGenerator, required super.keyValueStore, required super.swappableDetector});

  factory GamePageClassicState.fromLocator() {
    return GamePageClassicState(
      levelProvider: locator<LevelProvider>(),
      poolGenerator: locator<CompoundPoolGenerator>(),
      keyValueStore: locator<KeyValueStore>(),
      swappableDetector: locator<SwappableDetector>(),
    );
  }

  int currentLevel = 0;

  @override
  void startGame() async {
    currentLevel = await keyValueStore.getLevel();
    final storedProgress = await keyValueStore.getClassicPoolGameLevel();
    if (storedProgress != null) {
      if (storedProgress.shownComponents.isEmpty) {
        updateGameToLevel(currentLevel + 1, isLevelAdvance: true);
        return;
      }
      levelSetup = levelProvider.generateLevelSetup(currentLevel);
      poolGameLevel = storedProgress;
      setState(() { isLoading = false; });
      print("Loaded level $currentLevel from storage");
    } else {
      updateGameToLevel(currentLevel, isLevelAdvance: false);
    }
  }

  @override
  Future<void> preLevelUpdate(Object levelIdentifier, isLevelAdvance) async {
    assert(levelIdentifier is int);
    final newLevelNumber = levelIdentifier as int;
    if (isLevelAdvance) {
      currentLevel = newLevelNumber;
      keyValueStore.storeLevel(newLevelNumber);
      // Save the blocked compounds BEFORE the generation of the new level,
      // so that when regenerating the same level later, the same compounds
      // are blocked.
      keyValueStore.storeBlockedCompounds(poolGenerator.getBlockedCompounds());
    } else {
      final blocked = await keyValueStore.getBlockedCompoundNames();
      poolGenerator.setBlockedCompounds(blocked);
    }
  }

  @override
  void onPoolGameLevelUpdate() {
    keyValueStore.storeClassicPoolGameLevel(poolGameLevel);
  }

  @override
  String getLevelTitle() {
    return "Level $currentLevel";
  }

  @override
  LevelCompletedDialogType getLevelCompletedDialogType() {
    return LevelCompletedDialogType.classic;
  }

  @override
  void onLevelCompletion(LevelCompletedDialogResultType resultType) {
    assert(resultType == LevelCompletedDialogResultType.classic_continue);
    updateGameToLevel(currentLevel + 1, isLevelAdvance: true);
  }

}
import 'package:kompositum/game/modi/pool/pool_game_level.dart';

import '../config/locator.dart';
import '../data/key_value_store.dart';
import '../game/level_provider.dart';
import '../game/modi/pool/generator/compound_pool_generator.dart';
import '../game/stored_level_loader.dart';
import '../game/swappable_detector.dart';
import '../util/tutorial_manager.dart';
import '../widgets/play/dialogs/level_completed_dialog.dart';
import 'game_page.dart';

class GamePageClassicState extends GamePageState {
  GamePageClassicState({
    required super.levelProvider,
    required super.poolGenerator,
    required super.keyValueStore,
    required super.swappableDetector,
    required super.tutorialManager,
    super.gameMode
  });

  factory GamePageClassicState.fromLocator([GameMode gameMode = GameMode.Pool]) {
    return GamePageClassicState(
      levelProvider: locator<LevelProvider>(),
      poolGenerator: locator<CompoundPoolGenerator>(),
      keyValueStore: locator<KeyValueStore>(),
      swappableDetector: locator<SwappableDetector>(),
      tutorialManager: locator<TutorialManager>(),
      gameMode: gameMode
    );
  }

  int currentLevel = 0;

  @override
  void startGame() async {
    if (gameMode != GameMode.Pool) {
      updateGameToLevel(currentLevel, isLevelAdvance: false);
      return;
    }
    final blocked = await keyValueStore.getBlockedCompoundNames();
    await poolGenerator.setBlockedCompounds(blocked);

    currentLevel = await keyValueStore.getLevel();
    final levelLoader = StoredLevelLoader(keyValueStore);
    levelLoader.loadLevel().then(_onPoolGameLevelLoaded).catchError((error) {
      // Skip the corrupted level and advance to the next level.
      print("Error loading level: $error");
      updateGameToLevel(currentLevel + 1, isLevelAdvance: true);
    });
  }

  void _onPoolGameLevelLoaded(PoolGameLevel? loadedLevel) {
    if (loadedLevel == null) {
      // Should only happen for the first level or if stored level is got deleted.
      updateGameToLevel(currentLevel, isLevelAdvance: false);
    } else {
      // Default case: Load the stored level.
      levelSetup = levelProvider.generateLevelSetup(currentLevel);
      gameLevel = loadedLevel;
      if (gameLevel.attemptsWatcher.allAttemptsUsed()) {
        showNoAttemptsLeftDialog();
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Future<void> preLevelUpdate(Object levelIdentifier, isLevelAdvance) async {
    assert(levelIdentifier is int);
    final newLevelNumber = levelIdentifier as int;
    if (isLevelAdvance) {
      currentLevel = newLevelNumber;
      await keyValueStore.storeLevel(newLevelNumber);
      // Save the blocked compounds BEFORE the generation of the new level,
      // so that when regenerating the same level later, the same compounds
      // are blocked.
      await keyValueStore.storeBlockedCompounds(poolGenerator.getBlockedCompounds());
    } else {
      final blocked = await keyValueStore.getBlockedCompoundNames();
      await poolGenerator.setBlockedCompounds(blocked);
    }
  }

  @override
  void onGameLevelUpdate() {
    keyValueStore.storeClassicPoolGameLevel(gameLevel as PoolGameLevel);
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
  void onLevelCompletedDialogClosed(LevelCompletedDialogResultType resultType) {
    assert(resultType == LevelCompletedDialogResultType.classic_continue);
    updateGameToLevel(currentLevel + 1, isLevelAdvance: true);
  }
}

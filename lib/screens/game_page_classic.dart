import '../config/locator.dart';
import '../data/key_value_store.dart';
import '../game/level_loader.dart';
import '../game/level_provider.dart';
import '../game/pool_generator/compound_pool_generator.dart';
import '../game/swappable_detector.dart';
import '../util/tutorial_manager.dart';
import '../widgets/play/dialogs/level_completed_dialog.dart';
import 'game_page.dart';
import 'package:kompositum/game/pool_game_level.dart';

class GamePageClassicState extends GamePageState {
  GamePageClassicState({
    required super.levelProvider,
    required super.poolGenerator,
    required super.keyValueStore,
    required super.swappableDetector,
    required super.tutorialManager,
  });

  factory GamePageClassicState.fromLocator() {
    return GamePageClassicState(
      levelProvider: locator<LevelProvider>(),
      poolGenerator: locator<CompoundPoolGenerator>(),
      keyValueStore: locator<KeyValueStore>(),
      swappableDetector: locator<SwappableDetector>(),
      tutorialManager: locator<TutorialManager>(),
    );
  }

  int currentLevel = 0;

  @override
  Future<void> startGame() async {
    currentLevel = await keyValueStore.getLevel();
    final levelLoader = LevelLoader(keyValueStore);
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
      poolGameLevel = loadedLevel;
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

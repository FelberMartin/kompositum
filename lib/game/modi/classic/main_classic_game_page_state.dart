import 'package:kompositum/config/flavors/flavor.dart';
import 'package:kompositum/game/modi/classic/classic_game_level.dart';
import 'package:kompositum/game/modi/classic/classic_game_page_state.dart';

import '../../../config/locator.dart';
import '../../../data/key_value_store.dart';
import '../../level_setup_provider.dart';
import '../../level_content_generator.dart';
import '../../stored_level_loader.dart';
import '../../swappable_detector.dart';
import '../../../util/tutorial_manager.dart';
import '../../../widgets/play/dialogs/level_completed_dialog.dart';

class MainClassicGamePageState extends ClassicGamePageState {
  MainClassicGamePageState({
    required super.levelSetupProvider,
    required super.levelContentGenerator,
    required super.keyValueStore,
    required super.swappableDetector,
    required super.tutorialManager,
  });

  factory MainClassicGamePageState.fromLocator() {
    return MainClassicGamePageState(
      levelSetupProvider: locator<LevelSetupProvider>(),
      levelContentGenerator: locator<LevelContentGenerator>(),
      keyValueStore: locator<KeyValueStore>(),
      swappableDetector: locator<SwappableDetector>(),
      tutorialManager: locator<TutorialManager>(),
    );
  }

  int currentLevel = 0;

  @override
  void startGame() async {
    final blocked = await keyValueStore.getBlockedCompoundNames();
    await levelContentGenerator.setBlockedCompounds(blocked);

    currentLevel = await keyValueStore.getLevel();
    final levelLoader = StoredLevelLoader(keyValueStore);
    levelLoader.loadLevel().then(_onPoolGameLevelLoaded).catchError((error) {
      // Skip the corrupted level and advance to the next level.
      print("Error loading level: $error");
      updateGameToLevel(currentLevel + 1, isLevelAdvance: true);
    });
  }

  void _onPoolGameLevelLoaded(ClassicGameLevel? loadedLevel) {
    if (loadedLevel == null) {
      // Should only happen for the first level or if stored level is got deleted.
      updateGameToLevel(currentLevel, isLevelAdvance: false);
    } else {
      // Default case: Load the stored level.
      levelSetup = levelSetupProvider.generateLevelSetup(currentLevel);
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
      await keyValueStore.storeBlockedCompounds(levelContentGenerator.getBlockedCompounds());
    } else {
      final blocked = await keyValueStore.getBlockedCompoundNames();
      await levelContentGenerator.setBlockedCompounds(blocked);
    }
  }

  @override
  void onGameLevelUpdate() {
    keyValueStore.storeClassicGameLevel(gameLevel as ClassicGameLevel);
  }

  @override
  String getLevelTitle() {
    return Flavor.instance.uiString.lblLevelIndicator + " $currentLevel";
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

import '../data/models/compound.dart';
import 'game_page.dart';

class GamePageClassicState extends GamePageState {
  GamePageClassicState({required super.levelProvider, required super.poolGenerator, required super.keyValueStore, required super.swappableDetector});

  int currentLevel = 0;

  @override
  void startGame() async {
    currentLevel = await keyValueStore.getLevel();
    final storedProgress = await keyValueStore.getClassicPoolGameLevel();
    if (storedProgress != null) {
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
  void onLevelCompletion() {
    updateGameToLevel(currentLevel + 1, isLevelAdvance: true);
  }

}
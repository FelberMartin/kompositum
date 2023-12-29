import 'game_page.dart';

class GamePageClassicState extends GamePageState {
  GamePageClassicState({required super.levelProvider, required super.poolGenerator, required super.keyValueStore, required super.swappableDetector});

  int currentLevel = 0;

  @override
  void startGame() {
    keyValueStore.getLevel().then((value) {
      currentLevel = value;
      updateGameToLevel(currentLevel, isLevelAdvance: false);
    });
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
  String getLevelTitle() {
    return "Level $currentLevel";
  }

  @override
  void onLevelCompletion() {
    updateGameToLevel(currentLevel + 1, isLevelAdvance: true);
  }

}
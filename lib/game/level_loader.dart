import 'package:kompositum/game/pool_game_level.dart';

import '../data/key_value_store.dart';

class LevelLoader {

  final KeyValueStore _keyValueStore;

  LevelLoader(this._keyValueStore);

  Future<PoolGameLevel?> loadLevel() async {
    final storedProgress = await _keyValueStore.getClassicPoolGameLevel();
    if (storedProgress == null) {
      return null;
    }

    final isEmpty = storedProgress.shownComponents.isEmpty;
    if (isEmpty) {
      throw Exception("Stored level has no shown components");
    }

    final componentCount = storedProgress.shownComponents.length + storedProgress.hiddenComponents.length;
    final componentCountOdd = componentCount % 2 != 0;
    if (componentCountOdd) {
      throw Exception("Stored level has odd component count (is not solvable)");
    }

    return storedProgress;
  }

}
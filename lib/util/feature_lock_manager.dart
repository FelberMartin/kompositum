import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/game_event/game_event.dart';

class FeatureLockManager {

  final Stream<GameEvent> gameEventStream;
  final KeyValueStore keyValueStore;

  bool _isDailyLevelFeatureLocked = false;
  bool get isDailyLevelFeatureLocked => _isDailyLevelFeatureLocked;
  static const int dailyLevelFeatureLockLevel = 20;

  bool _isDailyGoalsFeatureLocked = false;
  bool get isDailyGoalsFeatureLocked => _isDailyGoalsFeatureLocked;
  static const int dailyGoalsFeatureLockLevel = 50;

  FeatureLockManager({
    required this.gameEventStream,
    required this.keyValueStore
  }) {
    gameEventStream.listen(_handleGameEvent);
    update();
  }

  Future<void> update() async {
    final level = await keyValueStore.getLevel();
    _isDailyLevelFeatureLocked = level < dailyLevelFeatureLockLevel;
    _isDailyGoalsFeatureLocked = level < dailyGoalsFeatureLockLevel;
  }

  void _handleGameEvent(GameEvent event) {
    if (event is NewLevelStartGameEvent) {
      update();
    }
  }

}
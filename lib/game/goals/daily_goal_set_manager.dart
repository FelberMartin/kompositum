import 'dart:async';

import 'package:kompositum/util/extensions/date_util.dart';
import 'package:kompositum/util/feature_lock_manager.dart';

import '../../data/key_value_store.dart';
import '../../data/models/daily_goal_set.dart';
import '../../util/device_info.dart';
import '../game_event/game_event.dart';
import '../game_event/game_event_stream.dart';


class DailyGoalSetProgression {
  final DailyGoalSet previous;
  final DailyGoalSet current;

  DailyGoalSetProgression(this.previous, this.current);
}

/// Manages the daily goal set for the player. Stores the progress, connects
/// to the game event stream and updates the daily goal set.
/// Monitors the progression of the goalSet during a game, that can then be used
/// to animate the progression.
class DailyGoalSetManager {
  final KeyValueStore keyValueStore;
  final DeviceInfo deviceInfo;
  final FeatureLockManager featureLockManager;

  DailyGoalSet? _dailyGoalSet;
  DailyGoalSetProgression? _progression;

  DailyGoalSetManager({
    required this.keyValueStore,
    required this.deviceInfo,
    required this.featureLockManager,
  }) {
    update();
    registerGameEventStream(GameEventStream.instance.stream);
  }

  Future<DailyGoalSet> getDailyGoalSet() async {
    if (_dailyGoalSet == null) {
      await update();
    }
    return _dailyGoalSet!;
  }

  Future<DailyGoalSetProgression> getProgression() async {
    if (_progression == null) {
      await update();
    }
    return _progression!;
  }

  Future<void> update() async {
    _dailyGoalSet = await _loadFromDiskOrCreate(DateTime.now());
    resetProgression();
  }

  void resetProgression() {
    _progression = DailyGoalSetProgression(_dailyGoalSet!.copy(), _dailyGoalSet!);
  }

  /// Returns the daily goal set for the current day.
  /// If no goal set exists for the current day, a new one is generated.
  /// Else-wise the existing one with its stored progress is loaded.
  Future<DailyGoalSet> _loadFromDiskOrCreate(DateTime now) async {
    final creationSeed = await deviceInfo.getDeviceSpecificSeed();
    final json = await keyValueStore.getDailyGoalSetJson();
    if (json == null) {
      return DailyGoalSet.generate(creationSeed: creationSeed, date: now);
    }

    final goalSet = DailyGoalSet.fromJson(map: json, creationSeed: creationSeed);
    if (goalSet.date.isSameDate(now)) {
      return goalSet;
    }
    return DailyGoalSet.generate(creationSeed: creationSeed, date: now);
  }

  void registerGameEventStream(Stream<GameEvent> stream) {
    stream.listen((event) {
      if (featureLockManager.isDailyGoalsFeatureLocked) {
        return;
      }

      final dailyGoalSet = _dailyGoalSet!;
      final progressBefore = dailyGoalSet.progress;
      final secretLevelBefore = dailyGoalSet.isSecretLevelCompleted;
      dailyGoalSet.processGameEvent(event);
      if (dailyGoalSet.progress > progressBefore ||
          dailyGoalSet.isSecretLevelCompleted != secretLevelBefore) {
        keyValueStore.storeDailyGoalSet(dailyGoalSet);
      }
    });
  }
}
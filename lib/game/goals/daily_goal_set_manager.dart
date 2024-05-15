import 'dart:async';

import 'package:kompositum/util/date_util.dart';

import '../../data/key_value_store.dart';
import '../../data/models/daily_goal_set.dart';
import '../../util/device_info.dart';
import '../game_event/game_event.dart';
import '../game_event/game_event_stream.dart';

class DailyGoalSetManager {
  final KeyValueStore keyValueStore;
  final DeviceInfo deviceInfo;

  late final Future<void> ensureInitialized;
  late DailyGoalSet _dailyGoalSet;
  DailyGoalSet get dailyGoalSet => _dailyGoalSet;

  DailyGoalSetManager(this.keyValueStore, this.deviceInfo) {
    ensureInitialized = update();
    registerGameEventStream(GameEventStream.instance.stream);
  }

  Future<void> update() async {
    final now = DateTime.now();
    _dailyGoalSet = await _loadFromDisk(now);
  }

  /// Returns the daily goal set for the current day.
  /// If no goal set exists for the current day, a new one is generated.
  /// Else-wise the existing one with its stored progress is loaded.
  Future<DailyGoalSet> _loadFromDisk(DateTime now) async {
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
      final progressBefore = _dailyGoalSet.progress;
      _dailyGoalSet.processGameEvent(event);
      if (_dailyGoalSet.progress > progressBefore) {
        keyValueStore.storeDailyGoalSet(_dailyGoalSet);
      }
    });
  }

}
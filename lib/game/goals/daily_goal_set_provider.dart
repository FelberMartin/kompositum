import 'package:kompositum/util/date_util.dart';

import '../../data/key_value_store.dart';
import '../../data/models/daily_goal_set.dart';
import '../../util/device_info.dart';

class DailyGoalSetProvider {
  final KeyValueStore keyValueStore;
  final DeviceInfo deviceInfo;

  const DailyGoalSetProvider(this.keyValueStore, this.deviceInfo);

  /// Returns the daily goal set for the current day.
  /// If no goal set exists for the current day, a new one is generated.
  /// Else-wise the existing one with its stored progress is loaded.
  Future<DailyGoalSet> getTodaysDailyGoalSet(DateTime now) async {
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
}

import 'package:shared_preferences/shared_preferences.dart';

import 'models/compound.dart';

class KeyValueStore {

  KeyValueStore({String? env}) {
    if (true) {
      SharedPreferences.setMockInitialValues({});
    }
  }

  Future<void> storeLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("level", level);
  }

  Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("level") ?? 1;
  }

  Future<void> storeBlockedCompounds(List<Compound> compounds) async {
    final prefs = await SharedPreferences.getInstance();
    final blockedCompoundNames = compounds.map((compound) => compound.name).toList();
    await prefs.setStringList("blockedCompounds", blockedCompoundNames);
  }

  Future<List<String>> getBlockedCompoundNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("blockedCompounds") ?? [];
  }

  Future<void> storeStarCount(int starCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("starCount", starCount);
  }

  Future<int> getStarCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("starCount") ?? 0;
  }

  Future<void> storeDailiesCompleted(List<DateTime> completedDays) async {
    final prefs = await SharedPreferences.getInstance();
    final completedDaysString = completedDays.map((day) => day.toIso8601String()).toList();
    await prefs.setStringList("completedDays", completedDaysString);
  }

  Future<List<DateTime>> getDailiesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completedDaysString = prefs.getStringList("completedDays") ?? [];
    return completedDaysString.map((dayString) => DateTime.parse(dayString)).toList();
  }


}